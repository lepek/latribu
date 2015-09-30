jQuery(document).ready(function() {
  $('#disciplines-table').DataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#disciplines-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "columnDefs": [
      {
      "targets": [-1],
      "orderable": false
      }
    ]
  });

  $('#discipline_color').minicolors();
  $('#discipline_font_color').minicolors();

});