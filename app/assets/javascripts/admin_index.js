$(document).ready(function () {
    $('#tabs').tabs({cookie:{expires:1}});
    $("#users-table").usersTable();
    $("#shifts-table").shiftsTable();
    $("#payments-table").paymentsTable();
    $("#user-payments-table").userPaymentsTable();
    $("#stats-table").statsTable();
    $("#rookies-table").rookiesTable();
});

(function ($) {
    /**
     * A column with default values.
     */
    var standardColumn = null;

    /**
     * A hidden column.
     */
    var hiddenColumn = {
        bSearchable:false,
        bSortable:false,
        bVisible:false
    }

    /**
     * A column that holds action buttons.
     */
    var actionColumn = {
        bSearchable:false,
        bSortable:false,
        sWidth:"160px"
    };

    var shortActionColumn = {
        bSearchable:false,
        bSortable:false,
        sWidth:"100px"
    };

    var nameColumn = {
        sWidth:"150px"
    };

    var longNameColumn = {
        sWidth:"200px"
    };

    var shortNameColumn = {
        sWidth:"80px"
    };

    var countColumn = {
        bSearchable:false,
        sWidth:"30px"
    };

    var shortCountColumn = {
        bSearchable:false,
        sWidth:"20px"
    }

    $.fn.selectableTable = function (tableOptions) {
        // Set the options that all of them share
        tableOptions.iDisplayLength = 10;
        tableOptions.bAutoWidth = false;
        tableOptions.bJQueryUI = true;
        tableOptions.bSort = true;
        tableOptions.bLengthChange = true;
        tableOptions.bStateSave = true;
        tableOptions.sPaginationType = "full_numbers";
        tableOptions.oLanguage = { sUrl: "/dataTables.spanish.txt" }

        return this.dataTable(tableOptions);
    }

    $.fn.usersTable = function () {
        var tableOptions = {
            aoColumns:[
                nameColumn, // Nombre
                nameColumn, // email
                nameColumn, // phone
                shortNameColumn, // rol
                actionColumn // Action buttons
            ]
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.shiftsTable = function () {
        var tableOptions = {
            aaSorting: [[ 6, "asc" ]],
            aoColumns:[
                $.extend({}, shortNameColumn, {bSortable:false}), // Dia y Hora
                shortCountColumn, // Cupo
                $.extend({}, nameColumn, {iDataSort: 6}), // Proxima
                shortCountColumn, // Anotados
                countColumn, // Estado
                actionColumn, // Action buttons
                hiddenColumn
            ]
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.userPaymentsTable = function () {
        var tableOptions = {
            aaSorting: [[ 4, "desc" ]],
            aoColumns: [
                $.extend({}, longNameColumn, {iDataSort: 4, mData: "created_at_formatted"}), // Fecha
                $.extend({}, nameColumn, {mData: "month"}), // Mes
                $.extend({}, countColumn, {mData: "amount"}), // Monto
                $.extend({}, countColumn, {mData: "credit"}), // Credito
                $.extend({}, hiddenColumn, {mData: "created_at"}) // Fecha sin formato
            ],
            bProcessing: true,
            fnRowCallback: function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                if (aData.credit == "1") {
                    $('td', nRow).each(function() { $(this).attr('class', 'conditionalRowColor'); })
                }
                return nRow;
            }
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.paymentsTable = function () {
        var tableOptions = {
            aaSorting: [[ 6, "asc" ]],
            aoColumns:[
                nameColumn, // Client
                nameColumn, // Email
                $.extend({}, longNameColumn, {iDataSort: 6}), // Fecha
                countColumn, // Monto
                countColumn, // Credito
                shortActionColumn, // Action buttons
                hiddenColumn
            ]
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.statsTable = function () {
        var tableOptions = {
            aaSorting: [[ 3, "desc" ]],
            aoColumns:[
                $.extend({}, nameColumn, {iDataSort: 3}), // Mes
                countColumn, // Creditos
                countColumn, // Inscriptiones
                hiddenColumn
            ]
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.rookiesTable = function () {
        var tableOptions = {
            aaSorting: [[ 5, "desc" ]],
            aoColumns:[
                $.extend({}, nameColumn, {iDataSort: 5}), // Clase
                nameColumn, // Nombre
                nameColumn, // Telefono
                nameColumn, // Email
                actionColumn, // Action buttons
                hiddenColumn // Clase para ordenar
            ]
        };
        return this.selectableTable(tableOptions);
    };

})(jQuery);
