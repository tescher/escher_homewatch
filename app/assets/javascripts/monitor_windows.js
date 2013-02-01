var mw_id = null;
var mw_token = null;
var series_all = [];

// Window object
function MonitorWindow(config, windowDiv) {
    this.config = config;
    this.windowDiv = windowDiv;
    this.plotOptions = {
        series: {
            lines: { show: false },
            shadowSize: 0
        },
        lines: { show: true },
        points: { show: false },
        colors: ["#ffff80", "#80ff80", "#80ffff", "#ff80ff", "#c0c080", "#80c080", "#80c0c0", "#c080c0"],
        legend: {
            backgroundColor: "#303030",
            color: "#e0e0e0",
            position: "sw",
            labelFormatter: function(label, series) {
                // series is the series object for the label
                var now = new Date();
                // console.log(getSQLts(now));
                var old = false;
                // console.log(legend_data[0][sensor_id]['ts']);
                var last_value = "";
                var limit_reached = false;
                var formatted = '<span id="legend">' + label + " (";
                var last = series['data'].length - 1;
                if (last >= 0) {
                    if ((now - Date.parse(series['data'][last][0])) > 60*60*1000) {  //If data more than an hour old, signify
                        old = true;
                    }
                    last_value = parseFloat(series['data'][last][1]).toFixed(1).toString();
                } else {
                    last_value = "No Data";
                }
                if ((series['trigger_upper_limit']) && (parseFloat(last_value) >= parseFloat(series['trigger_upper_limit']))) {
                    limit_reached = true;
                }
                if ((series['trigger_lower_limit']) && (parseFloat(last_value) <= parseFloat(series['trigger_lower_limit']))) {
                    limit_reached = true;
                }

                var style_code = "legendcurrent";
                if (old) {
                    style_code = "legendold";
                }
                if (limit_reached) {
                    style_code += "limit";
                }
                formatted += '<span id="' + style_code + '">' + last_value + '</span>)</span>';
                // console.log(formatted);
                return formatted;
            }
        },
        yaxis: {
            color: "#909090",
            min: ((!config.y_axis_auto && config.y_axis_min != "") ? config.y_axis_min : -10),
            max: ((!config.y_axis_auto && config.y_axis_max != "") ? config.y_axis_max : 120)
        },
        xaxis: {
            mode: "time", timeformat: "%b %d",
            min: ((!config.x_axis_auto && config.x_axis_days != "") ? Date.now() - 1000*60*60*24*config.x_axis_days : null),
            minTickSize: [1, "day"],
            monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
            zoomRage: [0.1,3600000000],
            color: "#909090"
        },
        grid: {
            hoverable: true,
            clickable: true,
            color: "#909090",
            backgroundColor: (config.background_color != "" ? config.background_color : null)
        },
        zoom: { interactive: true },
        pan: { interactive: true }
    };
    this.plot = function() {
        series_all = [];
        for (var index in config.monitor_sensors) {
            var ms = config.monitor_sensors[index];
            $.ajax({
                url: "/measurements?monitor_sensor_id="+ms.id+"&sensor_id="+ms.sensor_id,
                method: 'GET',
                dataType: 'json',
                success: function(data) {
                    series_all.push(data)
                },
                cache: false,
                async: false
            });
            $.ajax({
                url: "/measurements?monitor_sensor_id="+ms.id+"&sensor_id="+ms.sensor_id+"&alerts=true",
                method: 'GET',
                dataType: 'json',
                success: function(data) {
                    series_all.push(data)
                },
                cache: false,
                async: false
            });
        }
        var plot = $.plot(this.windowDiv, series_all, this.plotOptions);
    }

}

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

    var previousPoint = null;
    $(".monitor-window").live("plothover", function (event, pos, item) {

        if (item) {
            if (previousPoint != item.dataIndex) {
                previousPoint = item.dataIndex;

                $("#data-tooltip").remove();
                var x = item.datapoint[0],
                    y = item.datapoint[1];
                var d1 = new Date();
                x += d1.getTimezoneOffset() * 60000;
                var d = new Date(x);
                var label = item.series.label;
                if (!label) label = "Alert";
                showTooltip(item.pageX, item.pageY, label + " = " + y.toFixed(1) + " at " + d.toLocaleDateString() + " " + d.toLocaleTimeString());
            }
        } else {
            $("#tooltip").remove();
            previousPoint = null;
        }
    });


    // Get all the windows and display them

    $.ajax({
        url: "/monitor_windows.js",
        method: "GET",
        dataType: "json",
        success: function(data) {
            var container_div = document.getElementById("monitors-container");
            for (var index in data.monitor_windows) {
                var config = data.monitor_windows[index];
                // var parser = new DOMParser(), doc = parser.parseFromString(config.html,"text/xml");
                var mw_container_div = document.createElement("div");
                mw_container_div.className = "monitor-container-parent"
                mw_container_div.innerHTML = config.html;
                container_div.appendChild(mw_container_div);
                var placeholder = document.getElementById("mw-"+config.id);
                var mw = new MonitorWindow(config, placeholder);
                mw.plot();
                $('<div class="monitor-config" id="cfg-'+config.id+'" style="right:20px;top:20px"><img src="/assets/config.png" alt="Config" /></div>').appendTo(placeholder).click(function (e) {
                    e.preventDefault();
                    loadDialog("Window", true, this.id.split("-")[1]);
                    return false;
                });
                $('<span class="monitor-title" style="left:50px;top:20px">'+config.name+'</span>').appendTo(placeholder);
             }
        },
        cache: false,
        async: false
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
                    {display: 'Color', name : 'trigger_enabled', width : 70, sortable : true, align: 'left', process: procMS}
                ],
                sortname: "name",
                sortorder: "asc",
                usepager: false,
                width: 'auto',
                title: 'Sensors'
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

// Set up the tooltips for the data points
function showTooltip(x, y, contents) {
    $('<div id="data-tooltip">' + contents + '</div>').css( {
        position: 'absolute',
        display: 'none',
        top: y + 5,
        left: x + 5,
        // border: '1px solid #fdd',
        padding: '2px'
        // 'background-color': '#fee',
        // opacity: 0.80
    }).appendTo("body").fadeIn(200);
}


