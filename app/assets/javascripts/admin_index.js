$(document).ready(function () {
    $('#tabs').tabs({cookie:{expires:1}});
    $("#users-table").usersTable();
    $("#shifts-table").shiftsTable();
    $("#payments-table").paymentsTable();
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

    $.fn.paymentsTable = function () {
        var tableOptions = {
            aaSorting: [[ 5, "asc" ]],
            aoColumns:[
                nameColumn, // Client
                $.extend({}, nameColumn, {iDataSort: 5}), // Fecha
                countColumn, // Monto
                countColumn, // Credito
                actionColumn, // Action buttons
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
