include("history.jl") # utility functions for histories

"""
    AbstractVoice

An `AbstractVoice` is a type that represents any "voice" in an agent workflow.
A voice is a callable struct that can be used to pipe data through a series of
transformations. The voice is the primary way that agents interact with the
world.
"""
abstract type AbstractVoice end

"""
    Voice{P<:AbstractPrompt, M<:AbstractString} <: AbstractVoice

`Voice` is a default voice that has a single prompt.

# Fields
- `prompt::P`: The prompt to use, such as `SimplePrompt()` or
  `SystemPrompt()`.
- `schema::PromptingTools.AbstractPromptSchema`: The schema to use.
"""
struct Voice{P<:AbstractPrompt,M<:AbstractString} <: AbstractVoice
    prompt::P
    schema::PromptingTools.AbstractPromptSchema
    model::M

    function Voice(prompt::P, model::M) where {P<:AbstractPrompt,M<:AbstractString}
        new{P,M}(prompt, DEFAULT_SCHEMA, model)
    end
end

"""
    (v::Voice)(data)

Call the voice `v` with the data `data`. Functionally,
this is equivalent to calling

```julia
PromptingTools.aigenerate(
    v.schema,
    [
        PromptingTools.SystemMessage(v.prompt),
        PromptingTools.UserMessage(data),
    ],
)
```
"""
function (v::Voice)(data)
    return PromptingTools.aigenerate(
        v.schema,
        prepare(v.prompt, data),
        model=v.model,
        return_all=true
    )
end

get_sys(history) = history |> reverse |> (x -> x isa UserMessage) |> first |> vcat

function (v::Voice)(data, history)
    prepped = prepare(v.prompt, data)

    # Flatten the history into a string, wrap it in a UserMessage, and
    # prepend it to the prepped data. We select the most recent (i.e. towards the end)
    # system message to use as the prompt.
    history_summary(history) |> display

    # DEBUG
    # PromptingTools.aigenerate(
    #     v.schema,
    #     vcat(history, prepped),
    #     model=v.model,
    #     return_all=true
    # )
end

"""
    Echo <: AbstractVoice

Simple echo voice that repeats the input data.
"""
struct Echo <: AbstractVoice end
echo(x, model=DEFAULT_LOCAL_MODEL) = Voice(Echo(), model)


"""
    (v::Echo)(data)

Echo the data `data`.
"""
function (v::Echo)(data)
    return data
end

echo_sys(x) = Echo()(sys(x))
echo_user(x) = Echo()(usr(x))
export echo_sys, echo_user

# If we get a string, we echo it back as a user message.
# Convenience function.
(v::Echo)(data::String) = userprompt(data)

# If it's an iterable, we echo it back directly.
(v::Echo)(stuff...) = stuff

"""
    Append <: AbstractVoice

Appends a message into the system by 
appending it to the bottom of the history.

# Fields
- `message::Union{AbstractString, UserMessage}`: The message to Append.

# Examples
```julia
julia> Append("Hello, world!")
Append("Hello, world!")
```

"""
struct Append{MessageType<:Union{}} <: AbstractVoice
    message::MessageType
end

function (v::Append)(history)
    return vcat(history, v.message)
end

export Echo, Append, appendusr, appendsys
appendusr(x) = Append(UserMessage(x))
appendsys(x) = Append(SystemMessage(x))
