#ports to listen on
expressPort = 8090

#require jade
jade = require("jade")

#require stylus
stylus = require("stylus")
nib = require("nib")

#require coffeescript
coffeeScript = require("coffee-script")
connectCoffeescript = require("connect-coffee-script")

#require gm
fs = require('fs')
gm = require("gm")

#readdirp for recursive file stuffs
readdirp = require('readdirp')

#start express
express = require("express")
app = express()
http = require("http")
server = http.createServer(app)
sio = require("socket.io")
io = sio.listen(server)

#set socket.io log level 1-3
io.set "log level", 1
io.enable "browser client minification"
io.enable "browser client gzip"
io.enable "browser client etag"
console.log "Running server in mode: " + app.settings.env

#Configuration (Express)
app.configure ->
	app.use express.compress()
	app.set "views", __dirname + "/views"
	app.set "view engine", "jade"
	app.use express.bodyParser(uploadDir: __dirname + "/static")
	app.use stylus.middleware(
		src: __dirname + "/views" # .styl files are located in `views/css`
		dest: __dirname + "/static" # .styl resources are compiled `static/css/*.css`
		compile: (str, path) -> # optional, but recommended
			stylus(str).set("filename", path).set("compress", true).use(nib())
	)
	app.use connectCoffeescript(
		src: __dirname + "/views" # .coffee files are located in `views/js`
		dest: __dirname + "/static" # .coffee resources are compiled `static/js/*.js`
		compile: (str, options) -> # optional, but recommended
			options.bare = true
			coffeeScript.compile(str, options)
	)
	app.use express.static(__dirname + "/static")
	app.use app.router


#Routes
app.get "/", (req, res) ->
	res.render "index.jade"
app.get "/:command/:width/:height/:image(*)", (req, res) ->
	res.set('Content-Type', 'image/jpeg')
	gm(__dirname + "/static/images/" + req.params.image).size (err, size) ->
		if size
			ratioW = size.width/req.params.width
			ratioH = size.height/req.params.height
			ratio = 0.0
			posX = 0
			posY = 0
			if ratioW > ratioH
				ratio = ratioH
				posX = (size.width-(req.params.width*ratio))/2
			else
				ratio = ratioW
				posY = (size.height-(req.params.height*ratio))/2
			if req.params.command == "crop"
				gm(__dirname + "/static/images/" + req.params.image)
					.crop(req.params.width*ratio, req.params.height*ratio, posX, posY)
					.resize(req.params.width, req.params.height)
					.stream streamOut = (err, stdout, stderr) ->
						stdout.pipe res
			else if req.params.command == "resize"
				if ratioW < 1.0 && ratioH < 1.0
					gm(__dirname + "/static/images/" + req.params.image)
						.stream streamOut = (err, stdout, stderr) ->
							stdout.pipe res
				else
					gm(__dirname + "/static/images/" + req.params.image)
						.resize(req.params.width, req.params.height)
						.stream streamOut = (err, stdout, stderr) ->
							stdout.pipe res

app.post "/file-upload", (req, res) ->
  tmp_path = req.files.thumbnail.path # get the temporary location of the file
  target_path = __dirname + "/static/images/" + req.files.thumbnail.name # set where the file should actually exists - in this case it is in the "images" directory
  fs.rename tmp_path, target_path, (err) -> # move the file from the temporary location to the intended location
    throw err  if err
    fs.unlink tmp_path, -> # delete the temporary file, so that the explicitly set temporary upload dir does not get filled with unwanted files
      throw err  if err
      res.send "File uploaded to: " + target_path + " - " + req.files.thumbnail.size + " bytes"

io.sockets.on "connection", (socket) ->
	socket.on "getImageList", (data) ->
		readdirp(
			root: __dirname + "/static/images"
		).on "data", (entry) ->
			socket.emit "sendImage",
				name: entry.name
				path: entry.path

server.listen expressPort
console.log "Express on port: " + expressPort