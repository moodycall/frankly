# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

	$("#new_rating").submit ->
	  foo = $(".star-rating-on").length
	  $("#rating_stars").val(foo)
