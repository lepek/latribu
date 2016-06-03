/*
* Add the active class to the current selected menu option
*/
jQuery(document).ready(function() {
  function stripTrailingSlash(str) {
    if(str.substr(-1) == '/') {
      return str.substr(0, str.length - 1);
    }
    return str;
  }

  var url = window.location.pathname;
  var activePage = stripTrailingSlash(url);

  $('.nav li a').each(function(){
    var currentPage = stripTrailingSlash($(this).attr('href'));

    if (activePage == currentPage) {
      $(this).parent().addClass('active');
    }
  });

  $('#next_class').click(function() {
    $.ajax({
      url: "/shifts/next_class.json",
      type: "GET",
      dataType: "json",
      success: function(shift_id) {
        document.location.href = '/shifts/' + shift_id;
      },
      error: function (xhr, ajaxOptions, thrownError) {
        alert('No hay más clases para el día de hoy');
      }
    });
  });

  $.ajax({
    url: "/check_pending_messages.json",
    type: "GET",
    dataType: "json",
    success: function(messages) {
      $.each(messages, function(index, msg) {
        bootbox.alert('<b>' + msg + '</b>');
      });
    }
  });

  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })


});