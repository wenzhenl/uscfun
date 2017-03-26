# coding: utf-8

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

engine = Engine(app)

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
            body += ".\n此验证码将会在20分钟后失效，请尽快"
            body += "验证。\n如果你并没有注册USC日常，请忽略此邮件。\n"
            body += "\n\nUSC日常APP"
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
        raise LeanEngineError('没有提供邮箱地址')

@engine.define
def checkIfConfirmationCodeMatches(**params):
    return True

@engine.define
def receiveFeedback(**params):
    return True

@engine.before_save('Todo')
def before_todo_save(todo):
    content = todo.get('content')
    if not content:
        raise LeanEngineError('内容不能为空')
    if len(content) >= 240:
        todo.set('content', content[:240] + ' ...')
