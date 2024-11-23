#!/bin/bash

# Exit on errors
set -e

# Configuration Variables
DOCKER_USERNAME=""
DOCKER_IMAGE="microblog-prod"
DOCKER_TAG="latest"
MYSQL_CONTAINER_NAME="mysql"
APP_CONTAINER_NAME="microblog-server"
MYSQL_ROOT_PASSWORD=""
MYSQL_DATABASE="microblog"
MYSQL_USER="microblog"
MYSQL_PASSWORD=""
SECRET_KEY=""
DATABASE_URL="mysql+pymysql://$MYSQL_USER:$MYSQL_PASSWORD@mysql/$MYSQL_DATABASE"
NETWORK_NAME="microblog-net"
DB_VOLUME="microblog_db_data"
APP_VOLUME="microblog_app_data"
# Function to log messages
log() {
  echo "[INFO] $1"
}

log "Starting deployment process..."

log "Cleaning up ..."
# Clean Up Containers with its network
for container in $(docker ps -q --filter "network=$NETWORK_NAME"); do
  docker rm -f "$container"
done
docker network rm "$NETWORK_NAME"

log "Create docker network $NETWORK_NAME"
docker network create "$NETWORK_NAME"

# Log in to Docker Hub
# log "Logging into Docker Hub..."
# docker login -u "$DOCKER_USERNAME" || { echo "[ERROR] Docker login failed!"; exit 1; }

# Pull the production image from Docker Hub
log "Pulling Docker image: $DOCKER_USERNAME/$DOCKER_IMAGE:$DOCKER_TAG"
docker pull "$DOCKER_USERNAME/$DOCKER_IMAGE:$DOCKER_TAG"

if ! docker volume ls --format '{{.Name}}' | grep -w "$DB_VOLUME"; then
  log "Creating Volume $DB_VOLUME"

  docker volume create "$DB_VOLUME"
fi

if ! docker volume ls --format '{{.Name}}' | grep -w "$APP_VOLUME"; then
  log "Creating Volume $APP_VOLUME"

  docker volume create "$APP_VOLUME"
fi

docker run -d \
  --name "$MYSQL_CONTAINER_NAME" \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -e MYSQL_DATABASE="$MYSQL_DATABASE" \
  -e MYSQL_USER="$MYSQL_USER" \
  -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
  --network "$NETWORK_NAME" \
  -v "$DB_VOLUME:/var/lib/mysql" \
  mysql || { echo "[ERROR] MySQL container failed to start!"; exit 1; }

# Wait for MySQL to initialize
log "Waiting for MySQL to initialize (30 seconds)..."
sleep 30

# Run the production container
log "Starting application container..."
docker run -d \
  --name "$APP_CONTAINER_NAME" \
  --env SECRET_KEY="$SECRET_KEY" \
  --env DATABASE_URL="$DATABASE_URL" \
  -v "$APP_VOLUME:/home/microblog" \
  -p 8000:5000 \
  --network microblog-net \
  "$DOCKER_USERNAME/$DOCKER_IMAGE:$DOCKER_TAG" || { echo "[ERROR] App container failed to start!"; exit 1; }

# Confirm all containers are running
log "Checking running containers..."
docker ps

log "Deployment complete! Access the application at http://localhost:8000"
