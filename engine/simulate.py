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

leancloud.init("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", "XRGhgA5IwbqTWzosKRh3nzRY")
Event = leancloud.Object.extend('Event')
queryUser = leancloud.Query('_User')
queryConv = leancloud.Query('_Conversation')

for i in xrange(200):
    point = leancloud.GeoPoint(39.9, 116.4)
    creator = queryUser.get('58f07058a0bb9f006a89f511')
    conversation = queryConv.get('58f078d92f301e006cf2b656')
    event = Event()
    event.set('name', 'final test clean data when enter background' + str(i))
    event.set('maximumAttendingPeople', 20)
    event.set('remainingSeats', 1)
    event.set('minimumAttendingPeople', 20)
    event.set('due', time.time() + 1200.0)
    event.set('createdBy', creator)
    event.set('members', [creator])
    event.set('neededBy', [creator])
    event.set('conversation', conversation)
    event.set('isCancelled', False)
    event.set('institution', 'usc')
    event.set('startTime', time.time() + 3600*5)
    event.set('endTime', time.time() + 3600*10)
    event.set('location', "this is a place number " + str(i))
    event.set('whereCreated', point)
    event.set('note', "this is a quite short short note number " + str(i))
    event.save()
