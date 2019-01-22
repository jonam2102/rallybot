
# $ gunicorn --bind 0.0.0.0:8080 gitlabr:api
import falcon
import io,json
from Naked.toolshed.shell import execute_rb
import re
import os
import datetime
import sys
import logging

Class GitlabPushHook(object):

 def __int__(self):
   logging.basicConfig()
   self.logger = logging.getLogger(_name_)
   self.out_hdlr = logging.StreamHandler(sys.stdout)
   self.out_hdlr.SetFormatter(logging.Formatter('%(asctime)s %(message)s'))
   self.out_hdlr.SetLevel(Logging.INFO)
   self.logger.addHandler(self.out_hdlr)
   self.logger.SetLevel(Logging.INFO)


   def Remove(self,duplicate):
   	final_list = []
   	for num in duplicate:
   		if num not in final_list: 
   			final_list.append(num)
    return final_list


   def findRally(self, patter,filename)
     find_list = []
     jsonfile = open(filename,"r")
     find_list = re.findall(pattern,jsonfile.read())
     return find_list

   def on_post(self, req,resp)

     self.logger.info("Event:%s" , req.get_header('X-Gitlab-Event'))
     event = req.media

     fmt = '%Y%m%d%H%M%S'
     now = datetime.datetime.now().strftime(fmt)
     suffix = '.json'
     filename = 'git' + now + suffix

     self.logger.info("git json file sent : %s", filename)

     with io.open(filename, 'w', encoding='uft8') as outfile: 
     	str_ - json.dumps(event,
     		              indent=4, sort_keys = True,
     		              ensure_ascii = False)
     	outfile.write(str_)

     	userstory= self.findRally(r'#US[\w]+',filename)
     	userstory = self.Remove(userstory)
     	userstorysize = len(userstory)


     	defects= self.findRally(r'#DE[\w]+',filename)
     	defects = self.Remove(defects)
     	defectsize = len(defects)


     	tasks= self.findRally(r'#TA[\w]+',filename)
     	tasks = self.Remove(tasks)
     	tasksize = len(tasks)



     self.logger.info("number of user stories : %s", userstorysize)

     if userstorysize == 0 : 

     	self.logger.info("no User story provided by user in this event ")

     else: 

     	for word in userstory: 

     		self.logger.info("Running for :%s" , word[1:])
     		argument = word[1:] + ' ' + filename
     		success = execute_rb('01-connect-to-rally.rb', argument)
     		self.logger.info("Framework ran for user stories %s" , success)


     if defectsize == 0 : 

     	self.logger.info("no defects provided by user in this event ")

     else: 

     	for word in defects: 

     		self.logger.info("Running for :%s" , word[1:])
     		argument = word[1:] + ' ' + filename
     		success = execute_rb('01-connect-to-rally.rb', argument)
     		self.logger.info("Framework ran for  defects %s" , success)



     if tasksize == 0 : 

     	self.logger.info("no tasks provided by user in this event ")

     else: 

     	for word in tasks: 

     		self.logger.info("Running for :%s" , word[1:])
     		argument = word[1:] + ' ' + filename
     		success = execute_rb('01-connect-to-rally.rb', argument)
     		self.logger.info("Framework ran for tasks  %s" , success)

api = falcon.API()
api.add_route('/push',GitlabPushHook())
