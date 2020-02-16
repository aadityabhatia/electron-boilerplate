{app, BrowserWindow, ipcMain} = require 'electron'
path = require 'path'
url = require 'url'

window = null
app.allowRendererProcessReuse = true # this is to prevent deprecation warning

if not app.requestSingleInstanceLock()
	app.quit()

app.on 'second-instance', =>
	if window
		window.restore()
		window.focus()

app.whenReady().then =>
	window = new BrowserWindow
		title: app.name
		autoHideMenuBar: true
		show: false
		webPreferences:
			preload: path.join app.getAppPath(), 'preload.js'

	window.loadFile path.join app.getAppPath(), 'index.html'

	window.once 'closed', => app.quit()
	window.once 'ready-to-show', => window.show()

ipcMain.on 'stdout', (event, message) => console.log message
ipcMain.on 'stderr', (event, message) => console.error message
