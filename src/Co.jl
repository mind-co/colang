module Co

using PromptingTools

@enum Affirmative y n unknown_affirmative

############## 
# Yes no bot #
##############
function set_system_personality(personality)
    # Generate the next thought
    return [PromptingTools.SystemMessage(personality)]
end
function add_thought(thought, thoughts)
    return vcat(thoughts, PromptingTools.UserMessage(thought))
end

const AFFIRMATIVE_QUESTION = "your role is to respond \"y\" or \"n\" to the following questions."

# Types for the underlying thoughts. This is a way of modelling a "yes/no" question to a
# language model. If the language model response with only "y" or "n", then we can be
# confident that the response is a "yes" or "no". If the response is anything else, then
# we say the thought has "farted" in that it is not interpretable as a "yes" or "no".
#
# One way to handle the fart problem is to save the result from the yesno function and then
# pass it to a secondary function that asks "does the document specified suggest an affirmative?"
# This is a way of handling the "fart" problem.
abstract type AbstractThoughtBool end
struct ThoughtYes <: AbstractThoughtBool end # whether the thought is true
struct ThoughtNo <: AbstractThoughtBool end # whether the thought is false
struct Fart <: AbstractThoughtBool end # whether the thought is a fart, meaning it failed

struct ThoughtBool{R<:AbstractThoughtBool}
    answer::R
    response::String
end
ttrue() = ThoughtBool(ThoughtYes(), "")
tfalse() = ThoughtBool(ThoughtNo(), "")
tfart() = ThoughtBool(Fart(), "")

# Show methods
import Base.show
show(io::IO, t::ThoughtBool{ThoughtYes}) = show(io, 'y')
show(io::IO, t::ThoughtBool{ThoughtNo}) = show(io, 'n')
show(io::IO, t::ThoughtBool{Fart}) = show(io, '?')

String(t::ThoughtBool{ThoughtYes}) = "y"
String(t::ThoughtBool{ThoughtNo}) = "n"
String(t::ThoughtBool{Fart}) = "?"

Char(t::ThoughtBool{ThoughtYes}) = 'y'
Char(t::ThoughtBool{ThoughtNo}) = 'n'
Char(t::ThoughtBool{Fart}) = '?'

# Summary functions
poll(t::Vector{ThoughtBool}) = join(Char.(t))
poll(t::ThoughtBool) = Char(t)

# Mean/median/mode functions
import Statistics: mean, median

## TODO This has the issue that, for complicated queries,
##      fewer voices will non-fart. This means that
##      the mean will be biased towards a few volatile voices,
##      which may be relatively chaotic. 
mean(t::Vector{ThoughtBool}) = mean(yes.(t))
median(t::Vector{ThoughtBool}) = median(yes.(t))
mode(t::Vector{ThoughtBool}) = mode(yes.(t))

"""if y, then ThoughtYes. If n, then ThoughtNo. Otherwise, Fart."""
function ThoughtBool(s::AbstractString)
    z = lowercase(s) # Prevents Y and N from being interpreted as "yes" and "no"
    if z == "y" || z == "yes" # SHould relax this with fine tuning or something
        return ttrue()
    elseif z == "n" || z == "no"
        return tfalse()
    else
        @warn "ThoughtBool: Farted with $s"
        return tfart()
    end
end

# Bool types
yes(t::ThoughtBool{ThoughtYes}) = true
yes(t::ThoughtBool) = false # Catches no/fart
no(t::ThoughtBool{ThoughtNo}) = true
no(t::ThoughtBool) = false # Catches yes/fartfart(t::ThoughtBool{Fart}) = true
fart(t::ThoughtBool) = false # Catches yes/no

# Boolean addition
function +(t1::ThoughtBool, t2::ThoughtBool)
    if yes(t1) && yes(t2)
        return ttrue()
    elseif no(t1) && no(t2)
        return tfalse()
    else
        return tfart()
    end
end

prop_yes(t::Vector{ThoughtBool}) = sum(yes.(t)) / length(t)
prop_no(t::Vector{ThoughtBool}) = sum(no.(t)) / length(t)
prop_fart(t::Vector{ThoughtBool}) = sum(fart.(t)) / length(t)

# Boolean multiplication
function *(t1::ThoughtBool, t2::ThoughtBool)
    if yes(t1) && yes(t2)
        return ttrue()
    elseif no(t1) && no(t2)
        return tfalse()
    else
        return tfart()
    end
end

# Boolean negation
import Base.!
function !(t::ThoughtBool)
    if yes(t)
        return tfalse()
    elseif no(t)
        return ttrue()
    else
        return tfart()
    end
end

# Boolean disjunction
function ∨(t1::ThoughtBool, t2::ThoughtBool)
    if yes(t1) || yes(t2)
        return ttrue()
    elseif no(t1) && no(t2)
        return tfalse()
    else
        return tfart()
    end
end

# Boolean conjunction
function ∧(t1::ThoughtBool, t2::ThoughtBool)
    if yes(t1) && yes(t2)
        return ttrue()
    elseif no(t1) || no(t2)
        return tfalse()
    else
        return tfart()
    end
end

# Boolean implication
function →(t1::ThoughtBool, t2::ThoughtBool)
    if yes(t1) && no(t2)
        return tfalse()
    elseif no(t1) || yes(t2)
        return ttrue()
    else
        return tfart()
    end
end


"""
Returns a `ThoughtBool` that represents the answer to the question.

# Arguments
- `question::String`: The question to ask the bot.

# Returns
- `ThoughtBool`: The answer to the question.

`ThoughtBool` is a type that represents the answer to a question. 
It can be `ThoughtYes`, `ThoughtNo`, or `Fart`.

How it works:

- If the comind responds with "y", then the return value is `ThoughtYes`.
- If the comind responds with "n", then the return value is `ThoughtNo`.
- Otherwise, the return value is `Fart`.

A `Fart` is a thought that is not interpretable as a "yes" or "no".

# Example
```julia
question = "user: Tell me, do you want to go to the movies?"
yesorno(question)
```
"""
function yesorno(question)
    # 
    messages = vcat(
        set_system_personality(AFFIRMATIVE_QUESTION),
        PromptingTools.UserMessage(question)
    )

    # 
    schema = PromptingTools.OllamaSchema()
    generated = PromptingTools.aigenerate(schema, messages; model="openhermes2.5-mistral", verbose=false)
    content = generated.content
    return ThoughtBool(content)
end

end # end module