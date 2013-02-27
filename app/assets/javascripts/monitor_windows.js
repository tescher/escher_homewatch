var mw_id = null;
var mw_token = null;
var mw = [];

// Window object
function MonitorWindow(config, windowDiv) {
    var now = new Date();
    var now_utc = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),  now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds());
    this.config = config;
    this.series_all = [];
    this.windowDiv = windowDiv;
    this.plotOptions = {
        series: {
            lines: { show: false },
            shadowSize: 0
        },
        lines: { show: true, lineWidth: 1 },
        points: { show: false },
        colors: ["#ffff40", "#40ff40", "#40ffff", "#ff40ff", "#c0c040", "#40c040", "#40c0c0", "#c040c0"],
        legend: {
            backgroundColor: "#eeeeee",
            color: "#000000",
            show: (config.legend),
            position: "sw",
            labelFormatter: function(label, series) {
                // series is the series object for the label
                // console.log(getSQLts(now));
                var old = false;
                // console.log(legend_data[0][sensor_id]['ts']);
                var last_value = "";
                var limit_reached = false;
                var formatted = '<span id="legend">' + label + " (";
                var last = series['data'].length - 1;
                if (last >= 0) {
                    if ((now.valueOf() - series['data'][last][0]) > 60*60*1000) {  //If data more than an hour old, signify
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
            zoomAmount: 1.25,
            min: ((!config.y_axis_min_auto && config.y_axis_min != "") ? config.y_axis_min : -10),
            max: ((!config.y_axis_max_auto && config.y_axis_max != "") ? config.y_axis_max : 120)
        },
        xaxis: {
            mode: "time", timeformat: "%b %d",
            min: ((!config.x_axis_auto && config.x_axis_days != "") ? now_utc - 1000*60*60*24*config.x_axis_days : null),
            minTickSize: [1, "day"],
            monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
            zoomAmount: 1.25,
            timezone: "browser",
            color: "#909090"
        },
        grid: {
            hoverable: true,
            clickable: true,
            color: "#909090",
            backgroundColor: ((!config.background_color_auto && config.background_color != "") ? config.background_color : "white"),
            borderWidth: 2
        },
        zoom: { interactive: true },
        pan: { interactive: true }
    };
    this.display = function() {
        this.series_all = [];
        this.config = config;
        var color_count = 0;
        var series_count = 0;
        var series_total = 0;
        $('<div class="screenblock"></div>').appendTo(this.windowDiv).show();
        for (var index in config.monitor_sensors) {
            if (config.monitor_sensors[index].alerts_only) {
                series_total++
            } else {
                series_total += 2
            }
        }
        for (var index in config.monitor_sensors) {
            var ms = config.monitor_sensors[index];
            var that = this;
            if (!ms.alerts_only) {
                $.ajax({
                    url: "/measurements?type="+config.monitor_type+"&monitor_sensor_id="+ms.id+"&sensor_id="+ms.sensor_id,
                    method: 'GET',
                    dataType: 'json',
                    success: function(data) {
                        if (that.config.monitor_type == "graph") {
                            ++color_count;
                            if (data.color_auto || (data.color == "")) {
                                data.color = color_count;
                            }
                            that.series_all.push(data)
                        } else {
                            if (!that.series_all["rows"]) {
                                that.series_all["rows"] = [];
                                that.series_all["total"] = 0;
                            }
                            that.series_all["rows"] = that.series_all["rows"].concat(data.rows);
                            that.series_all["total"] += data.total;
                        }
                        ++series_count;
                        if (series_count == series_total) {
                            finishPlot(that);
                        }
                    },
                    cache: false,
                    async: true
                });
            }
            $.ajax({
                url: "/measurements?type="+config.monitor_type+"&monitor_sensor_id="+ms.id+"&sensor_id="+ms.sensor_id+"&alerts=true",
                method: 'GET',
                dataType: 'json',
                success: function(data) {
                    if (that.config.monitor_type == "graph") {
                        that.series_all.push(data)
                    } else {
                        if (!that.series_all["rows"]) {
                            that.series_all["rows"] = [];
                            that.series_all["total"] = 0;
                        }
                        that.series_all["rows"] = that.series_all["rows"].concat(data.rows);
                        that.series_all["total"] += data.total;
                    }
                    ++series_count;
                    if (series_count == series_total) {
                        finishPlot(that);
                    }
                },
                cache: false,
                async: true
            });
        }
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
                // x += d1.getTimezoneOffset() * 60000;
                var d = new Date(x);
                var label = item.series.label;
                if (!label) label = "<span style='color:red;font-weight:bold'>Alert</span>";
                showTooltip(item.pageX, item.pageY, $.datepicker.formatDate('DD, M d, yy', d) + ", " + niceTime(d) + "<br/>" + label + ": " + y.toFixed(1));
            }
        } else {
            $("#data-tooltip").remove();
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
                var mw_container_div = document.createElement("div");
                mw_container_div.className = "monitor-container-parent mw-parent-" + config.width;
                mw_container_div.innerHTML = config.html;
                container_div.appendChild(mw_container_div);
                var placeholder = document.getElementById("mw-"+config.id);
                mw[config.id] = new MonitorWindow(config, placeholder);
                mw[config.id].display();
             }
        },
        cache: false,
        async: false
    })


});

function finishPlot(that) {
    var mwControlTop = "20px";
    if (that.config.monitor_type == "graph") {
        var plot = $.plot(that.windowDiv, that.series_all, that.plotOptions);
        $('<span class="monitor-title ui-corner-all" style="left:50px;top:20px">'+that.config.name+'</span>').appendTo(that.windowDiv);
        $('div.legend').className = "legend ui-corner-all";
    } else {
        mwControlTop = "8px";
        var flex = $("#flexMonitor_"+that.config.id).flexigrid(
            {
                dataType: 'json',
                colModel : [
                    {display: 'Time', name : 'sensor', width : 100, sortable : true, align: 'left'},
                    {display: 'Sensor', name : 'legend', width : 100, sortable : true, align: 'left'},
                    {display: 'Value', name : 'color', width : 70, sortable : true, align: 'left'}
                ],
                sortname: "name",
                sortorder: "asc",
                usepager: false,
                width: 'auto',
                title: that.config.name
            }
        );
        $(flex).flexAddData({ total: that.series_all["total"], rows: that.series_all["rows"]});
        $(flex).addClass("mw-"+that.config.width);

        //$(flex).flexReload();

    }

    $('<div class="monitor-config" id="cfg-'+that.config.id+'" style="right:20px;top:'+mwControlTop+'"><img src="/assets/config.png" alt="Config" /></div>').appendTo(that.windowDiv).click(function (e) {
        e.preventDefault();
        loadDialog("Window", true, this.id.split("-")[1]);
        return false;
    });
    $('<div class="monitor-refresh" id="ref-'+that.config.id+'" style="right:40px;top:'+mwControlTop+'"><img src="/assets/refresh.png" alt="Config" /></div>').appendTo(that.windowDiv).click(function (e) {
        e.preventDefault();
        mw[this.id.split("-")[1]].display();
        return false;
    });

    $(that.windowDiv).find(".screenblock").hide().remove();
};

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

// Set up the tooltips for the data points
function showTooltip(x, y, contents) {
    $('<div id="data-tooltip">' + contents + '</div>').css( {
        position: 'absolute',
        display: 'none',
        top: y + 10,
        left: x + 10,
        padding: '2px'
     }).appendTo("body").fadeIn(200);
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




