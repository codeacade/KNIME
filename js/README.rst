
JavaScript
==========

took a class on jQuery, dealt thw AJAX, UI, etc.
maybe see the code folder in dropbox.

There was also the taxonomy reporter html page that called jQuery to provide some basic sorting and highligiting to tables, client side code so just need to access the html.

Node.js
=======

server-side JS (instead of client-side).

server is Node.js. 
Can add plugin (library) via npm.
event based, not multi-threaded, but can fork children.
said to be fast, so long as don't do a lot of work in each event, then serve large number of requests.


npm
===

- package manager for js.
- lots of js packages out there.

- run as user, not as root, as it add js library to an existing project
- js on client side?  or need server support???

- npm can install packages locally (eg by user for a project) or globally (ie system-wide by root)
- sudo npm  back in version 5.7.1 changed ownership of system files and broke the OS!!  There may not be a lot of reason why package need to be installed globally... 

- npm look at package.json and install all dependencies listed in it.
- package-lock.json list exact version of package use to prevent changing version.


- this may help understand better about npm: 
  https://www.npmjs.com/package/express


- kinda descent intro to npm
  https://webpack.js.org/guides/getting-started/
  i guess it install package locally, need a web server to serve them.
  but js still run client-side on browser, just that js not loaded via public url but served from my server?

- may want to start with this node.js intro
  https://codeburst.io/the-only-nodejs-introduction-youll-ever-need-d969a47ef219

        - JS is single threaded.  Node.js is a single threaded forever loop listing for event, then dispatching them to worker.  creates a registry for callbacks.  Once call back is received, response is send.
        This could be client- or server-side js... hmm....
        - Node.js, being single threaded, not good at things that runs a long time and takes lots of cpu.


first setup for a project:

.. code:: bash

        npm init                # creates a barebone package.json

        npm install upper-case --save	# --save will update package.json


will create a folder called node_module in current dir

will update package.json, which list all requirements.  the file must exist first.


should not need to check the files installed by npm under nodes_modules into git
as package.json will add them automatically as dependencies upon new execution (including get new version).


Plugin from Mapbox
------------------

presumably they are js that use import
but have not been able to figure out how to get them to work.

ZWEDC_50x50sq+Plugin.html was the main place I tried, 
pairing it up locally, with npm module that was checked into github, 
serving things via nodejs, 
none of the thing worked yet.

so, forked the documentation/example 
https://tin6150.github.io/mapbox-gl-controls
and try from there.


Ref
---

* https://tin6150.github.io/psg/javascript.html
  Quick output

