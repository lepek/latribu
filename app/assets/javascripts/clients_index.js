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
        tableOptions.bAutoWidth = false;
        tableOptions.bJQueryUI = true;
        tableOptions.bSort = true;
        tableOptions.bLengthChange = true;
        tableOptions.bStateSave = true;
        tableOptions.sPaginationType = "full_numbers";

        return this.dataTable(tableOptions);
    }

    $.fn.inscriptionsTable = function () {
        var tableOptions = {
            aaSorting: [[ 5, "asc" ]],
            aoColumns:[
                $.extend({}, nameColumn, {iDataSort: 5}), // Shift
                shortNameColumn, // Instructor
                countColumn, // Attendants
                shortNameColumn, // Status
                nameColumn, // enrolled?
                actionColumn, // Action buttons
                hiddenColumn
            ]
        };
        return this.selectableTable(tableOptions);
    };

})(jQuery);
