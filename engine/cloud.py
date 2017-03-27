# -*- coding: utf8 -*-
__author__ = "Wenzheng Li"

from leancloud import Engine
from leancloud import LeanEngineError
from leancloud import Object
from leancloud import Query
from app import app

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from string import digits
from random import choice

import datetime
import requests
import json

engine = Engine(app)

uscSystemConversationId = "58d5288eda2f600064f2c605"

@engine.define
def checkIfEmailIsTaken(**params):
    if 'email' in params:
        try:
            email = params['email']
            query = Query('_User')
            query.equal_to('email', email)
            query_list = query.find()
            if len(query_list) == 0:
                return False
            else:
                return True
        except Exception as e:
            print e
            raise LeanEngineError('系统错误，无法查询邮箱是否占用')
    else:
        raise LeanEngineError('没有提供邮箱地址')

@engine.define
def requestConfirmationCode(**params):
    if 'email' in params:
        try:
            fromaddr = "richangteam@gmail.com"
            toaddr = params['email']
            password = "580230richang"

            code = ''.join(choice(digits) for i in xrange(6))
            ConfirmationCode = Object.extend('ConfirmationCode')
            query = Query(ConfirmationCode)
            query.equal_to('email', toaddr)
            query_list = query.find()
            if len(query_list) > 0:
                concode = query_list[0]
                concode.set('code', code)
                concode.save()
            else:
                concode = ConfirmationCode()
                concode.set('email', toaddr)
                concode.set('code', code)
                concode.save()

            message = MIMEMultipart()
            message['From'] = fromaddr
            message['To'] = toaddr
            message['Subject'] = "【USC日常】你的注册验证码是 " + code
            body = ""
            body += "同学你好!\n\n你正在注册使用USC日常，你的验证码是 "
            body += code
            body += ".\n此验证码将会在20分钟后失效，请尽快验证。\n\n\n"
            body += "\n如果你并没有注册USC日常，请忽略此邮件。\n"
            body += "\n\nbest,"
            body += "\nUSC日常APP"
            message.attach(MIMEText(body, 'plain'))

            server = smtplib.SMTP('smtp.gmail.com', '587')
            server.ehlo()
            server.starttls()
            server.login(fromaddr, password)
            text = message.as_string()
            server.sendmail(fromaddr, toaddr, text)
            server.quit()
        except Exception as e:
            print e
            raise LeanEngineError('发送验证码失败，请稍后重试')
    else:
        raise LeanEngineError('邮箱地址不能为空')

@engine.define
def checkIfConfirmationCodeMatches(**params):
    if 'email' in params and 'code' in params:
        try:
            email = params['email']
            code = params['code']
            ConfirmationCode = Object.extend('ConfirmationCode')
            twentyMinutesAgo = datetime.datetime.now() - datetime.timedelta(minutes=20)
            print(twentyMinutesAgo)
            query1 = ConfirmationCode.query
            query2 = ConfirmationCode.query
            query3 = ConfirmationCode.query
            query1.equal_to('email', email)
            query2.equal_to('code', code)
            query3.greater_than_or_equal_to('updatedAt', twentyMinutesAgo)
            query12 = Query.and_(query1, query2)
            query = Query.and_(query12, query3)
            query_list = query.find()
            if len(query_list) == 0:
                return False
            else:
                return True
        except Exception as e:
            print e
            raise LeanEngineError('系统错误：无法验证验证码')
    else:
        raise LeanEngineError('邮箱已经验证码都不能为空')

@engine.define
def receiveFeedback(**params):
    if 'email' in params and 'feedback' in params:
        try:
            fromaddr = "richangteam@gmail.com"
            toaddr = "richangteam@gmail.com"
            password = "580230richang"

            email = params['email']
            print email
            feedback = params['feedback']
            print feedback

            message = MIMEMultipart()
            message['From'] = fromaddr
            message['To'] = toaddr
            message['Subject'] = "来自用户的反馈"

            message.attach(MIMEText(email.encode('utf-8'), 'plain', 'utf-8'))
            message.attach(MIMEText(feedback.encode('utf-8'), 'plain', 'utf-8'))

            server = smtplib.SMTP('smtp.gmail.com', '587')
            server.ehlo()
            server.starttls()
            server.login(fromaddr, password)
            text = message.as_string()
            server.sendmail(fromaddr, toaddr, text)
            server.quit()
        except Exception as e:
            print e
            raise LeanEngineError('发送反馈失败，请稍后重试')
    else:
        raise LeanEngineError('邮箱反馈都不能为空')

@engine.define
def createSystemConversationIfNotExists(**params):
    print "creating system conversation if not exists..."
    if 'email' in params:
        try:
            email = params['email']
            print "email:" + email
            suffix = email[email.find('@')+1:]
            print "suffix:" + suffix
            instituion = suffix[:suffix.find('.')]
            print "instituion:" + instituion
            Conversation = Object.extend('_Conversation')
            query1 = Conversation.query
            query2 = Conversation.query
            query1.equal_to('name', instituion)
            query2.equal_to('sys', True)
            query = Query.and_(query1, query2)
            query_list = query.find()
            if len(query_list) == 0:
                headers = {'Content-Type': 'application/json', \
                    'X-LC-Id': '0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz', \
                    'X-LC-Key': 'XRGhgA5IwbqTWzosKRh3nzRY'}
                url = "https://api.leancloud.cn/1.1/classes/_Conversation"
                data = {"name": instituion, \
                        "sys": True}
                requests.post(url, data=json.dumps(data), headers=headers)
        except Exception as e:
            print e
            raise LeanEngineError('创建系统对话失败，请稍后重试')
    else:
        raise LeanEngineError('邮箱不能为空')

@engine.before_save('_User')
def before_user_save(user):
    client_id = user.get('username') + "_system_notification"
    headers = {'Content-Type': 'application/json', \
        'X-LC-Id': '0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz', \
        'X-LC-Key': '86bDxHaspqbCjqxWm53txUxb,master'}
    url = 'https://leancloud.cn/1.1/rtm/broadcast/subscription'
    data = {"conv_id": uscSystemConversationId, "client_id": client_id}
    requests.post(url, data=json.dumps(data), headers=headers)

@engine.after_save('Event')
def after_event_save(event):
    eventId = event.get('objectId')
    headers = {'Content-Type': 'application/json', \
        'X-LC-Id': '0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz', \
        'X-LC-Key': '86bDxHaspqbCjqxWm53txUxb,master'}
    url = 'https://leancloud.cn/1.1/rtm/broadcast/subscriber'
    data = {"from_peer": "sys", \
            "message": "{\"_lctype\":-1,\"_lctext\":\"new event\", \
            \"_lcattrs\":{\"reason\": \"new\", \
            \"eventId\": \"" + eventId + "\"}}", \
             "conv_id": uscSystemConversationId}
    requests.post(url, data=json.dumps(data), headers=headers)

@engine.after_update('Event')
def after_event_update(event):
    eventId = event.get('objectId')
    headers = {'Content-Type': 'application/json', \
        'X-LC-Id': '0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz', \
        'X-LC-Key': '86bDxHaspqbCjqxWm53txUxb,master'}
    url = 'https://leancloud.cn/1.1/rtm/broadcast/subscriber'
    data = {"from_peer": "sys", \
            "message": "{\"_lctype\":-1,\"_lctext\":\"new event\", \
            \"_lcattrs\":{\"reason\": \"updated\", \
            \"eventId\": \"" + eventId + "\"}}", \
             "conv_id": uscSystemConversationId}
    requests.post(url, data=json.dumps(data), headers=headers)
