

global price = 100
totalCoinAmount = 1000
global coinsLeft = 1000
tradesPerTick = 1
maxCoinsPerTrade = 10

wantToBuy = 11
amount = 10


function buy(amount, price)
    ##coinsLeft -= amount
    if amount < maxCoinsPerTrade
        priceIncreasePercentage = amount / 10
        global price += price * priceIncreasePercentage
        return

    else
        println("too many damn coins")
        return

    end
    return
end
function optimization(wantToBuy)
    if wantToBuy >= 10
        buy(amount, price)
        return
    end
    return
end


optimization(wantToBuy)
stringPrice = string(price)
println("price " + stringPrice)

