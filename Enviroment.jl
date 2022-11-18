

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

function priceChange(price)
    n = Random.rand(Float16)
    x = Random.rand((0, 1))
    news = n + x
    if news < 0.3
        news = 0.3
        price = price * news
        println(news)
        return price
    end
    println(news)
    global price = price * news
    return price
end
#optimization(wantToBuy)
#stringPrice = string(price)
priceChange(price)
println("price ", price)

