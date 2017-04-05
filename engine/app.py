# coding: utf-8

from datetime import datetime

from flask import Flask
from flask import render_template
from flask_sockets import Sockets

from views.todos import todos_view

from leancloud import Object
from leancloud import Query
from leancloud import LeanEngineError

from momentjs import momentjs

app = Flask(__name__)
# Set jinja template global
app.jinja_env.globals['momentjs'] = momentjs

sockets = Sockets(app)

# 动态路由
app.register_blueprint(todos_view, url_prefix='/todos')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/agreement')
def agreement():
    return render_template('agreement.html')

@app.route('/events/<id>')
def event(id):
    try:
        query = Query('Event')
        query.include('createdBy')
        query.include('members')
        event = query.get(id)
    except LeanEngineError as e:
        print(e)
        raise e
    return render_template('events.html', event=event)
