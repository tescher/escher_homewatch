var mw = [];

$(function() {
    // Get the sensor we are dealing with

    var sensor_id = $(".page-title").data('id');
    // Get the temp windows and display them

    var url = "/monitor_windows/temp.js?count=1&monitor_type=graph";

    $.ajax({
        url: url,
        method: "GET",
        dataType: "json",
        success: function(data) {
            create_window(data);
        },
        cache: false,
        async: false
    });

    var url = "/monitor_windows/temp.js?count=1&monitor_type=table";

    $.ajax({
        url: url,
        method: "GET",
        dataType: "json",
        success: function(data) {
            create_window(data);
        },
        cache: false,
        async: false
    });

    function create_window(data) {
        var container_div = document.getElementById("monitors-container");
        var config = data.monitor_windows[0];
        // Adjust config for snapshot use
        config.snapshot = true;
        config.width = "small";
        config.monitor_sensors = [{sensor_id: sensor_id}];
        //
        var mw_container_div = document.createElement("div");
        mw_container_div.className = "monitor-container-parent mw-parent-" + config.width;
        mw_container_div.innerHTML = config.html;
        mw_container_div.id = "mc_" + config.id;
        container_div.appendChild(mw_container_div);
        var placeholder = document.getElementById("mw-"+config.id);
        mw[config.id] = new MonitorWindow(config, placeholder);
        mw[config.id].display();
    }

    // Display the restart log tables

    var oLengths = ["Long", "Short"];

    for (i=0; i< oLengths.length; i++) {
        var olen = oLengths[i];
        $("#flexRestarts"+olen).flexigrid(
            {
                method: 'GET',
                url: 'log.js?outage='+olen.toLowerCase(),
                dataType: 'json',
                colModel: [
                    {display: 'Time', name: 'time', width: 200, sortable: true, align: 'left'},
                    {display: 'Outage', name: 'outage', width: 100, sortable: true, align: 'left'},
                    {display: 'Stall Loc', name: 'stall', width: 100, sortable: false, align: 'left'},
                    {display: 'IP', name: 'ip', width: 100, sortable: false, align: 'left'}
                ],
                usepager: false,
                width: 'auto',
                height: 200,
                title: "Controller Restarts, "+olen+" Outages",
                onSuccess: function () {
                    $("#flexRestarts"+olen+" tr").each(function () {
                        var cell = $('td[abbr="time"] >div', this);
                        // $(cell).css("background-color", (cell.text() && (cell.text != "auto") ? cell.text() : "#FFFFFF"));
                        var t = cell.text().split(/[- :TZ]/);
                        var d = new Date(t[0], t[1]-1, t[2], t[3], t[4], t[5]);
                        $(cell).html($.datepicker.formatDate('DD, M d, yy', d) + ", " + niceTime(d));
                        cell = $('td[abbr="outage"] >div', this);
                        $(cell).html(cell.text().toHHMMSS)

                    })
                },
                sortorder: "asc"
            }
        );
    }




});


