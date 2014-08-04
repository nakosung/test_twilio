gulp = require 'gulp'
fs = require 'fs'
async = require 'async'
nodemon = require 'gulp-nodemon'
{exec} = require 'child_process'
yaml = require 'js-yaml'
_ = require 'lodash'

speak = (text,mp3,next) ->
	tts = (text) -> "http://translate.google.com/translate_tts?ie=UTF-8&tl=ko&q=#{encodeURIComponent(text)}"
	exec "wget -q -U Mozilla -O #{mp3} \"#{tts(text)}\"", {}, next

gulp.task 'folder', (done) -> (require 'mkdirp') 'public', done
gulp.task 'tts', ['folder'], (done) ->
	TTS = yaml.safeLoad(fs.readFileSync('./tts.yml', 'utf8'));
	jobs = _.pairs(TTS).map (kv) ->
		(next) -> speak kv[1], "public/#{kv[0]}.mp3", next
	async.parallel jobs, done
gulp.task 'default', ['tts'], ->
	nodemon
		script : 'app.coffee'
		ext : 'coffee'

