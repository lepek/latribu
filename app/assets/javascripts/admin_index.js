$(document).ready(function () {
    $('#tabs').tabs({
        beforeLoad: function( event, ui ) {
            if ( ui.tab.data( "loaded" ) ) {
                event.preventDefault();
                return;
            } else {
                ui.panel.html('<center><div class="alert-message block-message info" style="width: 300px; padding: 20px; margin: 20px; font-weight: bold;">Cargando...</div></center>');
            }

            ui.jqXHR.success(function() {
                ui.tab.data( "loaded", true );
            });
        }
    });

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

    var longActionColumn = {
        bSearchable:false,
        bSortable:false,
        sWidth:"250px"
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
        tableOptions.pageLength = 10;
        tableOptions.autoWidth = false;
        tableOptions.jQueryUI = true;
        tableOptions.ordering = true;
        tableOptions.lengthChange = true;
        tableOptions.stateSave = true;
        tableOptions.pagingType = "full_numbers";
        tableOptions.language = { sUrl: "/dataTables.spanish.txt" }

        return this.DataTable(tableOptions);
    }

    $.fn.usersTable = function () {
        var tableOptions = {
            columns:[
                nameColumn, // Nombre
                nameColumn, // email
                shortNameColumn, // phone
                countColumn, // Credito
                longActionColumn // Action buttons
            ]
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.shiftsTable = function () {
        var tableOptions = {
            aaSorting: [[ 6, "asc" ]],
            aoColumns:[
                $.extend({}, nameColumn, {bSortable: false, sWidth: "120px"}), // Dia y Hora
                shortCountColumn, // Cupo
                $.extend({}, longNameColumn, {iDataSort: 6}), // Proxima
                shortCountColumn, // Anotados
                countColumn, // Estado
                actionColumn, // Action buttons
                hiddenColumn
            ]
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.userPaymentsTable = function (options) {
        var tableOptions = {
            order: [[ 4, "desc" ]],
            columns: [
                $.extend({}, longNameColumn, {dataSort: 4, data: "created_at_formatted"}), // Fecha
                $.extend({}, nameColumn, {data: "month_year_formatted"}), // Mes
                $.extend({}, countColumn, {data: "amount"}), // Monto
                $.extend({}, countColumn, {data: "credit"}), // Credito
                $.extend({}, hiddenColumn, {data: "created_at"}) // Fecha sin formato
            ],
            processing: true,
            rowCallback: function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                if (aData.credit == "1") {
                    $('td', nRow).each(function() { $(this).attr('class', 'conditionalRowColor'); })
                }
                return nRow;
            }
        };
        $.extend(tableOptions, options);
        return this.selectableTable(tableOptions);
    };

    $.fn.paymentsTable = function () {
        var tableOptions = {
            order: [[ 5, "asc" ]],
            columns: [
                $.extend({}, longNameColumn, {dataSort: 5, data: "created_at_formatted"}), // Fecha
                $.extend({}, nameColumn, {data: "user.full_name"}), // Mes
                $.extend({}, countColumn, {data: "amount"}), // Monto
                $.extend({}, countColumn, {data: "credit"}), // Credito
                $.extend({}, shortNameColumn, {dataSort: 6, data: "month_year_formatted"}), // Mes
                $.extend({}, hiddenColumn, {data: "created_at"}), // Fecha sin formato
                $.extend({}, hiddenColumn, {data: "month_year"}) // Mes y año sin formato
            ],
            processing: true,
            footerCallback: function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
                var total = 0;
                for (var i = 0; i < aaData.length; i++) {
                    total += aaData[i].amount * 1;
                }
                var nCells = nRow.getElementsByTagName('th');
                nCells[0].innerHTML = '<strong>Total pagado en el período: $' + total + '</strong>';
            }
        };
        return this.selectableTable(tableOptions);
    };

    $.fn.resetCreditsTable = function () {
        var tableOptions = {
            columns: [
                $.extend({}, nameColumn, {data: "full_name"}), // Cliente
                $.extend({}, countColumn, {data: "current_credit"}), // Credito
                $.extend({}, countColumn, {data: "future_credit"}), // Credito futuro
            ],
            processing: true
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
