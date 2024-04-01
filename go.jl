using PromptingTools

default_model = "dolphin2.2-mistral:7b-q6_K"
# include("src/Co.jl")

# Evaluation context type
struct Memory{S<:AbstractString}
    content::S
end

function evaluate(context, model, query)
    # Prepare the context

end

function overview(model, query)
    # Generate the next thought
    return [PromptingTools.SystemMessage("I am generating an overview of the recipe for $food.")]
end

function recipe(food)
    # Create an overview of the recipe
    plan = overview(model, "Please give me a high-level overview of the recipe for $food.")
end