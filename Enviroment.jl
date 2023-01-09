using Agents
using Random
using DelimitedFiles

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

function initialize(; numagents=40, price=10.0, totalCoinAmount=10000, coinLeft=10000)
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

  balance = 100000 # start all with equal balance
  sell_buy = 0.5 # the initial sell/buy is neutral

  coinsOwned = 0
  startBalance = balance

  for n in 1:numagents
    volatilityScore = Random.rand(Float64) * 2   # randomly assign how volatile the trader should be 
    agent = TradingAgent(n, balance, sell_buy, volatilityScore, coinsOwned, startBalance)
    add_agent!(agent, model)
  end

  return model
end


function buy(model, agent)

  amount = 0

  while (agent.balance - ((amount + 1) * model.price)) > 0 && amount < 100 && agent.balance > (amount + 1) * model.price

    amount += 1
    if agent.balance < amount * model.price
      amount -= 1
    end
  end

  if amount <= 100 && agent.balance - model.price * amount > 0 && amount > 0
    model.price += 1
    # priceIncreasePercentage = amount / 100
    agent.balance -= amount * model.price
    println("Price before ", model.price)
    if model.price < 100
      model.price = model.price + (amount * 2)
    elseif model.price < 200
      model.price = model.price + (amount * 3)
    elseif model.price < 300
      model.price = model.price + (amount * 4)
    else
      model.price = model.price + (amount * 5)
    end
    # model.price += model.price * priceIncreasePercentage
    agent.coinsOwned += amount
    model.coinLeft -= amount


    println("Price after ", model.price)
    return

  else
    println("cant buy", amount)
    println(model.price)
    return

  end
  return
end

function sell(model, agent)
  coinsSold = 0
  println("jeg sælger")
  println("sell price ", model.price)
  if model.price < 500 && agent.balance > 100
    coinsSold = agent.coinsOwned * 0.10
    agent.coinsOwned = agent.coinsOwned - coinsSold
    agent.balance += coinsSold * model.price
    if model.price < 100
      model.price = model.price - (coinsSold * 2)
    elseif model.price < 200
      model.price = model.price - (coinsSold * 3)
    elseif model.price < 300
      model.price = model.price - (coinsSold * 4)
    else
      model.price = model.price - (coinsSold * 5)
    end

  elseif model.price > 500 && agent.balance > 100
    coinsSold = agent.coinsOwned / 2
    agent.coinsOwned = agent.coinsOwned - coinsSold
    agent.balance += coinsSold * model.price
    model.price = model.price - (coinsSold * 5)
  elseif agent.balance <= 100
    coinsSold = agent.coinsOwned * 0.9
    agent.coinsOwned = agent.coinsOwned - coinsSold
    agent.balance += coinsSold * model.price
    model.price = model.price - (coinsSold * 5)
  end

  return
end

tradesPerTick = 1
maxCoinsPerTrade = 10
wantToBuy = 9
amount = 10
array = []
function trader_step!(agent, model)
  #println("running trader_step")
  # detemine sell_buy

  agent.sell_buy = 0.5

  if model.price <= 0
    model.price = 10
  end


  if (model.scheduler.news < 0.33) # negative news
    agent.sell_buy = agent.sell_buy / (1.5 * agent.volatilityScore)
  elseif (model.scheduler.news > 0.66) # positive news
    agent.sell_buy = agent.sell_buy * (1.5 * agent.volatilityScore)
  end




  if agent.balance > 3 * agent.startBalance
    agent.sell_buy = agent.sell_buy * 2
  elseif agent.balance < 0.3 * agent.startBalance
    agent.sell_buy = agent.sell_buy / 3
  end



  if model.price > 1500
    agent.sell_buy = agent.sell_buy / (model.price / 1000)
  else
    agent.sell_buy = agent.sell_buy * 2
  end

  if (agent.coinsOwned == 0)
    agent.sell_buy = 1
  end
  if agent.coinsOwned < 1 && agent.balance > model.price
    agent.sell_buy = 1
  end



  println(agent)
  if (agent.sell_buy < 0.43 && agent.coinsOwned >= 1) ## sellq
    println("agent ", agent.id, " selling")
    sell(model, agent)
  elseif (agent.sell_buy > 0.56) ## buy
    println("agent ", agent.id, " buying")
    buy(model, agent)
  elseif agent.sell_buy > 0.43 && agent.sell_buy < 056
    println("agent ", agent.id, " doing nothing")
  else
    println("Agent ", agent.id, " Cant do anything")
  end
  println(agent)
  push!(array, model.price)
end

model = initialize()

step!(model, trader_step!, 10)
println(array)



writedlm("FileName3.csv", array)


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

