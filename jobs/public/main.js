Vue.component('loan', {
    props: ["seen", "loan"],
    template: '<div v-if="seen" class="list-line-div"><li class="list-div">ID: {{loan.id}}, Loaned Amount: {{loan.amount}}$, Weekly Rate: {{loan.interest}}%, Start: {{loan.start}}, End: {{loan.end}}, # of Missed Payments: {{loan.missedPayments}}, Total Interst Owed: {{loan.totalInterest}}$, Current Payment Owed: {{loan.currentInterest}}$, Next Payment Due Date: {{loan.nextDue}}</li>'
    + '<button v-on:click="onClick" type="button" class="btn button-div">Pay Weekly Payment</button>'
    + '<input id="payCurrentAmount" type="text" class="form-control list-input" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-sm">'
    + '<button v-on:click="onClick" type="button" class="btn button-div">Payback Total Amount</button>'
    + '<input id="payTotalAmount" type="text" class="form-control list-input" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-sm"></div>',
    methods: {
        onClick: function (event) {
            let id = $(event.target).parent().html().split(',')[0].split(' ')[2]
            console.log($(event.target).parent().html().split(',')[0].split(' ')[2])
        }
    }
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
        loans: [{id: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},
        {d: 1,amount: 100, interest: 0.2, start: "1/2/51", end: "12/25/2", missedPayments: 2, totalInterest: 50000, currentInterest: 25000, nextDue: "1/1/1"},]
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