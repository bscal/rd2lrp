local loansConfig = {}

function round(val, decimal)
    local exp = decimal and 10^decimal or 1
    return math.ceil(val * exp - 0.5) / exp
end

local function maxPersonalLoanMoney(level)
    return 100000 + 25000 * level
end

local function maxSecureLoanMoney(level)
    return 1000000 + 50000 * level
end

local function getFee(amount)
    return round(amount * 0.01)
end

function loansConfig.getInterestOwed(loan)
    return round(loan.amount / loan.weeks * loan.interest, 0)
end

loansConfig.types = {}

loansConfig.types["Personal Loan"] = {min=0, max=maxPersonalLoanMoney, rate=4.5, penalty=5.0, pay=2.5}

loansConfig.types["Secure Loan"] = {min=250000, max=maxSecureLoanMoney, rate=4.0, penalty=5.0, pay=0.05, fee=getFee}

