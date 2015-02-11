jQuery ->

  $('#counselor_search_toggle').click ->
    $('#counselor_search_toggle .fa').toggleClass("fa-close");
    $('#counselor_search').slideToggle();
