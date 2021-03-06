
was originally going to use django 
to provide the REST framework for bofhbotD
but found it too heavyweight
switched to flask 

files in here was origin in the bofhbot/ repo

this is kept as historical note.
a good chunk of REST planning is kept in original bofhbot, as README_rest.rst
2019.0228




BOFHbot django
==============

This is a new version of bofhbot, using django to create a 
RESTful client/server based version of bofhbot.

the cli version is needing a very wide screen.  
more features would need more columns, can't really fit in terminal.

So, have it renderable in browser instead.

Each feature become a REST (microservice) call.
- which set of host responds to ssh
- which set of host responds to ping
- which set of host responds to ipmi

resunt will be in json format, the browser can render which ever column is needed.

potentially, can have a cli client that query the browser.

BOFHbot REST API 
----------------

early thought process:

hmm... maybe start with looking what slurm api provides, how it does sinfo -RSE
depending how it provide the result/format, maybe then make this API to follow that...

From a service provider perspective, maybe these are relevant
-------------------------------------------------------------

GET URI:

GET /api/v1/sinfo           # current output of bofhbot --color ??
GET /api/v1/group-list      # list cluster, but get info from pdsh groups


GET /api/v1/status-ping?g=sinfo     # special case, get nodelist from sinfo -RSE
GET /api/v1/status-ping?g=savio3    # group (cluster) = savio3 node ping status
GET /api/v1/status-ping?g=all       # ping status of all nodes  

GET /api/v1/status-ssh?g=sinfo     # special case, get nodelist from sinfo -RSE

# These will be exacutable if ssh is UP:
GET /api/v1/status-uptime?g=sinfo     # special case, get nodelist from sinfo -RSE
GET /api/v1/df?g=sinfo                       # df (for all)
GET /api/v1/df/tmp?g=sinfo                   # df for tmp only, implement as child?
	
consider as 
	GET status/ssh
	GET status/cmd/uptime
	GET status/cmd/df
	GET status/cmd/df/scratch
	

GET /api/v1/status-ipmi-reachable?g=sinfo   # whether responding to ipmi cmd
GET /api/v1/status-ipmi-state?g=sinfo       # query ipmi for whether power is on/off


GET /api/v1/hostinfo?h=n0000.savio3         # need this?  store info of sinfo -RSE of a given host, so that it can be rendered into output?  
        # but may want the microservice to query for this and provide into json, 
        # rather than client asking everynode one at a time...


POST URI:

POST(?) /api/v2/reboot?h=n0000.savio3           # action to reboot a node


From a client perspective, to be able to provide the job, need
--------------------------------------------------------------

GET URI:

GET /api/v1/status?groups=sinfo&checks=all
	# ie, get info for all nodes listed by sinfo -RSE, include status for all checks

GET /api/v1/status?groups=all&checks=ping,ssh,df_scratch,df_tmp,ipmi
	# ie, get info for all nodes in all group, listing status for ping, ssh, ipmi, df/scratch, df/tmp
	# df may benefit from parent/child URI ... 
	# even group may benefit from say savio2/n0292  or savio2/htc 



client task should be:

1. get list of node (determine whether sinfo -RSE, specific cluster/group
2. maybe query for list of possible checks (could be later)
3. check for desired item, sending list of clients.  eg checks/ssh checks/ping  (but how to provide client list?  using GET?  or POST method??)
4.  assmeble results, and present a view to user.


which way to pivot is a critical decision for the api..
client should be simple, for rendering, UI with user.
cuz web vs cli client, don't want to write code twice.
server can provide many diff GET URI that responds to diff queries.
again, think of SQL query placed as URI.

simpler approach
----------------

client:

GET /api/v1/status?groups=sinfo
	# server get all info it can find, return json
	# client can filter out columns it does not need
	# also means client handle json, so number of column may change
	# may need a way to get checklist which provide for all possible column headers...

	# but maybe there is simply json2table or json2html :P

	# groups is the only filter, changeable to clustername.
	# actually, checks=... could be an orthogonal filter, and server can skip certain checks if client dont care about them.
	# but basic of REST API is to resondo to GET /status 
	

future if each node becomes a link, then it can be a new REST call
/api/v1/status/nodeName
and it can potentially provide like history...  AI explanation of confidence... etc.


server can still provide the many GET URI at top.
but more likely just for use by itself (maybe not as REST? but the underlaying fn?
so each REST call shold be a wrapper to a fn call, 
there will be an API library then a REST wrapper on top of it.

whence many of the fn in bofhbot.py could likely be reused, 
they become the foundation API library.
eg generateSinfo, buildSinfoList, sinfoList2nodeList, checkSsh( node ), 
add checkSsh(list) + REST wrapper
and so forth.


http status codes
-----------------

200s = all good
200: OK
201: CREATE successful
204: DELETE successful

400s = error
405: Method not allowed


Django enabling feature
-----------------------

provide a IPMI power cycle button to reboot a node.
Req authentication in such case.  Maybe tap into OTP, maybe the MProxy that Globus use and create a x-hours token.
this way, if django server for bofhbot is running as root, 
intern can click on power cycle, prompted for password, and reboot.
the roles control would then be in django, not sudoers.  (do i want to read from sudoers?)

it should provide a very granual approach, severly limiting possible damage from mistake.

hmm, maybe have way to do tail -f and other stuff in REST 

* provide protection from SQL injection autoamtically
* 



Serverside setup for djang (run in each server)
===============================================

https://www.django-rest-framework.org/tutorial/quickstart/

module load python/3.6

virtualenv venv4bofhbot  # name of dir and prompt.  # brc
virtualenv --python=python3  venv4bofhbot  # in bofh, since def looks for python 2
source     venv4bofhbot/bin/activate
pip install django
pip install djangorestframework

( create django project and app from one-time code setup section below )

python manage.py migrate     # still fails in bofh  even when using py3 :(
	# sync db ... (??)
	# create a db.sqlite3 file, which is in .gitignore by github 


python manage.py runserver
	# this really start the server
	# settings.py def port: 8000




One-Time code setup (files added to git)
----------------------------------------

# create a project directory:
django-admin startproject botd .	# note the tailing dot
	# create 5 files:
	./manage.py
	botd/urls.py
	botd/wsgi.py
	botd/__init__.py
	botd/settings.py 		# specify port, def 8000

# create an app, inside the project dir to avoid namespace clash
cd botd
django-admin startapp quickstart	
	# ie the app name is "quickstart", may want to create a diff app name later on
	# add these files:
	botd/quickstart/tests.py
	botd/quickstart/migrations
	botd/quickstart/migrations/__init__.py
	botd/quickstart/admin.py
	botd/quickstart/apps.py
	botd/quickstart/models.py
	botd/quickstart/views.py
	botd/quickstart/__init__.py


Coding
------

botd/quickstart/
		serializers.py
		views.py
botd/
     urls.py	




TODO
====


AI
--

only nodes where deemed reboot is appropriate and likely good fix, only then would "ipmi cycle" button be presented/enabled.

other AI feature could come later as more logs are parsed.

the server arch also allow for monitoring sinfo -RSE, 
keep a history of what has been done to nodes, etc.
so that AI can give action recommendation 


Client
------

* web browser.  present result as html table.  can add jquery datatable for interactivity/softing.
	* this make easy to implement text-based client.
* ideally have a text base client that can allow output redirect to file, for annotation into logs.
* cli.  maybe can use lynx, elinks, maybe browsh 
* revamp bofhbot.py to have option to connect to django server and make REST calls and render result...


PS
--


could have done this as a separete github project/repo, but didn't want to create another project.  
the former bofhbot.py cli command would likely become a very separate/independent script, albeit with very similar goal in mind (which is why i kept everything in here).

actually, the server back end may be able to reuse a lot of the code that is in bofhbot.py.



