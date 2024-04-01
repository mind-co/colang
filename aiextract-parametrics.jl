using PromptingTools

# Return types
abstract type AbstractThing end
struct Dolphin <: AbstractThing end
struct NotDolphin <: AbstractThing end

# Wrapper type
struct ThingHolder{C<:AbstractThing}
    dolphin_or_not::C
end

# Wrapper type that works
struct ThingHolder2
    dolphin_or_not::Union{Dolphin,NotDolphin}
end

# Call aiextract
tester = "Look it's probably a dolphin."
a = aiextract(tester; return_type=ThingHolder)
b = aiextract(tester; return_type=ThingHolder2)

@enum CreatureType animal person other

function f(x)
    # Check first if this is about a person or an animal. The return type of 
    # creaturetype must be CreatureType in this case.
    creaturetype = @classify x CreatureType

    # Dispatch on returned value
    if creaturetype == animal
        return "It's an animal."
    elseif creaturetype == person
        return "It's a person."
    else
        return "It's something else."
    end
end

using Statistics

@enum CreatureType animal person other

struct ClassifiedProbability
    classifications::Vector{CreatureType}
end

function probof(classified::ClassifiedProbability, t::CreatureType)
    # Return mean of types equal to `t`
    return mean(x -> x == t, classified.classifications)
end

probof(ClassifiedProbability([animal, animal, person, animal]), animal) # 0.75

# Get all probabilities
function probabilities(classified::ClassifiedProbability)
    # Return a dictionary of probabilities
    num_instances = length(instances(CreatureType))
    probs = zeros(num_instances)

    for c in classified.classifications
        probs[Int(c)+1] += 1.0
    end

    return probs ./ length(classified.classifications)
end

probabilities(ClassifiedProbability([animal, animal, person, animal])) # [0.75, 0.25, 0.0]