{app, BrowserWindow, ipcMain} = require 'electron'
path = require 'path'
url = require 'url'

app.on 'ready', ->
	win = new BrowserWindow()
	win.setMenu(null)

	win.loadURL url.format
		pathname: path.join(__dirname, 'index.html')
		protocol: 'file:'
		slashes: true

	win.on 'closed', -> app.quit()

app.on 'window-all-closed', -> app.quit()

ipcMain.on 'stdout', (event, message) => console.log message
ipcMain.on 'stderr', (event, message) => console.error message
