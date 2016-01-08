jQuery(document).ready(function() {
  $('#past-shifts-table').DataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#past-shifts-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" },
    "order": [[ 0, "desc" ]],
    "columnDefs": [
      {
      "targets": [-1, -2],
      "orderable": false
      }
    ]
  });
});