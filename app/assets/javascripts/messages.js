jQuery(document).ready(function() {

  $('#messages-table').DataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#messages-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "columnDefs": [
      {
        "targets": [-1],
        "orderable": false
      }
    ]
  });

  $('.form_datetime').datetimepicker({
    locale: 'es',
    format: 'DD/MM/YYYY'
  });

});