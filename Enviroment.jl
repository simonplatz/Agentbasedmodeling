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

function initialize(; numagents=2, price=100, totalCoinAmount=10000)
  properties = Dict(
    :price => price, # initial price
    :totalCoinAmount => totalCoinAmount, # how many coins exist
  )

  ms = MarketScheduler(0.5)

  # the space is nothing by default
  model = ABM(
    TradingAgent;
    properties=properties, scheduler=ms
  )

  balance = totalCoinAmount / numagents # start all with equal balance
  sell_buy = 0.7 # the initial sell/buy is neutral
  volatilityScore = Random.rand(Float64) * 2 # randomly assign how volatile the trader should be 

  for n in 1:numagents
    agent = TradingAgent(n, balance, sell_buy, volatilityScore)
    add_agent!(agent, model)
  end

  return model
end


tradesPerTick = 1
maxCoinsPerTrade = 10
wantToBuy = 9
amount = 10
price = 100
function trader_step!(agent, model)
  # detemine sell_buy
  println(agent.sell_buy)
  usablebalance = agent.balance / 5
  agent.balance = agent.balance - usablebalance
  if (model.news < 0.33) # negative news
    agent.sell_buy = agent.sell_buy / (1.5 * agent.volatilityScore)
  elseif (model.news > 0.66) # positive news
    agent.sell_buy = agent.sell_buy * (1.5 * agent.volatilityScore)
  end

  if (agent.sell_buy < 0.33) ## sellq
  elseif (agent.sell_buy > 0.66) ## buy
    buy(model, usablebalance)

  end

end

model = initialize()

step!(model, trader_step!, 2)

println(random_agent(model))

function buy(model, usablebalance)
  amount = 0
  while usablebalance % amount == 0 && amount < 10
    amount += 1
  end
  if amount < maxCoinsPerTrade
    priceIncreasePercentage = amount / 10
    global model.properties.price += model.properties.price * priceIncreasePercentage

    return

  else
    println("too many damn coins")
    return

  end
  return
end


#function optimization(wantToBuy)
#    if wantToBuy >= 10
#        buy(amount, price)
#        return
#    end
#    return
#end

#function priceChange(price)
#    n = Random.rand(Float16)
#    x = Random.rand((0, 1))
#    news = n + x
#    if news < 0.3
#        news = 0.3
#        price = price * news
#        println(news)
#        return price
#    end
#    println(news)
#    global price = price * news
#    return price
#end

#optimization(wantToBuy)
#stringPrice = string(price)
#priceChange(price)
# println("price ", model.properties.totalCoinAmount)

