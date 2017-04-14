# -*- coding: utf-8 -*-
__author__ = "Wenzheng Li"

import os

import sys
reload(sys)
sys.setdefaultencoding('utf-8')

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

APP_ID = os.environ['LEANCLOUD_APP_ID']
APP_KEY = os.environ['LEANCLOUD_APP_KEY']
MASTER_KEY = os.environ['LEANCLOUD_APP_MASTER_KEY']

admin = "wenzhenl_usc_edu"
# system notification type
### urgentMessage required
# snUrgentMessage = 0
### eventId required
snEventCreated = 1
### eventId required
snEventUpdated = 2
### newVersion required
### newVersionDescription
snNewVersionReleased = 3

conversation_url = "https://api.leancloud.cn/1.1/classes/_Conversation"
subscription_url = 'https://leancloud.cn/1.1/rtm/conversation/subscription'
subscriber_url = 'https://leancloud.cn/1.1/rtm/broadcast/subscriber'
messages_url = 'https://api.leancloud.cn/1.1/rtm/messages'

# conversation_url = "https://us-api.leancloud.cn/1.1/classes/_Conversation"
# subscription_url = 'https://leancloud.cn/1.1/rtm/conversation/subscription'
# subscriber_url = 'https://leancloud.cn/1.1/rtm/broadcast/subscriber'
# messages_url = 'https://us-api.leancloud.cn/1.1/rtm/messages'

engine = Engine(app)

@engine.define
def checkIfEmailIsTaken(**params):
    print 'check if email is taken starts'
    if 'email' in params:
        try:
            email = params['email']
            print "email: " + email
            query = Query('_User')
            query.equal_to('email', email)
            query_list = query.find()
            print('check if email is taken ends')
            if len(query_list) == 0:
                return False
            else:
                return True
        except Exception as e:
            print e
            print('check if email is taken ends')
            raise LeanEngineError('系统错误，无法查询邮箱是否占用')
    else:
        print "email cannot be empty"
        print('check if email is taken ends')
        raise LeanEngineError('没有提供邮箱地址')

@engine.define
def requestConfirmationCode(**params):
    print 'request confirmation code starts'
    if 'email' in params:
        try:
            fromaddr = "richangteam@gmail.com"
            toaddr = params['email']
            print "toaddr: " + toaddr
            password = "580230richang"

            code = ''.join(choice(digits) for i in xrange(6))
            print "code: " + code
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
            print 'request confirmation code ends'
            return True
        except Exception as e:
            print e
            print 'request confirmation code ends'
            raise LeanEngineError('发送验证码失败，请稍后重试')
    else:
        print "email cannot be empty"
        print 'request confirmation code ends'
        raise LeanEngineError('邮箱地址不能为空')

@engine.define
def checkIfConfirmationCodeMatches(**params):
    print "check if confirmation code matches starts"
    if 'email' in params and 'code' in params:
        try:
            email = params['email']
            print "email: " + email
            code = params['code']
            print "code: " + code
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
            print "check if confirmation code matches ends"

            if len(query_list) == 0:
                return False
            else:
                return True
        except Exception as e:
            print e
            print "check if confirmation code matches ends"
            raise LeanEngineError('系统错误：无法验证验证码')
    else:
        print "email and code cannot be empty"
        print "check if confirmation code matches ends"
        raise LeanEngineError('邮箱以及验证码都不能为空')

@engine.define
def createSystemConversationIfNotExists(**params):
    print "create system conversation if not exists starts"
    if 'email' in params:
        try:
            email = params['email']
            print "email:" + email
            suffix = email[email.find('@')+1:]
            print "suffix:" + suffix
            institution = suffix[:suffix.find('.')]
            print "institution:" + institution
            Conversation = Object.extend('_Conversation')
            query1 = Conversation.query
            query2 = Conversation.query
            query1.equal_to('name', institution)
            query2.equal_to('sys', True)
            query = Query.and_(query1, query2)
            query_list = query.find()
            if len(query_list) == 0:
                headers = {'Content-Type': 'application/json', \
                    'X-LC-Id': APP_ID, \
                    'X-LC-Key': APP_KEY}
                data = {"name": institution, \
                        "sys": True}
                requests.post(conversation_url, data=json.dumps(data), headers=headers)
            print "create system conversation if not exists ends"
            return True
        except Exception as e:
            print e
            print "create system conversation if not exists ends"
            raise LeanEngineError('创建系统对话失败，请稍后重试')
    else:
        print "email cannot be empty"
        print "create system conversation if not exists ends"
        raise LeanEngineError('邮箱不能为空')

@engine.define
def subscribeToSystemConversation(**params):
    print "subscribe to system conversation starts"
    if 'clientId' in params and 'institution' in params:
        try:
            client_id = params['clientId']
            print "clientId:" + client_id
            institution = params['institution']
            print "institution:" + institution
            Conversation = Object.extend('_Conversation')
            query1 = Conversation.query
            query2 = Conversation.query
            query1.equal_to('name', institution)
            query2.equal_to('sys', True)
            query = Query.and_(query1, query2)
            query_list = query.find()
            if len(query_list) == 0:
                raise LeanEngineError('没有找到系统对话')
            else:
                conversation = query_list[0]
                conversation_id = conversation.get('objectId')
                print "conversationId:" + conversation_id

                headers = {'Content-Type': 'application/json', \
                    'X-LC-Id': APP_ID, \
                    'X-LC-Key': MASTER_KEY + ',master'}
                data = {"conv_id": conversation_id, "client_id": client_id}
                requests.post(subscription_url, data=json.dumps(data), headers=headers)
            print "subscribe to system conversation ends"
            return True
        except Exception as e:
            print e
            print "subscribe to system conversation ends"
            raise LeanEngineError('订阅系统通知失败，请稍后重试')
    else:
        print "client id and institution must not be empty"
        print "subscribe to system conversation ends"
        raise LeanEngineError('client id and institution must be not empty')

@engine.define
def joinConversation(**params):
    print "join conversation starts"
    if 'clientId' in params and 'conversationId' in params:
        try:
            client_id = params['clientId']
            conversation_id = params['conversationId']
            query = Query("_Conversation")
            conversation = query.get(conversation_id)
            conversation.add_unique('m', client_id)
            conversation.save()
            print "join conversation ends"
            return True
        except Exception as e:
            print e
            print "join conversation ends"
            raise LeanEngineError('join conversation failed')
    else:
        print "client id and conversation id must not be empty"
        print "join conversation ends"
        raise LeanEngineError('join conversation failed')

@engine.define
def quitConversation(**params):
    print "quit conversation starts"
    if 'clientId' in params and 'conversationId' in params:
        try:
            client_id = params['clientId']
            conversation_id = params['conversationId']
            query = Query("_Conversation")
            conversation = query.get(conversation_id)
            conversation.remove('m', client_id)
            conversation.save()
            print "quit conversation ends"
            return True
        except Exception as e:
            print e
            print "quit conversation ends"
            raise LeanEngineError('quit conversation failed')
    else:
        print "client id and conversation id must not be empty"
        print "quit conversation ends"
        raise LeanEngineError('quit conversation failed')

@engine.define
def muteConversation(**params):
    print "mute conversation starts"
    if 'clientId' in params and 'conversationId' in params:
        try:
            client_id = params['clientId']
            conversation_id = params['conversationId']
            query = Query("_Conversation")
            conversation = query.get(conversation_id)
            conversation.add_unique('mu', client_id)
            conversation.save()
            print "mute conversation ends"
            return True
        except Exception as e:
            print e
            print "mute conversation ends"
            raise LeanEngineError('mute conversation failed')
    else:
        print "client id and conversation id must not be empty"
        print "mute conversation ends"
        raise LeanEngineError('mute conversation failed')

@engine.define
def unmuteConversation(**params):
    print "unmute conversation starts"
    if 'clientId' in params and 'conversationId' in params:
        try:
            client_id = params['clientId']
            conversation_id = params['conversationId']
            query = Query("_Conversation")
            conversation = query.get(conversation_id)
            conversation.remove('mu', client_id)
            conversation.save()
            print "unmute conversation ends"
            return True
        except Exception as e:
            print e
            print "unmute conversation ends"
            raise LeanEngineError('unmute conversation failed')
    else:
        print "client id and conversation id must not be empty"
        print "unmute conversation ends"
        raise LeanEngineError('unmute conversation failed')

@engine.define
def isMutedInConversation(**params):
    print "check if muted in conversation starts"
    if 'clientId' in params and 'conversationId' in params:
        try:
            client_id = params['clientId']
            conversation_id = params['conversationId']
            query = Query("_Conversation")
            conversation = query.get(conversation_id)
            muteMembers = conversation.get('mu')
            print "check if muted in conversation ends"
            return client_id in muteMembers
        except Exception as e:
            print e
            print "check if muted in conversation ends"
            raise LeanEngineError('check if muted in conversation failed')
    else:
        print "client id and conversation id must not be empty"
        print "check if muted in conversation ends"
        raise LeanEngineError('check if muted in conversation failed')

@engine.define
def fetchOverallRating(**params):
    print "fetch overall rating starts"
    return 2.5
    print "fetch overall rating ends"

@engine.after_save('_Conversation')
def after_conversation_save(conversation):
    print("after conversation save started")
    conversation_id = conversation.get('objectId')
    print "conversationId: " + conversation_id
    welcomeMessage = "大家对活动有任何疑问，欢迎在此讨论！【USC小管家】"
    headers = {'Content-Type': 'application/json', \
        'X-LC-Id': APP_ID, \
        'X-LC-Key': MASTER_KEY + ',master'}
    data = {"from_peer": admin, \
            "message": "{\"_lctype\":-1,\"_lctext\": \"" + welcomeMessage + "\", \
            \"_lcattrs\":{\"reason\": \"welcome\"}}", \
             "conv_id": conversation_id, "transient": False}
    requests.post(messages_url, data=json.dumps(data), headers=headers)

@engine.after_save('Event')
def after_event_save(event):
    print("after event save started")
    institution = event.get('institution')
    print "institution:" + institution
    Conversation = Object.extend('_Conversation')
    query1 = Conversation.query
    query2 = Conversation.query
    query1.equal_to('name', institution)
    query2.equal_to('sys', True)
    query = Query.and_(query1, query2)
    query_list = query.find()
    if len(query_list) == 0:
        raise LeanEngineError('没有找到系统对话')
    else:
        conversation = query_list[0]
        conversation_id = conversation.get('objectId')
        print "conversationId:" + conversation_id
        eventId = event.get('objectId')
        headers = {'Content-Type': 'application/json', \
            'X-LC-Id': APP_ID, \
            'X-LC-Key': MASTER_KEY + ',master'}
        data = {"from_peer": "sys", \
                "message": "{\"_lctype\":-1,\"_lctext\":\"eventCreated\", \
                \"_lcattrs\":{\"snType\":" + str(snEventCreated) + \
                ",\"eventId\": \"" + eventId + "\"}}", \
                 "conv_id": conversation_id}
        requests.post(subscriber_url, data=json.dumps(data), headers=headers)
    print("after event save ended")

@engine.after_update('Event')
def after_event_update(event):
    print("after event update called...")
    institution = event.get('institution')
    print "institution:" + institution
    Conversation = Object.extend('_Conversation')
    query1 = Conversation.query
    query2 = Conversation.query
    query1.equal_to('name', institution)
    query2.equal_to('sys', True)
    query = Query.and_(query1, query2)
    query_list = query.find()
    if len(query_list) == 0:
        raise LeanEngineError('没有找到系统对话')
    else:
        conversation = query_list[0]
        conversation_id = conversation.get('objectId')
        print "conversationId:" + conversation_id
        eventId = event.get('objectId')
        headers = {'Content-Type': 'application/json', \
            'X-LC-Id': APP_ID, \
            'X-LC-Key': MASTER_KEY + ',master'}
        data = {"from_peer": "sys", \
                "message": "{\"_lctype\":-1,\"_lctext\":\"eventUpdated\", \
                \"_lcattrs\":{\"snType\":" + str(snEventUpdated) + \
                ",\"eventId\": \"" + eventId + "\"}}", \
                 "conv_id": conversation_id}
        requests.post(subscriber_url, data=json.dumps(data), headers=headers)

@engine.define
def _receiversOffline(**params):
    print('_receiversOffline start')
    print(params)

    conversation_id = params['convId']
    query = Query("_Conversation")
    conversation = query.get(conversation_id)
    # if it is system notification skip
    if conversation.get('sys') == True:
        print "system notification, skip pushMessage"
        print('_receiversOffline end')
        return {
            'skip': True
        }
    else:
        from_peer = params['fromPeer']
        short_content = ""
        query = Query("_User")
        query.equal_to('username', from_peer)
        query_list = query.find()
        if len(query_list) > 0:
            short_content = query_list[0].get('nickname') + ": "

        content = params['content']
        mediaType = content[content.find('_lctype')+9:content.find('_lctype')+11]
        if mediaType == "-1":
            short_content += content[content.find('_lctext')+10:content.find('_lcattrs')-3]
        elif mediaType == "-2":
            short_content += "[图片]"
        elif mediaType == "-3":
            short_content += "[语音信息]"
        elif mediaType == "-4":
            short_content += "[视频信息]"
        elif mediaType == "-5":
            short_content += "[位置]"
        elif mediaType == "-6":
            short_content += "[文件]"
        print('short_content:', short_content)
        payloads = {
            # 自增未读消息的数目，不想自增就设为数字
            'badge': 'Increment',
            'sound': 'default',
            # 使用开发证书
            '_profile': 'dev',
            'alert': short_content,
        }
        print('_receiversOffline end')
        return {
            'pushMessage': json.dumps(payloads),
        }
