gulp = require 'gulp'
coffee = require 'gulp-coffee'
pug = require 'gulp-pug'
uglify = require('gulp-uglify-es').default
asar = require 'asar'
chalk = require 'chalk'
fs = require 'fs'
log = require 'fancy-log'
path = require 'path'
pkginfo = require './package.json'
request = require 'request'
rimraf = require 'rimraf'
{spawn} = require 'child_process'

DIR_SRC = 'src'
DIR_OUT = 'out'
URL_JQUERY = "https://code.jquery.com/jquery-3.3.1.slim.min.js"
URL_BOOTSTRAP = "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"

gulp.task 'default', (done) ->
	console.log "\nThe following tasks are available:\n\n\t" +
		chalk.bold gulp.tree().nodes.join(', ') + "\n"
	done()

mkdir = (directory) ->
	if not fs.existsSync directory
		fs.mkdirSync directory
		log "created directory: #{directory}"

download = (url) ->
	name = path.basename url
	destination = path.join DIR_OUT, name
	new Promise (resolve) ->
		if fs.existsSync destination
			log chalk.bold.green "found: #{name}"
			return resolve()
		log "downloading: #{url}"
		request url, (error, response, body) ->
			if not error and response.statusCode is 200
				mkdir DIR_OUT
				fs.writeFileSync destination, body
				log chalk.bold.green "downloaded: #{name}"
				return resolve()
			else
				log.error chalk.bold.red "#{name} download failed: #{response.statusCode}"
				throw new Error "#{name} download failed: #{response.statusCode}"

gulp.task 'download', -> Promise.all [download URL_JQUERY, download URL_BOOTSTRAP]

buildPug = ->
	gulp.src path.join DIR_SRC, '*.pug'
		.pipe pug
			locals:
				DESCRIPTION: pkginfo.description
				JQUERY: path.basename URL_JQUERY
				BOOTSTRAP: path.basename URL_BOOTSTRAP
		.pipe gulp.dest DIR_OUT

gulp.task 'pug', buildPug

buildCoffeeUgly = ->
	gulp.src path.join DIR_SRC, '*.coffee'
		.pipe coffee()
		.pipe uglify()
		.pipe gulp.dest DIR_OUT

buildCoffeePretty = ->
	gulp.src path.join DIR_SRC, '*.coffee'
		.pipe coffee()
		.pipe gulp.dest DIR_OUT

gulp.task 'coffee', buildCoffeeUgly

gulp.task 'watch', ->
	gulp.watch path.join(DIR_SRC, '*.pug'), buildPug
	gulp.watch path.join(DIR_SRC, '*.coffee'), buildCoffeePretty

gulp.task 'clean', ->
	p1 = new Promise (resolve) -> rimraf DIR_OUT, resolve
	p2 = new Promise (resolve) -> rimraf 'app.asar', resolve
	Promise.all [p1, p2]

gulp.task 'modules', ->
	mkdir DIR_OUT
	fs.copyFileSync 'package.json', path.join DIR_OUT, 'package.json'
	child = spawn 'npm', ['install', '--production'], cwd: DIR_OUT
	child.stdout.on 'data', (data) => log chalk.gray "[npm] " + data.toString().trim()
	child.stderr.on 'data', (data) => log.error chalk.gray "[npm] " + chalk.bold.red data.toString().trim()
	child

gulp.task 'asar', ->
	new Promise (resolve) ->
		asar.createPackage DIR_OUT, 'app.asar', ->
			if not fs.existsSync 'app.asar'
				log.error chalk.bold.red "archive creation failed: app.asar"
				throw new Error "archive creation failed: app.asar"
			log chalk.bold.green "archive created: app.asar"
			resolve()

gulp.task 'build', gulp.parallel 'download', 'coffee', 'pug', 'modules'
gulp.task 'package', gulp.series 'clean', 'build', 'asar'
