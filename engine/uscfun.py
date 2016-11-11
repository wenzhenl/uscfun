# -*- coding: utf8 -*-
__author__ = "Wenzheng Li"

from datetime import datetime
import schedule
import time
import requests
import json
import leancloud

def checkUpdate():
    print("checking updates...")
    global lastUpdatedAt
    Event = leancloud.Object.extend('Event')
    query = Event.query
    query.greater_than('updatedAt', lastUpdatedAt)
    query.select("objectId", "updatedAt")
    query.limit(1000)
    query.add_ascending('updatedAt')
    updated_list = query.find()
    updatedIds = []
    for event in updated_list:
        print(event.get('objectId'))
        print(event.get('updatedAt'))
        updatedIds.append(event.get('objectId'))
    if len(updated_list) > 0:
        lastUpdatedAt = updated_list[-1].get('updatedAt')
        print(lastUpdatedAt)
        headers = {'Content-Type': 'application/json', \
            'X-LC-Id': 'pDLnf6MjL1vIgRw6b2WWWVCJ-MdYXbMMI', \
            'X-LC-Key': 'D0WVYFeGPkXn9lue4AgM0WBa,master'}
        url = 'https://us.leancloud.cn/1.1/rtm/broadcast'
        data = {"from_peer": "sys", \
                "message": "{\"_lctype\":-1,\"_lctext\":\"系统通知，明天放假\", \
                \"_lcattrs\":{\"a\":\"_lcattrs 是用来存储用户自定义的一些键值对\"}}", \
                 "conv_id": "58251caf07cc140050a7ad48"}
        requests.post(url, data=json.dumps(data), headers=headers)
        print(url)

if __name__ == "__main__":
    print("start checking updates...")
    leancloud.init("pDLnf6MjL1vIgRw6b2WWWVCJ-MdYXbMMI", "zpbYwzEe5c6Cw4Ecmfr745C2")
    leancloud.use_region('US')
    lastUpdatedAt = datetime.utcfromtimestamp(0)
    schedule.every(5).seconds.do(checkUpdate)
    while 1:
        schedule.run_pending()
        time.sleep(1)
