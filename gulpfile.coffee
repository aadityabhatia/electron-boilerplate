gulp = require 'gulp'
coffee = require 'gulp-coffee'
pug = require 'gulp-pug'
uglify = require('gulp-uglify-es').default
asar = require 'asar'
chalk = require 'chalk'
fs = require 'fs'
log = require 'fancy-log'
path = require 'path'
{spawn} = require 'child_process'

DIR_SRC = 'src'
DIR_OUT = 'out'
PACKAGE_OUT = 'app.asar'

PATH_BOOTSTRAP = 'node_modules/bootstrap/dist/css/bootstrap.css'
PATH_BOOTSTRAP_MAP = 'node_modules/bootstrap/dist/css/bootstrap.css.map'

gulp.task 'default', (done) ->
	console.log "\nThe following tasks are available:\n\n\t" +
		chalk.bold gulp.tree().nodes.join(', ') + "\n"
	done()

mkdir = (directory) ->
	if not fs.existsSync directory
		fs.mkdirSync directory
		log "created directory: #{directory}"

getBootstrap = ->
	gulp.src [PATH_BOOTSTRAP, PATH_BOOTSTRAP_MAP]
		.pipe gulp.dest DIR_OUT

gulp.task 'css', getBootstrap

buildPug = ->
	gulp.src path.join DIR_SRC, '*.pug'
		.pipe pug
			locals:
				BOOTSTRAP: path.basename PATH_BOOTSTRAP
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
	p1 = new Promise (resolve) -> fs.rmdir DIR_OUT, recursive: true, resolve
	p2 = new Promise (resolve) -> fs.unlink PACKAGE_OUT, resolve
	Promise.all [p1, p2]

gulp.task 'modules', ->
	mkdir DIR_OUT
	gulp.src ['package.json', 'package-lock.json']
		.pipe gulp.dest DIR_OUT
	child = spawn 'npm', ['install', '--production'], cwd: DIR_OUT
	child.stdout.on 'data', (data) => log chalk.gray "[npm] " + data.toString().trim()
	child.stderr.on 'data', (data) => log.error chalk.gray "[npm] " + chalk.bold.red data.toString().trim()
	child

gulp.task 'asar', ->
	new Promise (resolve) ->
		await asar.createPackage DIR_OUT, PACKAGE_OUT
		if not fs.existsSync PACKAGE_OUT
			log.error chalk.bold.red "archive creation failed: app.asar"
			throw new Error "archive creation failed: app.asar"
		log chalk.bold.green "archive created: app.asar"
		resolve()

gulp.task 'build', gulp.parallel 'css', 'coffee', 'pug', 'modules'
gulp.task 'package', gulp.series 'clean', 'build', 'asar'
