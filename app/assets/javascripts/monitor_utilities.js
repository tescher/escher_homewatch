// Monitor window creation and rendering code, used in multiple views

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
                    if ((now.valueOf() - series['data'][0][0]) > 60*60*1000) {  //If data more than an hour old, signify
                        old = true;
                    }
                    last_value = parseFloat(series['data'][0][1]).toFixed(1).toString();
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
            min: ((!config.x_axis_auto && config.x_axis_days != "") ? now_utc.getTime() - 1000*60*60*24*config.x_axis_days : null),
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
        if (config.monitor_sensors.length < 1) {
            finishPlot(this);
        } else {
            for (var index in config.monitor_sensors) {
                if (config.monitor_sensors[index].alerts_only || (config.snapshot && (config.monitor_type == "table")))  {
                    series_total++
                } else {
                    series_total += 2
                }
            }
            for (var index in config.monitor_sensors) {
                var ms = config.monitor_sensors[index];
                var that = this;
                start_date = ((!config.x_axis_auto && config.x_axis_days != "") ? new Date(now_utc.getTime() - 1000 * 60 * 60 * 24 * config.x_axis_days) : null);
                if (!ms.alerts_only) {
                    $.ajax({
                        url: "/measurements?type=" + config.monitor_type + (ms.id? "&monitor_sensor_id=" + ms.id : "") + (config.snapshot ? "&snapshot=true": "") + (config.monitor_type == "table" ? "&limit=25" : "") +  "&sensor_id=" + ms.sensor_id + (start_date ? "+&start=" + $.datepicker.formatDate("yy-mm-dd", start_date) : ""),
                        method: 'GET',
                        dataType: 'json',
                        success: function (data) {
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
                if (config.monitor_type == "graph" || !config.snapshot) {
                    $.ajax({
                        url: "/measurements?type=" + config.monitor_type + (ms.id ? "&monitor_sensor_id=" + ms.id : "") + "&sensor_id=" + ms.sensor_id + "&alerts=true" + (start_date ? "+&start=" + $.datepicker.formatDate("yy-mm-dd", start_date) : ""),
                        method: 'GET',
                        dataType: 'json',
                        success: function (data) {
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
    }

}

function finishPlot(that) {
    var mwControlTop = "20px";
    var mwControlLeft = "50px";
    if (that.config.monitor_type == "graph") {
        var plot = $.plot(that.windowDiv, that.series_all, that.plotOptions);
        $('div.legend').className = "legend ui-corner-all";
    } else {
        that.series_all.rows.sort(function(a,b) {return b.cell[0] - a.cell[0]});
        mwControlTop = "8px";
        mwControlLeft = "15px";
        var flex = $("#flexMonitor_"+that.config.id).flexigrid(
            {
                dataType: 'json',
                colModel : (that.config.snapshot) ? [
                    {display: 'Time', name : 'time', width : 200, sortable : true, align: 'left'},
                    {display: 'Raw Val', name : 'raw', width : 70, sortable : false, align: 'left'},
                    {display: 'Calc Val', name : 'value', width : 70, sortable : false, align: 'left'}
                ] : [
                    {display: 'Time', name : 'time', width : 170, sortable : true, align: 'left'},
                    {display: 'Sensor', name : 'sensor', width : 120, sortable : false, align: 'left'},
                    {display: 'Value', name : 'value', width : 70, sortable : false, align: 'left'}
                ],
                usepager: false,
                width: 'auto',
                height: (that.config.width == 'small') ? 200 : 500,
                title: that.config.snapshot ? "Recent Values" : "&nbsp;&nbsp;&nbsp;.",
                onSuccess : function () {
                    $("#flexMonitor_"+that.config.id+" tr").each ( function () {
                        var cell = $('td[abbr="time"] >div', this);
                        // $(cell).css("background-color", (cell.text() && (cell.text != "auto") ? cell.text() : "#FFFFFF"));
                        var d = new Date(parseInt(cell.text()));
                        $(cell).html($.datepicker.formatDate('DD, M d, yy', d) + ", " + niceTime(d));
                    })
                }

            }
        );
        $(flex).flexAddData({ total: that.series_all["total"], rows: that.series_all["rows"]});
        $(flex).addClass("mw-"+that.config.width);

        //$(flex).flexReload();

    }

    if (!that.config.snapshot) {
        if (typeof public_token == 'undefined') {
            $('<div class="monitor-config" id="cfg-' + that.config.id + '" style="right:20px;top:' + mwControlTop + '"><img src="/assets/config.png" alt="Config" /></div>').appendTo(that.windowDiv).click(function (e) {
                e.preventDefault();
                loadDialog("Window", true, this.id.split("-")[1]);
                return false;
            });
        }
        $('<div class="monitor-move" id="ref-' + that.config.id + '" style="right:60px;top:' + mwControlTop + '"><img src="/assets/move.png" alt="Move" /></div>').appendTo(that.windowDiv);
    }
    $('<div class="monitor-refresh" id="ref-'+that.config.id+'" style="right:40px;top:'+mwControlTop+'"><img src="/assets/refresh.png" alt="Refresh" /></div>').appendTo(that.windowDiv).click(function (e) {
        e.preventDefault();
        mw[this.id.split("-")[1]].display();
        return false;
    });
    if (!that.config.snapshot) {
        $('<span class="monitor-title ui-corner-all" style="left:'+mwControlLeft+';top:'+mwControlTop+'">'+that.config.name+'</span>').appendTo(that.windowDiv);
    }


    $(that.windowDiv).find(".screenblock").hide().remove();
};

// Set up the tooltips for the data points

var previousPoint = null;
$(".monitor-window").bind("plothover", function (event, pos, item) {

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

function showTooltip(x, y, contents) {
    $('<div id="data-tooltip">' + contents + '</div>').css( {
        position: 'absolute',
        display: 'none',
        top: y + 10,
        left: x + 10,
        padding: '2px'
    }).appendTo("body").fadeIn(200);
}


