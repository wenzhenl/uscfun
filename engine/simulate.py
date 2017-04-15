# -*- coding: utf8 -*-
__author__ = "Wenzheng Li"

import logging
logging.basicConfig(level=logging.DEBUG)

import leancloud
from app import app

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from string import digits
from random import choice

from datetime import datetime
import time
import requests

from random import choice

leancloud.init("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", "XRGhgA5IwbqTWzosKRh3nzRY")
Event = leancloud.Object.extend('Event')
queryUser = leancloud.Query('_User')
queryConv = leancloud.Query('_Conversation')
Conversation = leancloud.Object.extend('_Conversation')

flag = "1"
for i in xrange(2):
    point = leancloud.GeoPoint(39.9, 116.4)
    queryUser.exists('username')
    users = queryUser.find()
    creator = users[choice(range(0, len(users)))]
    name = flag + "test test test " + str(i)
    conversation = Conversation()
    conversation.set('name', name)
    conversation.set('m', [creator.get('username')])
    conversation.save()
    queryConv.equal_to('name', name)
    conversations = queryConv.find()
    event = Event()
    event.set('name', name)
    event.set('maximumAttendingPeople', 20)
    event.set('remainingSeats', 1)
    event.set('minimumAttendingPeople', 20)
    event.set('due', time.time() + 120.0)
    event.set('createdBy', creator)
    event.set('members', [creator])
    event.set('neededBy', [creator])
    event.set('conversation', conversations[0])
    event.set('isCancelled', False)
    event.set('institution', 'usc')
    event.set('startTime', time.time() + 3600*5)
    event.set('endTime', time.time() + 3600*10)
    event.set('location', "this is a place number " + str(i))
    event.set('whereCreated', point)
    event.set('note', "this is a quite short short note number " + str(i))
    event.save()
