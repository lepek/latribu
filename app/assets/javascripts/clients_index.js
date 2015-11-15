$(document).ready(function () {
    $('#tabs').tabs({cookie:{expires:1}});
    $("#inscriptions-table").inscriptionsTable();
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
        sWidth:"65px"
    };

    var nameColumn = {
        sWidth:"150px"
    };

    var shortNameColumn = {
        sWidth:"70px"
    };

    var countColumn = {
        bSearchable:false,
        sWidth:"50px"
    };

    $.fn.selectableTable = function (tableOptions) {
        // Set the options that all of them share
        tableOptions.iDisplayLength = 10;
        tableOptions.bAutoWidth = true;
        tableOptions.bJQueryUI = true;
        tableOptions.bSort = true;
        tableOptions.bLengthChange = true;
        tableOptions.bStateSave = true;
        tableOptions.sPaginationType = "full_numbers";
        tableOptions.oLanguage = { sUrl: "/dataTables.spanish.txt" }

        return this.dataTable(tableOptions);
    }

    $.fn.inscriptionsTable = function () {
        var tableOptions = {
            order: [[ 6, "asc" ]],
            columns:[
                $.extend({}, countColumn, {sClass: "c-center"}), // Icon
                $.extend({}, nameColumn, {dataSort: 6}), // Shift
                nameColumn, // Instructor
                shortNameColumn, // Status
                nameColumn, // Shift
                actionColumn, // Action buttons
                hiddenColumn
            ]
        };
        return this.selectableTable(tableOptions);
    };

})(jQuery);
