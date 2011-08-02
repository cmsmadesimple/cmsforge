$(document).ready ->
  $('#spinner')
    .hide()
    .ajaxStart () ->
      $(this).show()
    .ajaxStop () ->
      $(this).hide()
