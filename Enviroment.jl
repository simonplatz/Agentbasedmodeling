using Agents
using Random

mutable struct TradingAgent <: AbstractAgent
  id::Int # id of the agent
  balance::Float64 # how much money the agent has
  sell_buy::Float64 # whether the agent will sell, buy or hold
  volatilityScore::Float64
  coinsOwned::Float64
  startBalance::Int
end


# here we could add more coins (following some function to simlulate mining)
mutable struct MarketScheduler
  news::Float64
end

# Scheduler which generates news events
function (ms::MarketScheduler)(model::ABM)
  #println(model)
  ms.news = Random.rand(Float64)

  return allids(model)
end

function initialize(; numagents=20, price=100.0, totalCoinAmount=10000, coinLeft=10000)
  properties = Dict(
    :price => price, # initial price
    :totalCoinAmount => totalCoinAmount, # how many coins exist
    :coinLeft => coinLeft
  )

  ms = MarketScheduler(0.5)

  # the space is nothing by default
  model = ABM(
    TradingAgent;
    properties=properties, scheduler=ms
  )

  balance = 10000 # start all with equal balance
  sell_buy = 0.5 # the initial sell/buy is neutral
  volatilityScore = Random.rand(Float64) * 2 # randomly assign how volatile the trader should be 
  coinsOwned = 0
  startBalance = balance

  for n in 1:numagents
    agent = TradingAgent(n, balance, sell_buy, volatilityScore, coinsOwned, startBalance)
    add_agent!(agent, model)
  end

  return model
end


function buy(model, usablebalance, agent)

  amount = 0
  while (usablebalance - (amount * model.price)) > 0 && amount < 10
    amount += 1
  end

  if amount <= maxCoinsPerTrade && agent.balance - model.price > 0
    priceIncreasePercentage = amount / 10
    usablebalance -= amount * model.price
    println("Price before ", model.price)
    model.price += model.price * priceIncreasePercentage
    agent.coinsOwned += amount
    model.coinLeft -= amount
    agent.balance += usablebalance

    println("Price after ", model.price)
    return

  else
    println("too many damn coins")
    return

  end
  return
end

function sell(model, agent)
  coinsSold = 0
  if model.price < 500 && agent.balance > 100
    coinsSold = agent.coinsOwned * 0.10
    agent.coinsOwned = agent.coinsOwned - coinsSold
    agent.balance = coinsSold * model.price
  elseif model.price > 500 && agent.balance > 100
    coinsSold = coinsOwned / 2
    agent.coinsOwned = agent.coinsOwned - coinsSold
    agent.balance = coinsSold * model.price
  elseif agent.balance <= 100
    coinsSold = agent.coinsOwned * 0.9
    agent.coinsOwned = agent.coinsOwned - coinsSold
    agent.balance = coinsSold * model.price
  end

  return
end

tradesPerTick = 1
maxCoinsPerTrade = 10
wantToBuy = 9
amount = 10
function trader_step!(agent, model)
  #println("running trader_step")
  # detemine sell_buy
  if agent.balance - model.price > 0
    usablebalance = agent.balance / 5
    agent.balance = agent.balance - usablebalance
  else
    usablebalance = agent.balance
    agent.balance = agent.balance - usablebalance
  end

  if (model.scheduler.news < 0.33) # negative news
    agent.sell_buy = agent.sell_buy / (1.5 * agent.volatilityScore)
  elseif (model.scheduler.news > 0.66) # positive news
    agent.sell_buy = agent.sell_buy * (1.5 * agent.volatilityScore)
  end

  if agent.balance > 3 * agent.startBalance
    agent.sell_buy = agent.sell_buy * 2
  end
  if (agent.sell_buy < 0.33) ## sellq
    sell(model, agent)
  elseif (agent.sell_buy > 0.66) ## buy
    buy(model, usablebalance, agent)

  end

end

model = initialize()

step!(model, trader_step!, 100)

println(Agents.allagents(model))



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

