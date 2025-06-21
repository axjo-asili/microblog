#!/bin/bash

# Exit on errors
set -e

# Configuration Variables
DOCKER_USERNAME="axjo21"
DOCKER_IMAGE="microblog-prod"
DOCKER_TAG="latest"
MYSQL_CONTAINER_NAME="mysql"
APP_CONTAINER_NAME="microblog-server"
MYSQL_DATABASE="microblog"
MYSQL_USER="microblog"
MYSQL_PASSWORD="heejheeej"
SECRET_KEY="its_a_secret"
DATABASE_URL="mysql+pymysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_CONTAINER_NAME/$MYSQL_DATABASE"
NETWORK_NAME="microblog-net"
DB_VOLUME="microblog_db_data"
APP_VOLUME="/"
MYSQL_PORT="3306"

# Function to log messages
log() {
  echo "[INFO] $1"
}

# Function to check if the MySQL server is ready to accept connections
wait_for_mysql() {
  log "Waiting for MySQL to be ready..."
  while ! docker exec "$MYSQL_CONTAINER_NAME" mysqladmin -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" ping --silent; do
    sleep 2
  done
  log "MySQL is ready!"
}

log "Starting deployment process..."

# Clean Up Containers with its network
log "Cleaning up ..."

# Remove existing containers and volumes if they exist
docker rm -f "$MYSQL_CONTAINER_NAME" "$APP_CONTAINER_NAME" || true
docker volume rm "$DB_VOLUME" || true
docker network rm "$NETWORK_NAME" || true

# Create docker network
log "Creating Docker network $NETWORK_NAME"
docker network create "$NETWORK_NAME" || { echo "[ERROR] Docker network creation failed!"; exit 1; }

# Pull the production image from Docker Hub
log "Pulling Docker image: $DOCKER_USERNAME/$DOCKER_IMAGE:$DOCKER_TAG"
docker pull "$DOCKER_USERNAME/$DOCKER_IMAGE:$DOCKER_TAG"

# Create MySQL Volume if it doesn't exist
if ! docker volume ls --format '{{.Name}}' | grep -w "$DB_VOLUME"; then
  log "Creating volume $DB_VOLUME"
  docker volume create "$DB_VOLUME"
fi

# Run the MySQL container
log "Starting MySQL container..."
docker run -d \
  --name "$MYSQL_CONTAINER_NAME" \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -e MYSQL_DATABASE="$MYSQL_DATABASE" \
  -e MYSQL_USER="$MYSQL_USER" \
  -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
  --network "$NETWORK_NAME" \
  -v "$DB_VOLUME:/var/lib/mysql" \
  mysql:latest || { echo "[ERROR] MySQL container failed to start!"; exit 1; }

# Wait for MySQL to initialize and be ready for connections
wait_for_mysql

# Run the production app container
log "Starting application container..."
docker run -d \
  --name "$APP_CONTAINER_NAME" \
  --env SECRET_KEY="$SECRET_KEY" \
  --env DATABASE_URL="$DATABASE_URL" \
  -v "$APP_VOLUME:/app" \
  -p 8000:5000 \
  --network "$NETWORK_NAME" \
  "$DOCKER_USERNAME/$DOCKER_IMAGE:$DOCKER_TAG" || { echo "[ERROR] App container failed to start!"; exit 1; }

# Confirm all containers are running
log "Checking running containers..."
docker ps

log "Deployment complete! Access the application at http://localhost:8000"
