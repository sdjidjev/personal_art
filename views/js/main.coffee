getRandomInt = (min, max) ->
	Math.floor(Math.random() * (max - min + 1)) + min

resizeOverlayImage = () ->
	width = $("#overlayPic").width()
	height = $("#overlayPic").height()
	$("#overlayPic").css("margin-left", ($(window).width()-width)/2)
	$("#overlayPic").css("margin-top", ($(window).height()-height)/2)

overlayImage = (img) ->
	sizeRatio = 0.8
	$("#overlayPic").attr("src", "/resize/"+$(window).width()*sizeRatio+"/"+$(window).height()*sizeRatio+"/"+img)
	$("#overlay").waitForImages ->
		$("#overlay").fadeIn(500)
		resizeOverlayImage()

overlayImageOff = () ->
	$("#overlay").fadeOut(500)

letter = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

gridSize = 250
gridMargin = 2
shapes = [
			{width: gridSize*2-gridMargin*2, height: gridSize*2-gridMargin*2},
			{width: gridSize-gridMargin*2, height: gridSize*2-gridMargin*2},
			{width: gridSize*2-gridMargin*2, height: gridSize-gridMargin*2},
			{width: gridSize-gridMargin*2, height: gridSize-gridMargin*2},
			{width: gridSize-gridMargin*2, height: gridSize-gridMargin*2},
			{width: gridSize-gridMargin*2, height: gridSize-gridMargin*2}
		]

$(document).ready ->
	$ ->
		i = 0
		while i < 12
			size = shapes[getRandomInt(0,shapes.length-1)]
			width = size.width
			height = size.height
			$("#artContainer").append "<img class='box' onclick='overlayImage(\""+letter[i]+".jpg\")' src='/crop/"+width+"/"+height+"/"+letter[i]+".jpg'>"
			i++
		$("#artContainer").masonry(
			itemSelector: ".box"
			columnWidth: 1
			#isAnimated: true
		).imagesLoaded ->
			$("#artContainer").masonry("reload").css(
				visibility: "visible"
			)
		$("#overlayPic").on "click", (event) ->
			overlayImageOff()
		$(window).resize ->
			resizeOverlayImage()
		$(document).keyup (e) ->
			overlayImageOff() if e.keyCode is 27
