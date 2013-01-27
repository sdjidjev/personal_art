socket = io.connect('/')

jQuery(document).ready ($) ->

	numToLoad = 25
	images = []

	time = 0
	lastcall = -1

	gridSize = 250
	gridMargin = 2
	shapes = [
				{width: gridSize*2-gridMargin*2, height: gridSize*2-gridMargin*2, p: 5}
				{width: gridSize-gridMargin*2, height: gridSize*2-gridMargin*2, p: 10},
				{width: gridSize*2-gridMargin*2, height: gridSize-gridMargin*2, p: 10},
				{width: gridSize-gridMargin*2, height: gridSize-gridMargin*2, p: 40},
				{width: gridSize*3-gridMargin*2, height: gridSize-gridMargin*2, p: 0},
				{width: gridSize-gridMargin*2, height: gridSize*3-gridMargin*2, p: 0},
				{width: gridSize*3-gridMargin*2, height: gridSize*2-gridMargin*2, p: 0},
				{width: gridSize*2-gridMargin*2, height: gridSize*3-gridMargin*2, p: 0},
				{width: gridSize*3-gridMargin*2, height: gridSize*3-gridMargin*2, p: 0}
			]

	$container = $("#artContainer")

	getRandomInt = (min, max) ->
		Math.floor(Math.random() * (max - min + 1)) + min

	resizeOverlayImage = () ->
		width = $("#overlayPic").width()
		height = $("#overlayPic").height()
		$("#overlayPic").css("margin-left", ($(window).width()-width)/2)
		$("#overlayPic").css("margin-top", ($(window).height()-height)/2)

	overlayImage = (img) ->
		sizeRatio = 0.8
		$("#overlayPic").attr("src", "/resize/"+parseInt($(window).width()*sizeRatio)+"/"+parseInt($(window).height()*sizeRatio)+"/"+img)
		$("#overlay").waitForImages ->
			$("#overlay").fadeIn(500)
			resizeOverlayImage()

	overlayImageOff = () ->
		$("#overlay").fadeOut(500)

	refreshMasonry = () ->
		$container.masonry(
			itemSelector: ".box"
			columnWidth: gridSize
			isAnimated: !Modernizr.csstransitions
		)

	addImage = (width, height, path) ->
		box = $("<img class='box' onclick='overlayImage(\""+path+"\")' src='/crop/"+width+"/"+height+"/"+path+"'>");
		$container
			.append(box)
			.masonry("appended", box, true)
		box.load ->
			box.css
				opacity: 1.0
			# , 500, ->
			# 	console.log "image loaded"
				# refreshMasonry()

	intervalID = setInterval(->
		time += 500
	, 500)

	nearBottom = () ->
		console.log 'herp'
		loopArray = []
		if images.length > 0
			if images.length > numToLoad
				loopArray = images.slice(0,numToLoad)
				images.splice(0, numToLoad)
			else
				loopArray = images.slice(0)
				images = []
			i = 0
			console.log loopArray
			console.log images
			while i < loopArray.length
				addImage(loopArray[i].width, loopArray[i].height, loopArray[i].path)
				i++
			# refreshMasonry()

	randomShape = () ->
		totalp = 0
		i = 0
		while i < shapes.length
			totalp += shapes[i].p
			i++
		num = getRandomInt(0,totalp)
		tempp = 0
		j = 0
		while j < shapes.length
			tempp += shapes[j].p
			if num <= tempp
				return shapes[j]
			j++

	totalImages = 0

	$("#overlayPic").on "click", (event) ->
		overlayImageOff()
	$(window).resize ->
		resizeOverlayImage()
	$(document).keyup (e) ->
		overlayImageOff() if e.keyCode is 27
	socket.on "sendImage", (data) ->
		size = randomShape()
		width = size.width
		height = size.height
		if totalImages < numToLoad
			addImage(width, height, data.path)
			# refreshMasonry()
		if totalImages >= numToLoad
			images.push
				width: width
				height: height
				path: data.path
		totalImages++

	$(window).scroll ->
		if $(window).scrollTop() + $(window).height() > $(document).height() - 100
			if lastcall == -1 || lastcall + 2000 < time
				nearBottom()
				lastcall = time
	socket.emit "getImageList",
		num: 1000
	totalImages = 0
