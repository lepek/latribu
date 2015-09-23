jQuery(document).ready(function() {
  $('#credit-reset-table').dataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#credit-reset-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "columnDefs": [ {
      "targets": -1,
      "orderable": false
    } ]
  });

  $('#month-year').datetimepicker({
    locale: 'es',
    format: 'MM/YYYY'
  });

  var oTable = $('#credit-reset-table').DataTable();

  $('#search-reset').click(
    function () {
      oTable.ajax.url("/users/reset_search.json?month_year=" + $('#reset-month-year').val()).load();
    }
  );

});