app = require 'app'
BrowserWindow = require 'browser-window'
Menu = require 'menu'
dialog = require 'dialog'
ipc = require 'ipc'

Exporter = require './export'

fs = require 'fs'

mainWindow = null

app.on 'window-all-closed', ->
	app.quit()

app.on 'ready', ->
	menu = Menu.buildFromTemplate require './template'
	Menu.setApplicationMenu menu

	mainWindow = new BrowserWindow
		width: 1280
		height: 720
		resizeable: false

	mainWindow.loadUrl "file://#{__dirname}/../../index.html"

	# mainWindow.openDevTools()

	mainWindow.on 'closed', ->
		mainWindow = null

	ipc.on 'show:dialog', (event, arg) =>
		fName = dialog.showOpenDialog
			properties: [ 'openDirectory' ]

		if fName?
			event.sender.send 'dialog:reply', fName[0]

	ipc.on 'export', (event, arg) =>
		{directory, model} = arg
		console.log "exporting to directory: #{directory}, model: #{JSON.stringify model}"

		fs.lstat directory, (err, stats) ->
			if err?
				event.sender.send 'export:err', "Export path is not a valid directory"
			else if stats.isFile()
				event.sender.send 'export:err', "Export path is a file, please change it to a directory"
			else if stats.isDirectory()
				console.log "Valid Directory! Exporting"
				Exporter.export directory, model
