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

    $.post('http://utils/clicked', JSON.stringify({
        id: element.attr('id')
    }));
}

window.addEventListener("message", function(event) {
    var data = event.data;
    console.log(`NUIMessage: ${event.data.type}`)
    if (data.type == "display") {
        if (data.enable) {
            $(document.body).show();
            $("#main").show()
            console.log("showing")
        }
        else {
            $(document.body).hide();
            $("#main").hide()
            $("#contacts").hide()
            console.log("hiding")
            return;
        }
    }

    else if (data.type == "contacts") {
        $("#main").hide()
        $("#contacts").show()
        $(".contact-list").empty();
        for (var key in data.contacts) {
            if (data.contacts.hasOwnProperty(key)) {
                $(".contact-list").append(`<li><button class="contact-entry" type="button">${key} | ${data.contacts[key]}</button></li>`)
            }
        }
    }

    else if (data.type == "click") {
        Click(cursorX - 1, cursorY - 1);
    }
});

$(function() {
    $(document.body).hide();

    $(document).mousemove(function(event) {
        cursorX = event.pageX;
        cursorY = event.pageY;
        UpdateCursorPos();
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('http://utils/escape', JSON.stringify({}));
        }
    };

    window.addEventListener("contextmenu", function(event) {
        event.preventDefault();
        $.post('http://utils/escape', JSON.stringify({}));
    })
});