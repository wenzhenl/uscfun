import leancloud

leancloud.init("pDLnf6MjL1vIgRw6b2WWWVCJ-MdYXbMMI", "zpbYwzEe5c6Cw4Ecmfr745C2")

leancloud.use_region('US')

TestObject = leancloud.Object.extend('TestObject')
test_object = TestObject()
test_object.set('words', "Hello World!")
test_object.save()
