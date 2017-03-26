# coding: utf-8

from leancloud import Engine
from leancloud import LeanEngineError

from app import app

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from string import digits
from random import choice

engine = Engine(app)

@engine.define
def requestConfirmationCode(**params):
    if 'email' in params:
        fromaddr = "richangteam@gmail.com"
        toaddr = params['email']
        password = "580230richang"

        code = ''.join(choice(digits) for i in xrange(6))

        message = MIMEMultipart()
        message['From'] = fromaddr
        message['To'] = toaddr
        message['Subject'] = "【USC日常】你的注册验证码是 " + code
        body = ""
        body += "同学你好!\n\n你正在注册使用USC日常，你的验证码是 "
        body += code
        body += ".\n此验证码将会在20分钟后失效，请尽快"
        "验证。\n如果你并没有注册USC日常，请忽略此邮件。\n"
        "\n\nUSC日常APP"
        message.attach(MIMEText(body, 'plain'))

        try:
            server = smtplib.SMTP('smtp.gmail.com', '587')
            server.ehlo()
            server.starttls()
            server.login(fromaddr, password)
            text = message.as_string()
            server.sendmail(fromaddr, toaddr, text)
            server.quit()
        except:
            raise LeanEngineError('发送验证码失败，请稍后重试')
    else:
        raise LeanEngineError('没有提供邮箱地址')

@engine.define
def hello(**params):
    if 'name' in params:
        return 'Hello, {}!'.format(params['name'])
    else:
        return 'Hello, LeanCloud!'


@engine.before_save('Todo')
def before_todo_save(todo):
    content = todo.get('content')
    if not content:
        raise LeanEngineError('内容不能为空')
    if len(content) >= 240:
        todo.set('content', content[:240] + ' ...')
