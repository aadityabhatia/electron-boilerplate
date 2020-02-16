{log} = window

log.clear = => $('#log').empty()
log.web = (message) => $('#log').prepend $('<div>').text message

log.stdout "It works!"

$ ->
	log.clear()
	log.web "It works!"
	$('#test').click => log.web "Success!"
	$('#reset').click => window.reload()
