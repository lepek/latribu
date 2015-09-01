jQuery(document).ready(function() {
  $('#users-table').DataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#users-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "columnDefs": [ {
      "targets": -1,
      "orderable": false
    } ]
  });
});