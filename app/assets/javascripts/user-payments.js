jQuery(document).ready(function() {
  $('#user-payments-table').dataTable({
    "responsive": true,
    "processing": true,
    "serverSide": true,
    "ajax": $('#user-payments-table').data('source'),
    "pagingType": "full_numbers",
    "language": { sUrl: "/dataTables.spanish.txt" }
  });

  $("#payment_user_id").select2();

  $('#payment_user_id').change( function () {
    var oTable = $('#user-payments-table').DataTable()
    var user_id = $('#payment_user_id').val()
    if (user_id) {
      oTable.ajax.url("/payments/user_payments/" + user_id + ".json").load();
    }
  } );
});