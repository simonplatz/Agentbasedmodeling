using Pkg; Pkg.add("Agents")
Pkg.add("InteractiveDynamics")
Pkg.add("CairoMakie")

using Agents
using InteractiveDynamics
using CairoMakie # choosing a plotting backend

space = GridSpaceSingle((10, 10); periodic = false)
@agent SchellingAgent GridAgent{2} begin
    mood::Bool # whether the agent is happy in its position. (true = happy)
    group::Int # The group of the agent, determines mood as it interacts with neighbors
end

for (name, type) in zip(fieldnames(SchellingAgent), fieldtypes(SchellingAgent))
    println(name, "::", type)
end

mutable struct SchellingAgent <: AbstractAgent
    id::Int             # The identifier number of the agent
    pos::NTuple{2, Int} # The x, y location of the agent on a 2D grid
    mood::Bool          # ...
    group::Int          # ...

end

properties = Dict(:min_to_be_happy => 3)
schelling = ABM(SchellingAgent, space; properties)

schelling2 = ABM(
    SchellingAgent,
    space;
    properties = properties,
    scheduler = Schedulers.ByProperty(:group),
)

function agent_step!(agent, model)
    minhappy = model.min_to_be_happy
    count_neighbors_same_group = 0
    # For each neighbor, get group and compare to current agent's group
    # and increment `count_neighbors_same_group` as appropriately.
    # Here `nearby_agents` (with default arguments) will provide an iterator
    # over the nearby agents one grid point away, which are at most 8.
    for neighbor in nearby_agents(agent, model)
        if agent.group == neighbor.group
            count_neighbors_same_group += 1
        end
    end
    # After counting the neighbors, decide whether or not to move the agent.
    # If count_neighbors_same_group is at least the min_to_be_happy, set the
    # mood to true. Otherwise, move the agent to a random position, and set
    # mood to false.
    if count_neighbors_same_group ≥ minhappy
        agent.mood = true
    else
        agent.mood = false
        move_agent_single!(agent, model)
    end
    return
end


groupcolor(a) = a.group == 1 ? :blue : :orange
groupmarker(a) = a.group == 1 ? :circle : :rect
figure, _ = abmplot(model; ac = groupcolor, am = groupmarker, as = 10)
figure # returning the figure displays it

model = initialize();
abmvideo(
    "schelling.mp4", model, agent_step!;
    ac = groupcolor, am = groupmarker, as = 10,
    framerate = 4, frames = 20,
    title = "Schelling's segregation model"
)
