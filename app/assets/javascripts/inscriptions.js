jQuery(document).ready(function() {

  function ColorLuminance(hex, lum) {

    // validate hex string
    hex = String(hex).replace(/[^0-9a-f]/gi, '');
    if (hex.length < 6) {
      hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
    }
    lum = lum || 0;

    // convert to decimal and change luminosity
    var rgb = "#", c, i;
    for (i = 0; i < 3; i++) {
      c = parseInt(hex.substr(i*2,2), 16);
      c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16);
      rgb += ("00"+c).substr(c.length);
    }

    return rgb;
  }

  today = moment();

  if (today.day() == 0) {
    today.add(1, 'day')
    today.startOf('day')
  }

  $('#calendar').fullCalendar({
    defaultView: "agendaWeek",
    allDaySlot: false,
    events: '/inscriptions.json',
    height: 690,
    slotDuration: '00:30:00',
    hiddenDays: [ 0 ],
    minTime: '08:00:00',
    maxTime: '22:00:00',
    timezone: 'local',
    now: today,
    eventRender: function (event, element) {
      var tooltip = event.description;
      if (!event.open) {
        tooltip += '<br />' + event.status.charAt(0).toUpperCase() + event.status.substring(1);
        $(element).css('cursor', 'not-allowed');
      }
      $(element).attr("data-original-title", tooltip)
      $(element).tooltip({ container: "body", html: true})

      if (event.booked) {
        var time = $(element).find('.fc-time').html();
        var icon = '<div class="pull-right"><span class="glyphicon glyphicon-ok-sign" aria-hidden="true"></span></div>'
        $(element).find('.fc-time').html(time + icon);
      }

    },
    eventClick: function(event, jsEvent, view) {
      if (event.open) {
        $(this).tooltip('hide')
        if (event.booked) {
          $.ajax({
            url: "/inscriptions/" + event.id + ".json",
            type: "DELETE",
            dataType: "json",
            data:  {
              id: event.id,
              start_time: event.start.format("YYYY-MM-DD HH:mm:ss")
            },
            dataType: 'json',
            success: function(user) {
              $("#calendar").fullCalendar("refetchEvents");
              $("#user-credit").html(user.credit);

              var deadline = event.start.clone().subtract(event.deadline, 'hours');
              $('#cancelTitle').html(event.title);
              $('#cancelDate').html(event.start.format("LLLL") + ' hs.');
              $('#cancelModal').modal();
            }
          });
        } else {
          $.ajax({
            url: "/inscriptions.json",
            type: "POST",
            dataType: "json",
            data:  {
              id: event.id,
              start_time: event.start.format("YYYY-MM-DD HH:mm:ss")
            },
            dataType: 'json',
            success: function(user) {
              $("#calendar").fullCalendar("refetchEvents");
              $("#user-credit").html(user.credit);

              var deadline = event.start.clone().subtract(event.deadline, 'hours');
              $('#bookTitle').html(event.title);
              $('#bookDate').html(event.start.format("LLLL") + ' hs.');
              $('#deadline').html(deadline.format('HH:mm') + 'hs.');
              $('#bookModal').modal();
            }
          });
        }
      }
    },
    eventMouseover: function( event, jsEvent, view ) {
      if (event.open) {
        $(this).css('background-color', ColorLuminance(event.color, -0.2));
      }
    },
    eventMouseout: function( event, jsEvent, view ) {
      if (event.open) {
        $(this).css('background-color', event.color);
      }
    }
  })
});