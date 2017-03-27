# -*- coding: utf8 -*-
__author__ = "Wenzheng Li"


import leancloud
from app import app

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from string import digits
from random import choice

import datetime
import requests
import json

leancloud.init("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", "XRGhgA5IwbqTWzosKRh3nzRY")
email = "wenzhenl@usc.edu"
print "email:" + email
suffix = email[email.find('@')+1:]
print "suffix:" + suffix
instituion = suffix[:suffix.find('.')]
print "instituion:" + instituion
Conversation = leancloud.Object.extend('_Conversation')
query1 = Conversation.query
query2 = Conversation.query
query1.equal_to('name', instituion)
query2.equal_to('sys', True)
query = leancloud.Query.and_(query1, query2)
query_list = query.find()
if len(query_list) == 0:
    headers = {'Content-Type': 'application/json', \
        'X-LC-Id': '0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz', \
        'X-LC-Key': 'XRGhgA5IwbqTWzosKRh3nzRY'}
    url = "https://api.leancloud.cn/1.1/classes/_Conversation"
    data = {"name": instituion, \
            "sys": True}
    requests.post(url, data=json.dumps(data), headers=headers)
