bind_show_closed = () ->
  $('#show_closed_form').bind 'ajax:success', (data, status, xhr) ->
    $('#data').html(status)
  $('#show_closed_check_box').change () ->
    $('#show_closed_check_box').closest('form').submit()

$(document).ready ->
  bind_show_closed()
