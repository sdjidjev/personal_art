getRandomInt = (min, max) ->
	Math.floor(Math.random() * (max - min + 1)) + min

letter = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

i = 0
while i < 4
	width = getRandomInt(100, 600)
	height = getRandomInt(100, 600)
	$("#artContainer").append "<img class='box' src='/resize/"+width+"/"+height+"/"+letter[i]+".jpg'>"
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