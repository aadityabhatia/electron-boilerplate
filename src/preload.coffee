{remote, ipcRenderer} = require 'electron'

window.log = log =
	stdout: (message) => ipcRenderer.send 'stdout', message
	stderr: (message) => ipcRenderer.send 'stderr', message

window.reload = => remote.getCurrentWindow().reload()
