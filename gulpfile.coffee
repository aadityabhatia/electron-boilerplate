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

buildCss = =>
	gulp.src [PATH_BOOTSTRAP, PATH_BOOTSTRAP_MAP]
		.pipe gulp.dest DIR_OUT

buildPug = =>
	gulp.src path.join DIR_SRC, '*.pug'
		.pipe pug
			locals:
				BOOTSTRAP: path.basename PATH_BOOTSTRAP
		.pipe gulp.dest DIR_OUT

buildCoffeeUgly = =>
	gulp.src path.join DIR_SRC, '*.coffee'
		.pipe coffee()
		.pipe uglify()
		.pipe gulp.dest DIR_OUT

buildCoffeePretty = =>
	gulp.src path.join DIR_SRC, '*.coffee'
		.pipe coffee()
		.pipe gulp.dest DIR_OUT

watch = =>
	gulp.watch path.join(DIR_SRC, '*.pug'), buildPug
	gulp.watch path.join(DIR_SRC, '*.coffee'), buildCoffeePretty

deleteOutputDir = (done) =>
	fs.rmdir DIR_OUT, recursive: true, done

deletePackage = =>
	new Promise (resolve) => fs.unlink PACKAGE_OUT, resolve

clean = gulp.series deleteOutputDir, deletePackage

copyPackageJson = =>
	gulp.src ['package.json', 'package-lock.json']
		.pipe gulp.dest DIR_OUT

npmInstall = =>
	child = spawn 'npm', ['install', '--production'], cwd: DIR_OUT
	child.stdout.on 'data', (data) => log chalk.gray "[npm] " + data.toString().trim()
	child.stderr.on 'data', (data) => log.error chalk.gray "[npm] " + chalk.bold.red data.toString().trim()
	child

modules = gulp.series copyPackageJson, npmInstall

createPackage = =>
	new Promise (resolve) =>
		await asar.createPackage DIR_OUT, PACKAGE_OUT
		if not fs.existsSync PACKAGE_OUT
			log.error chalk.bold.red "package creation failed: #{PACKAGE_OUT}"
			throw new Error "package creation failed: #{PACKAGE_OUT}"
		log chalk.bold.green "package created: #{PACKAGE_OUT}"
		resolve()

build = gulp.parallel buildCss, buildCoffeeUgly, buildPug, modules

exports.css = buildCss
exports.coffee = buildCoffeePretty
exports.pug = buildPug
exports.watch = watch
exports.clean = clean
exports.modules = modules
exports.build = build
exports.package = gulp.series clean, build, createPackage
exports.default = (done) => console.log "\nThe following tasks are available:\n\n\t#{chalk.bold gulp.tree().nodes.join(', ')}\n"; done()
