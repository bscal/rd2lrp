Vue.component('loan', {
    props: ["seen", "loan"],
    template: '<li class="list-group-item" v-if="seen">{{loan.id}}, {{loan.amount}}</li>'
})

Vue.component('player', {
    data: function() {
        return {
            fname: "lebron",
            lname: "james"
        }
    },
    props: ["seen"],
    template: '<p v-if="seen">Loans for: {{lname}}, {{fname}}</p>'
})

var app = new Vue({
    el: '#app',
    data: {
        title: "Loan Management",
        seen: true,
        loans: [{id: 1,amount: 100},{id: 2,amount: 500}]
    }
})

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

    $.post('http://jobs/clicked', JSON.stringify({
        id: element.attr('id')
    }));
}

window.addEventListener("message", function(event) {
    var data = event.data;
    console.log(`NUIMessage: ${event.data.type}`)
    if (data.type == "display") {
        if (data.enable) {
            vm.seen = true
            vm.loans = data.loans
            vm.user = data.user
        }
        else {
            vm.seen = false
        }
    }
    else if (data.type == "click") {
        Click(cursorX - 1, cursorY - 1);
    }
});

$(function() {
    $(document.body).show();

    $(document).mousemove(function(event) {
        cursorX = event.pageX;
        cursorY = event.pageY;
        UpdateCursorPos();
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('http://jobs/escape', JSON.stringify({}));
        }
    };

    window.addEventListener("contextmenu", function(event) {
        //event.preventDefault();
        $.post('http://jobs/escape', JSON.stringify({}));
    })
});

function toggleVisible(id, visible) {
    (visible) ? $(id).show() : $(id).hide(); 
}

function sendToServer(form) {
    $.post('http://jobs/submit', JSON.stringify({
        id: form.getElementById("id").value
    }));
}