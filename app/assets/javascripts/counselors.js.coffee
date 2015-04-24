# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  display_remove_icon = ->
    if $(".remove_item_wrapper").length > 1
      $(".remove_item_wrapper").find(".fa").fadeIn()
    else
      $(".remove_item_wrapper").find(".fa").fadeOut()

  update_session_cost = (rate) ->
    if $("#counseling_session_estimate_duration_in_minutes").val() == "60"
      $("#session_cost_wrapper").html("$" + (rate * 2).toFixed(2))
    else
      $("#session_cost_wrapper").html("$" + rate.toFixed(2))


  $(document.body).on('click', '.remove_item_wrapper', ->
    if $(".remove_item_wrapper").length > 1
      $(this).parent().remove()
    
    display_remove_icon()
  ).click()

  $(document.body).on 'click', '#add-item', ->
    display_remove_icon()
    
  display_remove_icon()

  $('.toggle_trigger').click ->
    toggleable_class = $(this).attr('data-toggleable')
    $(toggleable_class).fadeToggle()

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

  $( "#datetime" ).datepicker ->
    dateFormat: "mm/dd/yyyy"

  $(".trigger_calendar_picker").click ->
    $("#datetime").datepicker("show");

  $(window).resize( ->
    new_height = $(window).height()
    $('.counselor_availability_wrapper').css("min-height", new_height)
  ).resize()

  $(".counselor-time-button").click ->
    session_rate        = parseFloat($(this).attr("data-session-rate"))
    time                = $(this).attr("data-time")

    $(".selected_time").val(time)
    
    $("#counseling_session_time").change()
    $("#counseling_session_estimate_duration_in_minutes").change()
    $("#counseling_session_estimate_duration_in_minutes").attr("data-session-rate", session_rate)

    update_session_cost(session_rate)

  $("#counseling_session_time").change ->
    selected_time       = $(this).find("option:selected")
    is_hourly_available = selected_time.attr("data-available")
    session_rate        = parseFloat($(this).attr("data-session-rate"))

    if (is_hourly_available == "false")
      $("#counseling_session_estimate_duration_in_minutes").val("30")
      $("#counseling_session_estimate_duration_in_minutes option[value='60']").hide()
    else
      $("#counseling_session_estimate_duration_in_minutes").val("60")
      $("#counseling_session_estimate_duration_in_minutes option[value='60']").show()
    
    update_session_cost(session_rate)
    $("#counseling_session_estimate_duration_in_minutes").change()

  $("#counseling_session_estimate_duration_in_minutes").change ->
    session_rate        = parseFloat($(this).attr("data-session-rate"))

    console.log(session_rate)
    update_session_cost(session_rate)


  $(".counselor_availability_day_wrapper").each ->
    $(this).children(".availability_time_button_wrapper:nth-child(7)").nextAll().wrapAll("<div class='extra-times-for-day' />")

  $(".extra-times-for-day").after("<div class='col-xs-6 col-sm-3 availability_time_button_wrapper'><div class='btn btn-primary btn-block expand-extra-times'>More</div></div>")

  $(".expand-extra-times").click ->
    # Clean up Previous Selection
    $(".extra-times-for-day").hide()
    $(".expand-extra-times").show()
    
    #Manipulate Selected
    parent = $(this).closest(".row")
    parent.children(".extra-times-for-day").show()
    $(this).hide()
