Microblog
===================

CI Workflow Badge:
[![CI](https://github.com/axjo-asili/microblog/actions/workflows/continous-integration.yml/badge.svg)](https://github.com/axjo-asili/microblog/actions/workflows/continous-integration.yml)


[![Join the chat at https://gitter.im/dbwebb-se/devops](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dbwebb-se/devops?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Course material for a devops course, aimed at a Swedish course in computer science on University level new to devops. The students are to further develop this application and integreate it with new tools.

Released as part of a University course: https://dbwebb.se/kurser/devops

The application used in this course is based on [The flask mega tutorial](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world).




Dev environment
------------------

Here is how you setup the development environment and start the application.



### Packages

Create a virtual environment and install packages:
```
python3 -m venv venv
source venv/bin/activate
make install-dev
```

If you are on Windows and Cygwin you will probably have troubles installing the pip package `cryptography`. Common errors are missing `python.h`, `gcc`, `cffi` and `openssl`. 


### Database

Setup SQLite database if `migrations` folder already exist:
```
flask db upgrade
```

If you have upgraded the code for any SQLAlchemy models:
```
flask db migrate -m '<message>'
flask db upgrade
```

You probably won't need to do this. But if you need to recreate `app.db` and migrations folder:
```
flask db init
flask db migrate -m '<message>'
flask db upgrade
```

If you have the wrong migrations version in the database when you want to upgrade it you can change it with:
```
flask db stamp head
flask db upgrade
```



### Test application

There are several make commands for testing the application. Use `make help` to see which. To run all tests and validation use:
```
make test
```



### Run application

Start byt setting the FLASK_APP and FLASK_ENV env vars:
```
export FLASK_APP=microblog.py
export FLASK_ENV=development
```
Change to use the DevConfig in `microblog.py`, uncomment `# from app.config import DevConfig` and `# app = create_app(DevConfig)` (comment `app = create_app()`).

Start the app with the following command and go to `localhost:5000` in your browser.
```
flask run
```



Production environment
------------------

Follow the scripts in `scripts/` or [Driftsätta en flask app](https://dbwebb.se/kunskap/driftsatta-en-flask-app).



License
-------------------

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.



Acknowledgement
-------------------

This is a co-effort of several people using freely available documentation and tools from the open source community.

For contributors, see commit history and issues.

Feel free to help building up the repository with more content suited for training and education.
