jQuery(document).ready(function() {
  $('#stats-table').DataTable({
    "responsive": true,
    "order": [[ 0, "desc" ]],
    "processing": true,
    "serverSide": true,
    "ajax": $('#stats-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "columnDefs": [ {
      "targets": -1,
      "orderable": false
    } ]
  });
});