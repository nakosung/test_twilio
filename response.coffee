builder = require 'xmlbuilder'

module.exports = (prefix) ->
	->
		o = builder.create 'Response'
		closed = false
		xml = null
		fn = ->
			unless closed
				closed = true
				xml = o.end()
			xml
		fn.play = (s) ->
			o = o.e 'Play', [prefix,s+'.mp3'].join('/')
			o = o.up()
			fn
		fn.record = (action) ->
			obj = 
				maxLength : 20
				method : 'GET'
				action : [prefix,action].join('/')
				finishOnKey : '*'
			fn.play 'record'
			o = o.e 'Record', obj
			o = o.up()
			fn
		fn.input = (action) ->
			o = o.e 'Gather', timeout:10, method:'GET', finishOnKey:'*', action:[prefix,action].join('/'), numDigits:1
			fn.play action
			fn.play 'yn'
			o = o.up()
			fn
		fn
