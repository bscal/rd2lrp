Vue.component('loan', {
    props: ["seen", "loan"],
    template: '<div v-if="seen" class="list-line-div"><li class="list-div">ID: {{loan.id}}, Loaned Amount: {{loan.amount}}$, Weekly Rate: {{loan.interest}}%, # of Missed Payments: {{loan.missedPayments}}, Total Interst Owed: {{loan.totalInterest}}$, Current Payment Owed: {{loan.currentInterest}}$, Next Payment Due Date: {{loan.nextDue}} Start Date: {{loan.start}}, End Date: {{loan.end}},</li>'
    + '<button id="payCurrentAmount" v-on:click="onClick" type="button" class="btn button-div" data-toggle="tooltip" data-placement="bottom" title="Attempts to pay off your loans weekly payment. Will use bank if not enough cash.">Pay Weekly Payment</button>'
    //+ '<input id="payCurrentAmount" type="text" class="form-control list-input" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-sm">'
    + '<button id="payTotalAmount" v-on:click="onClick" type="button" class="btn button-div" data-toggle="tooltip" data-placement="bottom" title="Will payoff current debt on the loan then will payback current owed amount.">Payback loan</button>'
    + '<input id="inputTotalAmount" type="text" class="form-control list-input" aria-label="Sizing example input" aria-describedby="inputGroup-sizing-sm">$</div>',
    methods: {
        onClick: function (event) {
            let target = event.target
            let id = $(target).parent().html().split(',')[0].split(' ')[2]
            let button = $(target).attr("id")
            let input = $(target).parent().find("#inputTotalAmount")
            console.log(id, button, $(input).val())
            jobsPressed(id, $(input).html(), $(input).val())
        }
    }
})

function jobsPressed(loanid, elementid, value) {
    $.post('http://jobs/onPressed', JSON.stringify({
        loanid: loanid,
        elementid: elementid,
        value: value
    }));
}

Vue.component('player', {
    props: ["seen", "name",],
    template: '<p v-if="seen">Loans for: {{name}}</p>'
})

Vue.component('money', {
    props: ["seen", "cash", "bank",],
    template: '<p v-if="seen">Current Cash: {{cash}}$ | Bank Account Balance: {{bank}}$</p>'
})

var app = new Vue({
    el: '#app',
    data: {
        title: "Loan Management",
        seen: false,
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
            $(document.body).show();
            vm.seen = true
            vm.loans = data.loans
            vm.name = data.name
            vm.cash = data.cash
            vm.bank = data.bank
            toggleVisible("#container", true)
        }
        else {
            $(document.body).hide();
            vm.seen = false
            toggleVisible("#container", false)
        }
    }
    else if (data.type == "click") {
        Click(cursorX - 1, cursorY - 1);
    }
});

$(function() {
    $(document.body).hide();
    $("#container").hide()

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

$(function () {
    $('[data-toggle="tooltip"]').tooltip()
})