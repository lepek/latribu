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

  $('#show-credit-less').focus(function() {
    $('#show-credit-less-check').prop('checked', true);
  });

  $('#show-credit-less-check').change(function() {
    if ($('#show-credit-less-check').prop('checked') == false) {
      $('#show-credit-less').val('');
    }
  });

});