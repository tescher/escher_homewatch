$(function() {
    $("#flexSensors").flexigrid(
      {
      method: 'GET',
      url: 'sensors.js',
      dataType: 'json',
      colModel : [
        {display: 'Name', name : 'name', width : 100, sortable : true, align: 'left', process: procMe},
        {display: 'Controller', name : 'controller', width : 100, sortable : true, align: 'left', process: procMe},
        {display: 'AlarmEnabled', name : 'trigger_enabled', width : 70, sortable : true, align: 'left', process: procMe},
        {display: 'AlarmHigh', name : 'trigger_upper_limit', width : 70, sortable : true, align: 'left', process: procMe},
        {display: 'AlarmLow', name : 'trigger_lower_limit', width : 70, sortable : true, align: 'left', process: procMe},
        {display: 'AlarmEmail', name : 'trigger_email', width : 100, sortable : true, align: 'left', process: procMe},
        {display: 'AbsAlarm', name : 'absence_alert', width : 70, sortable : true, align: 'left', process: procMe},
        {display: 'User', name: 'user', width: 100, sortable: true, align: 'left', process: procMe}
      ],
      sortname: "name",
      onSuccess: function() {
          $.ajax({
              url: "/sessions/isadmin",
              success: function(data) {
                  if (data == "true") {
                      showColumn('#flexSensors','user', true);
                  } else {
                      showColumn('#flexSensors','user', false);
                  };
              },
              async: false,
              cache: false
          });

      },
      sortorder: "asc",
      usepager: false,
      title: 'Sensors'
      }
    );

    $("#dialogSensors").dialog({
        modal: true,
        disabled: true,
        autoOpen: false,
        width: 800,
        buttons: [{
            text: "Save",
            click: function() {
                $("form[id*='sensor']").submit()
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
            $("#flexSensors").flexReload();
        }
    })

    $("#linkNewSensor").click(function(evt) {
        loadDialog(false, null);
        return false;
    })

    $("form[id*='sensor']").live('ajax:success', function(evt, data) {
        if (data.length < 2) {
            $("#dialogSensors").dialog("close");
        } else {
            $('#dialogSensors').html(data);
        }
    })

});

function procMe(celDiv, id) {
  $(celDiv).click ( function()
  {
    loadDialog(true, id);
    return false;
  });

}

function loadDialog(editing, id) {
    var url = "/sensors/";
    if (editing) {
        url += id + "/edit";
    } else {
        url += "new";
    }
    $.ajax({
        url: url,
        success: function(data) {
            $('#dialogSensors').html(data);
        },
        async: false,
        cache: false
    });
    var buttons =  [{
        text: "Save",
        click: function() {
            $("form[id*='sensor']").submit()
        },
        class: "btn btn-large btn-primary"
    }];

    if (editing) {
        buttons.push({
            text: "Delete",
            click: function() {
                if (confirm("OK to delete?")) {
                    $.ajax({
                      url: "/sensors/" + id,
                      type: "DELETE",
                      success: function(data) {
                          $("#dialogSensors").dialog("close");
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
    $("#dialogSensors").dialog("option", "buttons", buttons);

    $("#dialogSensors").dialog("enable");
    $("#dialogSensors").dialog("open");

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
