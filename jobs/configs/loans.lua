local loansConfig = {}

if SERVER then
    function round(val, decimal)
        local exp = decimal and 10^decimal or 1
        return math.ceil(val * exp - 0.5) / exp
    end

    local function maxPersonalLoanMoney(level)
        return 50000 * level
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

    function updateLoanPayments() 
        local querystring = "SELECT weekOf FROM loan_payments WHERE loanID=@loanID"
        local results = exports["GHMattiMySQL"]:QueryResult(querystring, {loanID = loan.id})
    end

    local MIN_INTEREST_PERSONAL      = 0.075
    local MIN_INTEREST_SECURE           = 0.055
    function createLoan(banker, client, type, amount, interest, weeks)
        if client == nil then
            Citizen.Trace("[ error ] loans config client is null\n")
            return
        end

        if type == "Personal" and interest < MIN_INTEREST_PERSONAL then
            return
        elseif type == "Secure" and interest < MIN_INTEREST_SECURE then
            return
        end
    
        -- Success

        if banker then
            -- If banker is not null
            local querystring = "SELECT totalLoanedOut FROM bankers WHERE cid=@cid"
            local bankerQuery = exports["GHMattiMySQL"]:QueryResult(querystring, {cid = cid})
    
            querystring = "SELECT level FROM user_jobs WHERE cid=@cid"
            local jobsQuery = exports["GHMattiMySQL"]:QueryResult(querystring, {cid = cid})
    
            local maxLoanMoney = loans.maxPersonalLoanMoney(jobsQuery[0].level)
            if bankerQuery + amount > maxLoanMoney then
                return
            end
        end
    
        -- Insert into loans
        local bankerid = banker.cid
        if bankerid == nil then bankerid = -1 end
        local querystring = "INSERT INTO loans (banker, client, type, amount, interest, weeks, end) VALUES (@banker, @client, @type, @amount, @interest, @weeks, TIMESTAMPADD(WEEK, @weeks, CURRENT_TIMESTAMP))"
        exports["GHMattiMySQL"]:Query(querystring, {banker = bankerid, client = client.cid, type = type, amount = amount, interest = interest, currentDebt = currentDebt, weeks = weeks})

        local results = exports["GHMattiMySQL"]:QueryResult("SELECT LAST_INSERT_ID() as id FROM loans")

        -- Inserts weekly payments
        local weeklyPayment = amount / weeks + amount / weeks * interest
        for i = 1, weeks, 1 do
            querystring = "INSERT INTO loan_payments (id, loanid, client, amount, weekOf) VALUES (@id, @loanid, @client, @amount, TIMESTAMPADD(WEEK, @id, CURRENT_TIMESTAMP))"
            exports["GHMattiMySQL"]:Query(querystring, {id = i, loanid = results[1].id, client = client.cid, amount = amount})
        end
    end

    RegisterNetEvent("jobs:payWeeksLoan")
    AddEventHandler("jobs:payWeeksLoan", function(id, loan)
        local querystring = "SELECT ID, client, amount, paided FROM loan_payments WHERE ID=@ID AND loanID=@loanID"
        local results = exports["GHMattiMySQL"]:QueryResult(querystring, {ID=id, loanID = loan.id})
        local loanPayment = results[1]

        if loanPayment == nil or loanPayment.paided then
            return
        end

        print("1 testing loan payments single")
    end)

    RegisterNetEvent("jobs:payAllWeeksLoans")
    AddEventHandler("jobs:payAllWeeksLoans", function(loan)
        local user = vRP.users_by_source[source]
        local querystring = "SELECT ID, client, amount, paided FROM loan_payments WHERE loanID=@loanID"
        local results = exports["GHMattiMySQL"]:QueryResult(querystring, {loanID = loan.id})

        if #results < 1 then return end

        for _, v in pairs(results) do
            if v.paided then return end

            if user:tryFullPayment(v.amount, true) then
                user:tryFullPayment(v.amount, false)
            else
                break
            end
        end

        results = exports["GHMattiMySQL"]:QueryResult("SELECT paided FROM loan_payments WHERE loanID=@loanID", {loanID = loan.id})
        if #results < 1 then
            exports["GHMattiMySQL"]:Query("DELETE loans WHERE id=@id", {id = loan.id})
        end

        print("2 testing loan payments double")
    end)

end