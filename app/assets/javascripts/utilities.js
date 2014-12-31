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

// Seconds to HH:MM:SS

String.prototype.toHHMMSS = function () {
    var sec_num = parseInt(this, 10); // don't forget the second param
    alert(sec_num);
    var hours   = Math.floor(sec_num / 3600);
    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
    var seconds = sec_num - (hours * 3600) - (minutes * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
    var time    = hours+':'+minutes+':'+seconds;
    return time;
}

