var documentWidth = document.documentElement.clientWidth;
var documentHeight = document.documentElement.clientHeight;

var cursor = document.getElementById("cursor");
var cursorX = documentWidth / 2;
var cursorY = documentHeight / 2;

function UpdateCursorPos() {
    cursor.style.left = cursorX + "px";
    cursor.style.top = cursorY + "px";
}

function Click(x, y) {
    var element = $(document.elementFromPoint(x, y));
    element.focus().click();

    if (element != null) {
        $.post('http://robberies/clicked', JSON.stringify({
            id: element.attr('id'),
            item: element.text()
        }));
    }
}

window.addEventListener("message", function(event) {
    var data = event.data;
    console.log(`NUIMessage: ${event.data.type}`)
    if (data.type == "display") {
        if (data.enable) {
            $(document.body).show();
            cursor.style.display = "block";
        }
        else {
            $(document.body).hide();
            cursor.style.display = "none";
            return;
        }

        // Alter html
        if (data.name == null) {
            $("#yourWeight").text(data.uWeight);
            $("#otherName").hide();
            $("#otherWeight").hide();
        }
        else {
            $("#otherName").show();
            $("#otherWeight").show();
            $("#otherName").text(data.name + "'s Inventory")
        }

        $(".listl").empty();
        for (var key in data.inv) {
            if (data.inv.hasOwnProperty(key)) {
                $(".listl").append(`<li><button id="yours" class="slot" type="button">${key} | ${data.inv[key]}</button></li>`)
            }
        }
        $(".listr").empty();
        for (var key in data.invv) {
            if (data.invv.hasOwnProperty(key)) {
                $(".listr").append(`<li><button class="slot" type="button">${key} | ${data.invv[key]}</button></li>`)
            }
        }
    }
    else if (data.type == "updateWeight") {
        $("#yourWeight").text(data.uWeight);
        $("#otherWeight").text(data.vWeight);
    }

    else if (data.type == "updateInventory") {
        $(".listl").empty();
        for (var key in data.inv) {
            if (data.inv.hasOwnProperty(key)) {
                $(".listl").append(`<li><button class="slot" type="button">${key} | ${data.inv[key]}</button></li>`)
            }
        }
        $(".listr").empty();
        for (var key in data.invv) {
            if (data.invv.hasOwnProperty(key)) {
                $(".listr").append(`<li><button class="slot" type="button">${key} | ${data.invv[key]}</button></li>`)
            }
        }
    }

    else if (data.type == "click") {
        Click(cursorX - 1, cursorY - 1);
    }
});

$(function() {
    $(document).mousemove(function(event) {
        cursorX = event.pageX;
        cursorY = event.pageY;
        UpdateCursorPos();
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('http://robberies/escape', JSON.stringify({}));
        }
    };

    window.addEventListener("contextmenu", function(event) {
        event.preventDefault();
        $.post('http://robberies/escape', JSON.stringify({}));
    })
});