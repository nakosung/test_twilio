express = require 'express'
app = express()
builder = require 'xmlbuilder'
path = require 'path'
_ = require 'lodash'
yaml = require 'js-yaml'
fs = require 'fs'
{prefix,twilio} = yaml.safeLoad(fs.readFileSync('./conf.yml', 'utf8'))
client = require('twilio')(twilio.sid, twilio.authToken)

R = (require './response')(prefix)

responses = yaml.safeLoad fs.readFileSync('./responses.yml', 'utf8')

conv_array = (v) ->
	_r = R()
	v.forEach (a) ->
		a = _.pairs(a)[0]
		_r = _r[a[0]] a[1]
	_r

conv_obj = (v) ->
	_r = {}
	for kk,vv of v
		_r[kk] = conv(vv)
	_r

conv = (v) ->
	if _.isArray(v) then conv_array(v) else conv_obj(v)

menu = {}
responses.forEach (rr) ->
	[k,v] = _.pairs(rr)[0]
	menu[k] = conv(v)

send = (R) ->
	L = {}
	_default = R() if _.isFunction R
	unless _default?
		xml = {}
		for k,v of R
			L[k] = v()
		_default = L.default
	(req,res,next) ->
		res.set 'Content-Type', 'text/xml'
		if req.query.RecordingUrl?
			console.log 'got recording', decodeURIComponent(req.query.RecodingUrl)
		digit = L[req.query.Digits] if req.query.Digits?
		res.send digit or _default
for k,v of menu
	do (k,v) -> app.get "/#{k}", send v

dial = (req,res,next) ->
	call = _.extend
		to: "+82"+req.query.to,
		method: "GET",
		fallbackMethod: "GET",
		statusCallbackMethod: "GET",
		record: "false"
		twilio.call
	client.calls.create call, next
app.post '/dial', dial, (req,res) ->
	res.send "OK"
	res.end()
app.use express.static path.join __dirname, 'public'
app.listen 80

