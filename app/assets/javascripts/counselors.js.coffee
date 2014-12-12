# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  
  $('.best_in_place').best_in_place()

  $('.interval_trigger').click ->
  	target_wrapper = $(this).attr("data-trigger");
  	$(target_wrapper).slideToggle();

  # Set Initial Datepairs
  $('.time_pair .time').timepicker
  	showDuration: true
  	maxTime: '11:30pm'
  $('.time_pair').datepair()
