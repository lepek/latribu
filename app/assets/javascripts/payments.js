jQuery(document).ready(function() {
  $('#payments-table').DataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#payments-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" }
  });

  $('#date-from-comp').datetimepicker({
    locale: 'es',
    sideBySide: true
  });
  $('#date-to-comp').datetimepicker({
    locale: 'es',
    sideBySide: true,
    useCurrent: false //Important! See issue #1075
  });
  $("#date-from-comp").on("dp.change", function (e) {
    $('#date-to-comp').data("DateTimePicker").minDate(e.date);
  });
  $("#date-to-comp").on("dp.change", function (e) {
    $('#date-from-comp').data("DateTimePicker").maxDate(e.date);
  });

  var oTable = $('#payments-table').DataTable();

  $('#payments-search-button').click(
    function () {
      oTable.ajax.url("/payments.json?date_from=" + $('#date-from').val() + "&date_to=" + $('#date-to').val()).load();
    }
  );

  $("#payments-export-button").click(
    function () {
      $("#payments_form").submit();
    }
  );

});