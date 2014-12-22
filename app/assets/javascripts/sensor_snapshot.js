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



});


