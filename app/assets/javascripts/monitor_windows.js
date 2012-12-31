$(function() {


    $("#dialogMonitorWindows").dialog({
        modal: true,
        title: "Monitor Window Properties",
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Save",
            click: function() {
                $("form[id*='monitor_window']").submit()
            },
            class: "btn btn-large btn-primary"
        },{
            text: "Cancel",
            click: function() {
                $(this).dialog("close");
            },
            class: "btn btn-large btn-primary"
        }],
        close: function (event, ui ) {
            // $("#flexSensors").flexReload();
        }
    })

    $("#linkNewMonitorWindow").click(function(evt) {
        loadMonitorDialog(false, null);
        return false;
    })

    $("form[id*='monitor_window']").live('ajax:success', function(evt, data) {
        if (data.length < 2) {
            $("#dialogMonitorWindows").dialog("close");
        } else {
            $('#dialogMonitorWindows').html(data);
            $(".color").spectrum({
                clickoutFiresChange: true,
                change: function(c) {
                    this.value = c.toHexString()
                }
            });
        }
    })

});

function loadMonitorDialog(editing, id) {
    var url = "/monitor_windows/";
    if (editing) {
        url += id + "/edit";
    } else {
        url += "new";
    }
    $.ajax({
        url: url,
        success: function(data) {
            $('#dialogMonitorWindows').html(data);
            $(".color").spectrum({
                clickoutFiresChange: true,
                change: function(c) {
                    this.value = c.toHexString()
                }
            });
        },
        async: false,
        cache: false
    });
    var buttons =  [{
        text: "Save",
        click: function() {
            $("form[id*='monitor_window']").submit()
        },
        class: "btn btn-large btn-primary"
    }];

    if (editing) {
        buttons.push({
            text: "Delete",
            click: function() {
                if (confirm("OK to delete?")) {
                    $.ajax({
                      url: "/monitor_windows/" + id,
                      type: "DELETE",
                      success: function(data) {
                          $("#dialogMonitorWindows").dialog("close");
                      },
                      async: false,
                      cache: false
                    });
                }
            },
            class: "btn btn-large btn-primary"
        });
    }

    buttons.push({
        text: "Cancel",
        click: function() {
            $(this).dialog("close");
        },
        class: "btn btn-large btn-primary"
    });
    $("#dialogMonitorWindows").dialog("option", "buttons", buttons);
    $("#dialogMonitorWindows").dialog("enable");
    $("#dialogMonitorWindows").dialog("open");

}

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
