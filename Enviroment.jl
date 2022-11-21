using Agents
using Random

mutable struct TradingAgent <: AbstractAgent
  id::Int # id of the agent
  balance::Int # how much money the agent has
  sell_buy::Float64 # whether the agent will sell, buy or hold
  volatilityScore::Float64
end


# here we could add more coins (following some function to simlulate mining)
mutable struct MarketScheduler
  news::Float64
end

# Scheduler which generates news events
function (ms::MarketScheduler)(model::ABM)
  println(model)
  ms.news = Random.rand(Float64)
end

function initialize(; numagents = 50, price = 100, totalCoinAmount = 10000)
  properties = Dict(
    :price => price, # initial price
    :totalCoinAmount => totalCoinAmount, # how many coins exist
  )

  ms = MarketScheduler(0.5)

  # the space is nothing by default
  model = ABM(
    TradingAgent; 
    properties = properties, scheduler = ms
  )

  balance = totalCoinAmount/numagents # start all with equal balance
  sell_buy = 0.5 # the initial sell/buy is neutral
  volatilityScore = Random.rand(Float64) # randomly assign how volatile the trader should be 

  for n in 1:numagents
    agent = TradingAgent(n, balance, sell_buy, volatilityScore)
    add_agent!(agent, model)
  end

  return model
end 


# tradesPerTick = 1
# maxCoinsPerTrade = 10
# wantToBuy = 11
# amount = 10

function trader_step!(agent, model)
  # detemine sell_buy
  
  if (model.news < 0.33) # negative news
    agent.sell_buy = agent.sell_buy/2
  else if (model.news > 0.66) # positive news
    agent.sell_buy = agent.sell_buy*2
  end




end

model = initialize()

step!(model, trader_step!, 2)

println(random_agent(model))

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
# priceChange(price)
# println("price ", price)

