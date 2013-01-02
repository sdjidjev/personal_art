getRandomInt = (min, max) ->
	Math.floor(Math.random() * (max - min + 1)) + min

i = 0
while i < 50
	width = getRandomInt(100, 200)
	height = getRandomInt(100, 200)
	$("#artContainer").append "<img class='box' width='"+width+"' height='"+height+"' src='http://placekitten.com/" + width + "/" + height + "'>"
	i++

$(document).ready ->
	$ ->
		$("#artContainer").masonry(
			itemSelector: ".box"
			columnWidth: 1
			isAnimated: true
		).imagesLoaded ->
			$("#artContainer").masonry("reload").css(
				visibility: "visible"
			)