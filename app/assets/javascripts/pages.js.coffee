jQuery ->

  $('.time_zone_hover_wrapper').hover ->
    $('.time_zone_hover_name').toggleClass("animated fadeIn")

  # Set initial icon state for counselor search
  if $('#counselor_search').css('display') != 'none'
    $('#counselor_search_toggle .fa').addClass 'fa-close'
  
  # Handle counselor search toggle action
  $('#counselor_search_toggle').click ->
    $('#counselor_search_toggle .fa').toggleClass("fa-close");
    $('#counselor_search').slideToggle();
