{remote, ipcRenderer} = require 'electron'

log =
	stdout: (message) => ipcRenderer.send 'stdout', message
	stderr: (message) => ipcRenderer.send 'stderr', message
	clear: => $('#log').empty()
	web: (message) => $('#log').append $('<div>').html message

log.stdout "It works!"

$ ->
	log.clear()
	log.web "It works!"
	$('#test').click => log.web "Success!"
	$('#reset').click => remote.getCurrentWindow().reload()
