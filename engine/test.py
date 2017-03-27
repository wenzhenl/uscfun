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
instituion = "usc"
print "instituion:" + instituion
Conversation = leancloud.Object.extend('_Conversation')
query1 = Conversation.query
query2 = Conversation.query
query1.equal_to('name', instituion)
query2.equal_to('sys', True)
query = leancloud.Query.and_(query1, query2)
query_list = query.find()
if len(query_list) == 0:
    raise LeanEngineError('没有找到系统对话')
else:
    conversation = query_list[0]
    conversation_id = conversation.get('objectId')
    print "conversationId:" + conversation_id
    eventId = "some event"
    headers = {'Content-Type': 'application/json', \
        'X-LC-Id': "0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", \
        'X-LC-Key': '86bDxHaspqbCjqxWm53txUxb,master'}
    url = 'https://leancloud.cn/1.1/rtm/broadcast/subscriber'
    data = {"from_peer": "sys", \
            "message": "{\"_lctype\":-1,\"_lctext\":\"new event\", \
            \"_lcattrs\":{\"reason\": \"new\", \
            \"eventId\": \"" + eventId + "\"}}", \
             "conv_id": conversation_id}
    requests.post(url, data=json.dumps(data), headers=headers)

curl -X POST \
  -H "X-LC-Id: 0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz" \
  -H "X-LC-Key: 86bDxHaspqbCjqxWm53txUxb,master" \
  -H "Content-Type: application/json" \
  -d '{"from_peer": "1a", "message": "{\"_lctype\":-1,\"_lctext\":\"这是一个纯文本消息\",\"_lcattrs\":{\"a\":\"_lcattrs 是用来存储用户自定义的一些键值对\"}}", "conv_id": "58d86df5da2f600064f4bb43"}' \
  https://api.leancloud.cn/1.1/rtm/broadcast

  curl -X POST \
  -H "X-LC-Id: 0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz" \
  -H "X-LC-Key: 86bDxHaspqbCjqxWm53txUxb,master" \
  -H "Content-Type: application/json" \
  -d '{"from_peer": "1a", "message": "{\"_lctype\":-1,\"_lctext\":\"这是一个纯文本消息\",\"_lcattrs\":{\"a\":\"_lcattrs 是用来存储用户自定义的一些键值对\"}}", "conv_id": "58d86df5da2f600064f4bb43"}' \
  https://leancloud.cn/1.1/rtm/broadcast/subscriber

curl -X POST \
  -H "X-LC-Id: 0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz" \
  -H "X-LC-Key: 86bDxHaspqbCjqxWm53txUxb,master" \
  -H "Content-Type: application/json" \
  -d '{"conv_id": "58d86df5da2f600064f4bb43", "client_id": "fuck"}' \
  https://leancloud.cn/1.1/rtm/conversation/subscription
