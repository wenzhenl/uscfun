from datetime import datetime
import schedule
import time
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
    for event in updated_list:
        print(event.get('objectId'))
        print(event.get('updatedAt'))
    if len(updated_list) > 0:
        lastUpdatedAt = updated_list[-1].get('updatedAt')
        print(lastUpdatedAt)

if __name__ == "__main__":
    leancloud.init("pDLnf6MjL1vIgRw6b2WWWVCJ-MdYXbMMI", "zpbYwzEe5c6Cw4Ecmfr745C2")
    leancloud.use_region('US')
    lastUpdatedAt = datetime.utcfromtimestamp(0)
    schedule.every(30).seconds.do(checkUpdate)
    while 1:
        schedule.run_pending()
        time.sleep(1)
