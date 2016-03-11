jQuery(document).ready(function() {
  $('#shifts-table').DataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#shifts-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "columnDefs": [
      {
      "targets": [-1, -2, -3],
      "orderable": false
      }
    ]
  });
});