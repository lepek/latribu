$(document).ready(function () {
    $('#tabs').tabs({cookie:{expires:1}});
    $("#users-table").usersTable();
    $("#shifts-table").shiftsTable();
    $("#payments-table").paymentsTable();
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
        sWidth:"95px"
    };

    var nameColumn = {
        sWidth:"150px"
    };

    var shortNameColumn = {
        sWidth:"70px"
    };

    var countColumn = {
        bSearchable:false,
        sWidth:"30px"
    };

    $.fn.selectableTable = function (tableOptions) {
        // Set the options that all of them share
        tableOptions.iDisplayLength = 10;
        tableOptions.bAutoWidth = false;
        tableOptions.bJQueryUI = true;
        tableOptions.bSort = true;
        tableOptions.bLengthChange = true;
        tableOptions.bStateSave = true;
        tableOptions.sPaginationType = "full_numbers";

        return this.dataTable(tableOptions);
    }

    $.fn.usersTable = function () {
        var tableOptions = {
            aoColumns:[
                nameColumn, // Nombre
                nameColumn, // email
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
                countColumn, // Cupo
                $.extend({}, nameColumn, {iDataSort: 6}), // Proxima
                countColumn, // Anotados
                countColumn, // Estado
                actionColumn, // Action buttons
                hiddenColumn
            ]
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.paymentsTable = function () {
        var tableOptions = {
            aoColumns:[
                nameColumn, // Client
                nameColumn, // Fecha
                countColumn, // Monto
                countColumn, // Credito
                actionColumn // Action buttons
            ]
        };
        return this.selectableTable(tableOptions);
    };

})(jQuery);
