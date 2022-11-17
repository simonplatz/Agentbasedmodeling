using Agents

@agent Trader NoSpaceAgent begin  
  balance::Int # how much money the agent has
  sell_buy::Float64 # whether the agent will sell, buy or hold
  volatilityScore::Float64
end
