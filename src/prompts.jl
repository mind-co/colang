"""
    AbstractPrompt

An `AbstractPrompt` is a type that represents a prompt,
which is a type or container than can be used to generate
a set of messages to send to a language model.

Prompts may include a personality which should go into
a user message, or may define a general functional transform
of incoming data to a prompt.
"""
abstract type AbstractPrompt end

struct Prompt{
    SystemType<:Union{Missing,AbstractString},
    HeadType<:Union{Missing,AbstractString},
    TailType<:Union{Missing,AbstractString},
} <: AbstractPrompt
    uuid::Base.UUID
    system::SystemType
    head_prompt::HeadType
    tail_prompt::TailType
    # TODO #1 add structure_prompt, .json
end

function prepare(prompt::Prompt, data)
    return [
        PromptingTools.SystemMessage(prompt.system),
        PromptingTools.UserMessage(prompt.head_prompt),
        PromptingTools.UserMessage(data),
        PromptingTools.UserMessage(prompt.tail_prompt),
    ]
end

"""
    SimplePrompt <: AbstractPrompt

A `SimplePrompt` is a prompt that contains no information --
evaluating an `AbstractVoice` with a `SimplePrompt` will
simply put the data into the user message.

# Examples
```julia
julia> prepare(Co.SimplePrompt(), "Hello, world!")
1-element Vector{PromptingTools.UserMessage}:
 PromptingTools.UserMessage("Hello, world!")
```

# See also
- [`prepare`](@ref)
"""
struct SimplePrompt <: AbstractPrompt end

"""
    prepare(prompt::SimplePrompt, data)

Prepare a `SimplePrompt` with the data `data`.

# Arguments
- `prompt::SimplePrompt`: The prompt to prepare.
- `data`: The data to prepare.

# Returns
- An array `[PromptingTools.UserMessage(data)]`.

# Examples
```julia
julia> prepare(Co.SimplePrompt(), "Hello, world!")
1-element Vector{PromptingTools.UserMessage}:
 PromptingTools.UserMessage("Hello, world!")
```

# See alos
- [`SimplePrompt`](@ref)
"""
function prepare(prompt::SimplePrompt, data)
    return [PromptingTools.UserMessage(data)]
end

"""
    SystemPrompt <: AbstractPrompt

A `SystemPrompt` is a prompt that contains no information --
evaluating an `AbstractVoice` with a `SystemPrompt` will
simply put the data into the system message.

# Examples
```julia
julia> prepare(Co.SystemPrompt(), "Hello, world!")
1-element Vector{PromptingTools.SystemMessage}:
 PromptingTools.SystemMessage("Hello, world!")
```

# See also
- [`prepare`](@ref)
"""
struct SystemPrompt <: AbstractPrompt end

"""
    prepare(prompt::SystemPrompt, data)

Prepare a `SystemPrompt` with the data `data`.

# Arguments
- `prompt::SystemPrompt`: The prompt to prepare.
- `data`: The data to prepare.

# Returns
- An array `[PromptingTools.SystemMessage(data)]`.

# Examples
```julia
julia> prepare(Co.SystemPrompt(), "Hello, world!")
1-element Vector{PromptingTools.SystemMessage}:
 PromptingTools.SystemMessage("Hello, world!")
```
"""
function prepare(prompt::SystemPrompt, data)
    return [PromptingTools.SystemMessage(data)]
end