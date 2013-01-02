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
	app.use express.bodyParser()
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
app.get "/resize/:width/:height/:image", (req, res) ->
	res.set('Content-Type', 'image/jpeg')
	gm(__dirname + "/static/images/" + req.params.image).resize(req.params.width, req.params.height).stream streamOut = (err, stdout, stderr) ->
		stdout.pipe res

server.listen expressPort
console.log "Express on port: " + expressPort