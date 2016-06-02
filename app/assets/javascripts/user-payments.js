jQuery(document).ready(function() {
  $('#user-payments-table').dataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "order": [[ 0, "desc" ]],
    "ajax": $('#user-payments-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "rowCallback": function( row, data, index ) {
      if (data[3] == "1") {
        $('td', row).each(function() { $(this).attr('class', 'conditional-payment-row'); })
      }
      return row;
    }
  });

  $( "#new_payment" ).submit(function( event ) {
    $('#date-from').val( $('#date-from-credit').data("DateTimePicker").date().format() );
    $('#date-to').val( $('#date-to-credit').data("DateTimePicker").date().format() );
  });

  $('#date-from-credit').datetimepicker({
    locale: 'es',
    format: 'dddd, D [de] MMMM [del] YYYY',
    defaultDate: 'now',
    ignoreReadonly: true
  });

  $('#date-to-credit').datetimepicker({
    locale: 'es',
    format: 'dddd, D [de] MMMM [del] YYYY',
    defaultDate: moment(new Date()).add(31, "days"),
    ignoreReadonly: true
  });

  $("#payment_user_id").select2();

  $('#payment_user_id').change( function () {
    var oTable = $('#user-payments-table').DataTable();
    var user_id = $('#payment_user_id').val();
    if (user_id) {
      oTable.ajax.url("/payments?user_id=" + user_id + ".json").load();
    }
  } );
});