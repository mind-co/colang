# Imports
using PromptingTools

# Evaluation context type
abstract type AbstractCreatureType end
struct Animal{S<:AbstractString} <: AbstractCreatureType 
    name::S
end
struct Human{S<:AbstractString} <: AbstractCreatureType 
    name::S
end
struct Other{S<:AbstractString} <: AbstractCreatureType
    type::S # Leave room to fill out the type if it's not an animal or human
    name::S
end

# Methods for extracting fields
name(creature::AbstractCreatureType) = creature.name
creaturetype(creature::Other) = creature.type
creaturetype(creature::Animal) = "animal"
creaturetype(creature::Human) = "human"

# Return type 
struct CreatureType{C<:Union{Animal, Human, Other}}
    type::C
end

# Dispatch on the evaluation context type
function describecreature(creature::AbstractCreatureType)
    return "It looks like this $(creaturetype(creature)) is named $(creature.name)."
end

# Macro @classify to classify the input and return the appropriate creature type
macro classify(input)
    # Call `aiextract`
    rt = aiextract(input; return_type=CreatureType)

    # Return the content
    return rt.content
end

# Function to evaluate an aribtrary string
function evaluate(input)
    # Set up messages
    messages = [
        PromptingTools.SystemMessage("I am evaluating the input.")
    ]
    
end

@classify "dolphin"