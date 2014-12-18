var mw_id = null;
var mw_token = null;
var mw = [];

$(function() {



    $("#dialogMonitorWindows").dialog({
        modal: true,
        title: "Monitor Window Properties",
        disabled: true,
        autoOpen: false,
        width: 800,
        close: function (event, ui ) {
            location.reload();
        }
    })

    $("#linkNewMonitorWindow").click(function(evt) {
        loadDialog("Window",false, null);
        return false;
    })

    $("form[id*='monitor_window']").live('ajax:success', function(evt, data) {
        if (data.length < 2) {
            $("#dialogMonitorWindows").dialog("close");
        } else {
            setupDialog($("#dialogMonitorWindows"), data);
        }
    })

    $("form[id*='monitor_sensor']").live('ajax:success', function(evt, data) {
        if (data.length < 2) {
            $("#dialogMonitorSensors").dialog("close");
            $("#flexMonitorSensors").flexReload();
        } else {
            setupDialog($("#dialogMonitorSensors"), data);
        }
    })



    // Get all the windows and display them

    var url = "/monitor_windows.js";
    if (typeof public_token != 'undefined') {
      url = "/monitor_windows/"+public_token+"/public.js"
    }
    $.ajax({
        url: url,
        method: "GET",
        dataType: "json",
        success: function(data) {
            var container_div = document.getElementById("monitors-container");
            for (var index in data.monitor_windows) {
                var config = data.monitor_windows[index];
                var mw_container_div = document.createElement("div");
                mw_container_div.className = "monitor-container-parent mw-parent-" + config.width;
                mw_container_div.innerHTML = config.html;
                mw_container_div.id = "mc_" + config.id;
                container_div.appendChild(mw_container_div);
                var placeholder = document.getElementById("mw-"+config.id);
                mw[config.id] = new MonitorWindow(config, placeholder);
                mw[config.id].display();
             }
        },
        cache: false,
        async: false
    });

    // Make them draggable and sortable
    $(".monitors-container").sortable({
        items: '.monitor-container-parent',
        handle: ".monitor-move",
        cursor: 'move',
        update: function() {
            $.ajax({
                type: 'post',
                data: $(".monitors-container").sortable('serialize'),
                dataType: 'script',
                url: '/monitor_windows/sort'
            })
        }
    })


});


function procMS(celDiv, id) {
    $(celDiv).click ( function()
    {
        loadDialog("Sensor", true, id);
        return false;
    });
}


function loadDialog(type, editing, id) {
    var url = "/monitor_"+type.toLowerCase()+"s/";
    if (editing) {
        url += id + "/edit";
    } else {
        url += "new";
        if (type == "Sensor") {
            url += "?initial_window_token="+mw_token;
        }
    }
    $.ajax({
        url: url,
        success: function(data) {
            setupDialog($('#dialogMonitor'+type+'s'),data);
        },
        async: false,
        cache: false
    });
    var buttons = null;
    if (type == "Window") {
        buttons =  [{
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
    } else {
        buttons =  [{
            text: "Save",
            click: function() {
                $("form[id*='monitor_sensor']").submit()
            },
            class: "btn btn-large btn-primary"
        }];

        if (editing) {
            buttons.push({
                text: "Delete",
                click: function() {
                    if (confirm("OK to delete?")) {
                        $.ajax({
                            url: "/monitor_sensors/" + id,
                            type: "DELETE",
                            success: function(data) {
                                $("#dialogMonitorSensors").dialog("close");
                                $("#flexMonitorSensors").flexReload();
                            },
                            async: false,
                            cache: false
                        });
                    }
                },
                class: "btn btn-large btn-primary"
            });
        }

    }

    buttons.push({
        text: "Cancel",
        click: function() {
            $(this).dialog("close");
        },
        class: "btn btn-large btn-primary"
    });

    if (type == "Window") {
        $("#flexMonitorSensors").flexigrid(
            {
                method: 'GET',
                url: 'monitor_sensors.js?monitor_window_id='+mw_id+"&initial_window_token="+mw_token,
                dataType: 'json',
                colModel : [
                    {display: 'Sensor', name : 'sensor', width : 100, sortable : true, align: 'left', process: procMS},
                    {display: 'Legend Name', name : 'legend', width : 100, sortable : true, align: 'left', process: procMS},
                    {display: 'Color', name : 'color', width : 70, sortable : true, align: 'left', process: procMS},
                    {display: 'Alerts Only', name : 'alerts_only', width : 70, sortable : true, align: 'left', process: procMS}
                ],
                sortname: "name",
                sortorder: "asc",
                usepager: false,
                width: 'auto',
                height: 'auto',
                title: 'Sensors',
                onSuccess : function () {
                    $("#flexMonitorSensors tr").each ( function () {
                        var cell = $('td[abbr="color"] >div', this);
                        $(cell).css("background-color", (cell.text() && (cell.text != "auto") ? cell.text() : "#FFFFFF"));
                        if (cell.text() != "auto") $(cell).html("&nbsp;");
                    })
                }
            }
        );

        $("#dialogMonitorSensors").dialog({
            modal: true,
            title: "Sensor Properties",
            disabled: true,
            autoOpen: false,
            stack: true,
            width: 600,
            close: function (event, ui ) {
                $("#flexMonitorSensors").flexReload();
            }
        });

        $("#linkNewMonitorSensor").click(function(evt) {
            loadDialog("Sensor", false, null);
            return false;
        });

        $("#monitor_window_monitor_type").change(function(evt) {
            swapWindowTypeForm(this);
         });

        swapWindowTypeForm($("#monitor_window_monitor_type"));

        $("#monitor_window_public").change(function(evt) {
            showHidePublicUrl(this);
        });

        showHidePublicUrl($("#monitor_window_public"));



    }
    $("#dialogMonitor"+type+"s").dialog("option", "buttons", buttons);
    $("#dialogMonitor"+type+"s").dialog("enable");
    $("#dialogMonitor"+type+"s").dialog("open");

}

function setupDialog(element, data) {
    element.html(data);
    $(".color").spectrum({
        clickoutFiresChange: true,
        change: function(c) {
            this.value = c.toHexString()
        }
    });

    if (mw_id == null) mw_id = $("input#monitor_window_id").val();
    if (mw_token == null) mw_token = $("input#monitor_window_initial_token").val();

}

function swapWindowTypeForm(select) {
    if ($(select).val() == "graph") {
        $(".graph-only").show();
    } else {
        $(".graph-only").hide();
    }
}

function showHidePublicUrl(select) {
    if ($(select).is(':checked')) {
        $("a#linkMonitorWindowUrl").attr("href", "/monitor_windows/" + mw_token + "/public");
        $("a#linkMonitorWindowUrl").text(window.location + "/" + mw_token + "/public");
        $("#linkMonitorWindowUrl").show();
    } else {
        $("#linkMonitorWindowUrl").hide();
    }
}

// Auto-refresh

var last_activity = (new Date()).getTime();
var replot_interval = 600000;    // Milliseconds between automatic plots
window.setInterval(function() {
    if ((((new Date()).getTime()) - (last_activity)) > replot_interval) {
        mw.forEach(function (placeholder) {
           placeholder.display();
        });
    }
}, replot_interval);




