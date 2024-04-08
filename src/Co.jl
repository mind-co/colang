module Co

# An example program that Co.jl should be able to solve.

using PromptingTools

#
# ████████╗██╗   ██╗██████╗ ███████╗███████╗
# ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
#    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
#    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
#    ██║      ██║   ██║     ███████╗███████║
#    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝
# 
# (abstract ones)
# 
"""
An `AbstractThought` is a thought that is accepted or send by a voice.
An `AbstractMemory` is a memory that is something you should take into
account when you are thinking about during your process.
"""
abstract type AbstractThought end
abstract type AbstractMemory end


                                                                                                            
#
# ███╗   ███╗███████╗███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗
# ████╗ ████║██╔════╝████╗ ████║██╔═══██╗██╔══██╗╚██╗ ██╔╝
# ██╔████╔██║█████╗  ██╔████╔██║██║   ██║██████╔╝ ╚████╔╝ 
# ██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██║   ██║██╔══██╗  ╚██╔╝  
# ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║╚██████╔╝██║  ██║   ██║   
# ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   
# 
# Everything you need to manage what you know.
#

"""
`BlankSlate` is a memory that is empty. No information can be added
or removed to it. Please create a [`Stack`](@ref) if you need to
store information.
"""
struct BlankSlate <: AbstractMemory end

"""
`ThoughtArray` is a vector of thoughts.
"""
mutable struct ThoughtArray{A<:Vector{AbstractThought}} <: AbstractMemory
    thoughts::A
end

macro thought_str(raw)
    return :(Thought($raw))
end

ThoughtArray() = ThoughtArray(AbstractThought[])
ThoughtArray(t::AbstractThought) = ThoughtArray([t])
ThoughtArray(t1::AbstractThought, t2::AbstractThought) = ThoughtArray(t1, [t2])


Base.getindex(thoughtArray::ThoughtArray, i::Int) = thoughtArray.thoughts[i]
Base.setindex!(thoughtArray::ThoughtArray, value::AbstractThought, i::Int) = thoughtArray.thoughts[i] = value
Base.push!(thoughtArray::ThoughtArray, thought::AbstractThought) = push!(thoughtArray.thoughts, thought)
Base.pop!(thoughtArray::ThoughtArray) = pop!(thoughtArray.thoughts)
Base.isempty(thoughtArray::ThoughtArray) = isempty(thoughtArray.thoughts)
Base.length(thoughtArray::ThoughtArray) = length(thoughtArray.thoughts)
Base.last(thoughtArray::ThoughtArray) = last(thoughtArray.thoughts)

"""
A `Stack` memory has a vector of thoughts. You can push thoughts onto the stack
and pop thoughts from the stack.

There is an optional `core` thought that is used to guide all processes, 
in the memory. All users of a `Stack` memory will have `core` prepended
to the final prompts.
"""
mutable struct Stack{A,B<:ThoughtArray} <: AbstractMemory
    core::A
    thoughts::B
end

# Constructors
Stack() = Stack(Empty(), ThoughtArray())

"""Get the core thought of a `Stack`."""
core(stack::Stack) = stack.core

Base.getindex(stack::Stack, i::Int) = stack.thoughts[i]
Base.setindex(stack::Stack, i::Int, value::AbstractThought) = stack.thoughts[i] = value
Base.push!(stack::Stack, thought::AbstractThought) = push!(stack.thoughts, thought)
Base.pop!(stack::Stack) = pop!(stack.thoughts)
Base.isempty(stack::Stack) = isempty(stack.thoughts)
Base.length(stack::Stack) = length(stack.thoughts)
Base.last(stack::Stack) = last(stack.thoughts)



#
# ████████╗██╗  ██╗ ██████╗ ██╗   ██╗ ██████╗ ██╗  ██╗████████╗
# ╚══██╔══╝██║  ██║██╔═══██╗██║   ██║██╔════╝ ██║  ██║╚══██╔══╝
#    ██║   ███████║██║   ██║██║   ██║██║  ███╗███████║   ██║   
#    ██║   ██╔══██║██║   ██║██║   ██║██║   ██║██╔══██║   ██║   
#    ██║   ██║  ██║╚██████╔╝╚██████╔╝╚██████╔╝██║  ██║   ██║   
#    ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   
#                                                             
# Little bits of information.
#

"""
Thought is a generic type that has not yet been categorized. `content`
stores the text of the thought.
"""
struct Thought{A<:AbstractString} <: AbstractThought
    content::A
end

struct NumberThought{A<:Number} <: AbstractThought
    content::A
end

"""
    asthought(t::AbstractThought)

Convert an input to a `Thought`. You may define custom methods for
different `AbstractThought` subtypes.
"""
asthought(t::AbstractString) = Thought(t)
asthought(n::Number) = NumberThought(n)
asthought(t::AbstractThought) = t

"""
`Empty` means we can't do anything with the thought.
"""
struct Empty <: AbstractThought end

"""
`CategoricalThought` is a thought that can be categorized.

Has subtypes:
    
- Affirmative/negative: `Yes`, `No`, and `Maybe`.
"""
abstract type CategoricalThought <: AbstractThought end

"""
YesNoMaybe is a categorical type that can be used to represent
yes, no, or maybe.
"""
abstract type YesNoMaybe <: AbstractThought end
struct Yes <: YesNoMaybe end
struct No <: YesNoMaybe end
struct Maybe <: YesNoMaybe end

yesnomaybe(thought::AbstractThought) = yesnomaybe(BlankSlate(), thought)
yesnomaybe(memory::AbstractMemory, thought::AbstractThought) = yesnomaybe(memory, thought)

"""
`makestart` is a helper function that ensures the `start` string
begins with the `character`. The result of `makestart(start, character)`
is the `start` string if it begins with `character`, otherwise
`character * start`.

# Arguments
- `start::String`: The string to be modified.
- `character::Char`: The character to be added to the start of the string.

# Returns
- `String`: The modified string.

```julia
makestart(start, character) = first(start) == character ? start : character * start
```

"""
makestart(start, character) = first(start) == character ? start : character * start

"""
`wrap` is a helper function that wraps a `thought` with `start` and `finish`.
The result of `wrap(thought, start, finish)` is `start * thought * finish`.
"""
wrap(thought, start, finish) = makestart(start, '\n') * thought * finish
wrap(thought) = wrap(thought, "---BEGIN THOUGHT---", "--- END THOUGHT ---")

"""
    contains_concept(context, thought, concept)

Check if the `thought` contains the `concept`. For a `thought`
to contain a `concept`, it must seem relevant or related to the `concept`.

For example, 

$wrap("Janine mentioned that she hasn't received my package yet")

would return `true` because the listener may need to investigate
what happened to the package.
"""
contains_concept(thought, concept) = contains_concept(BlankSlate(), thought, concept)
function contains_concept(context::AbstractMemory, thought, concept) 
    # Prompt the LLM to determine if the thought contains the concept.
    prepared_thought = wrap(thought)
    system_prompt = """
    You identify whether a concept seems to be related to a thought.
    You are given a `thought` and a `concept`.
    """
    user_prompt = "Consider the thought $prepared_thought. Does it contain the concept $concept?"
    return PromptingTools.aigenerate(
        [PromptingTools.SystemMessage(system_prompt), PromptingTools.UserMessage(user_prompt)],
        verbose=true
    )
    # 
end

"""
    contains_affirmative(response)

Check if the `response` is an affirmative response.
"""
contains_affirmative(thought, concept ) = contains_affirmative(BlankSlate(), thought, concept)
function contains_affirmative(context::AbstractMemory, thought, concept)
    return contains_concept(context, thought, affirmative)
end

"""
    tasks(context, thought)    
    tasks(context, thought)

The {tasks} function accepts a `thought` (a piece of text) and
returns a bullet-pointed list of tasks that are contained in the
thought. If no tasks are found, the function returns "{no-task}".

# Arguments
- `thought::String`: A piece of text that may contain tasks.

# Returns
- `String`: A bullet-pointed list of tasks or "{no-task}".

"""
tasks(thought) = tasks(BlankSlate(), asthought(thought))
function tasks(context::AbstractMemory, thought::Thought) # Retrict to only Thoughts that have not yet been processed
    # Check first if there is any indication that thought
    # contains a task for any party.
    return contains_concept(context, thought, "task")
    if contains_concept(context, thought, "task")
        # Extract it
        task_list = []

        # Get a list of tasks.
        task_list = PromptingTools.aigenerate(
            [PromptingTools.SystemMessage(sysprompt), PromptingTools.UserMessage(prompt)],
        )

        # Check if there's tasks left to mine.
        # prepared_thought = wrap(
        #     thought, 
        #     "---BEGIN THOUGHT---", 
        #     "--- END THOUGHT ---"
        # )
        # sysprompt = "You are an expert task extractor. Your role is to review a document of almost any form and attempt to extract tasks. Another has indicated that there are functions that can be used to extract tasks. You should use these Julia functions to extract tasks from the document: \nItemize([INSERT_TASK_STRING])"
        # prompt = "Consider the thought $prepared_thought Are there tasks in this thought (marked with ---BEGIN TASK--- and ---END TASK---) that could be itemized?"


        println(prompt)

        return PromptingTools.aigenerate(
            [
                PromptingTools.SystemMessage(sysprompt),
                PromptingTools.UserMessage(prompt)
            ],
        )

        # Keep checking for tasks until there are none left.
        # while !fully_mined(context, tasklist, thought, Task())
        #     # Get the next task
        #     ## TODO #2 and "emit log" as an @info-style macro. kick message to upstream logger.
        #     task_candidates = mine(context, thought, Task())

        #     push!(task_list, task)
        # end
    else
        # Otherwise return an empty thought.
        return Empty()
    end
end

end # module

