/* Utilities used throughout application JS code */

// showColumn - Show or hide a column in a Flexigrid
function showColumn(tbl, columnName, visible) {

    var grd = $(tbl).closest('.flexigrid');
    var colHeader = $('th[abbr=' + columnName + ']', grd);
    var colIndex = $(colHeader).attr('axis').replace(/col/, "");


    // queryVisible = $(colHeader).is(':visible');
    // alert(queryVisible);

    $(colHeader).toggle(visible);

    $('tbody tr', grd).each(
        function () {
            $('td:eq(' + colIndex + ')', this).toggle(visible);
        }
    );

}

// Format a time
function niceTime(dt) {
    var hours = dt.getHours()
    var minutes = dt.getMinutes()

    if (minutes < 10)
        minutes = "0" + minutes

    var suffix = "AM";
    if (hours >= 12) {
        suffix = "PM";
        hours = hours - 12;
    }
    if (hours == 0) {
        hours = 12;
    }

    return hours + ":" + minutes + " " + suffix;
}

