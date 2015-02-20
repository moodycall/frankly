# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  $('textarea').autosize();
  
  $('.best_in_place').best_in_place()

  $(".boolean-switch").bootstrapSwitch()
  $( ".datepicker" ).datepicker({"showAnim": "slideDown"})
  $('#counselor_specialty_ids').chosen()
  $('.floatlabel').floatlabel({
    "labelEndTop": "8px",
  });

  $("#datepicker").datepicker({ minDate: 0 });

  $('.interval_trigger').click ->
  	$(".intervals_wrapper").not($(this).attr("data-trigger")).slideUp();
  	$($(this).attr("data-trigger")).slideToggle();

  # Set Initial Datepairs
  $('.time').timepicker
  	showDuration: true
  	maxTime: '11:30pm'
  $('.time_pair').datepair()

  $(window).resize ->
    new_height = $(window).height()
    $('.counselor_availability_wrapper').css("min-height", new_height)

  $(window).resize()

  $(".counselor-time-button").click ->
    $(".selected_time").val($(this).attr("data-time"))

  $(".counselor_availability_day_wrapper").each ->
    $(".availability_time_button_wrapper:nth-child(7)").nextAll().wrapAll("<div class='extra-times-for-day'></div>")