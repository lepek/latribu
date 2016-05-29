jQuery(document).ready(function() {
  $('#packs-table').DataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#packs-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "columnDefs": [
      {
      "targets": [-1],
      "orderable": false
      }
    ]
  });

});