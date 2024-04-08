# co

co is a linguistic programming language, built on top of [Julia](https://julialang.org). Make AIs and stuff.

Written by Cameron Pfiffer. I run [mindco](https://github.com/mind-co/), an organization creating [comind](https://www.comind.me). co is to support that. There is a [Patreon](https://www.patreon.com/Comind) if you would like to support my work.

co is intended to make linguistic programming simple, straightforward, and functional. At the same time, it is intended to provide programmatic structure for larger and complicated language programs.

## the motivating principle

co is an attempt to visualize a future for language models as drivers of a __linguistic program__. In a linguistic program, agent workflows are not simply a composition of strings, but a strongly typed system of modular functions and components. It should be trivial for me to program something that works simply, quickly, and deterministically.

Consider the following example:

```julia
function tasks(memory::AbstractMemory, thought::AbstractThought)
    # Task list
    task_list = ExtractTask[]

    # 
    while x = task(memory, thought)
        push!(task_list, x)
    end
end

function task(memory::AbstractMemory, thought::AbstractThought)
    # Get task memory, containing relevant information put into
    # the memory by the task extractor. This is a subset of 
    # memory that is only relevant to this group of tasks.
    task_memory = from(memory, ExtractTask())

    # Check if there's any 


    return contains_affirmative(context, thought, concept)
end
```

## co features

### voice composition

co's design is centered around a `Voice`. A `Voice` is simply a callable type that maps a `memory` and a `thought` to a new `thought`. All voices must return a subtype of `AbstractThought`.

A `Voice` is intended to be a simple composable function. For example, this should be possible for a user to specify:

```julia
memory = BlankSlate() # We don't know anything right now, empty memory

# A thought from an asker (either the user or another voice)
thought = "I need to buy apples, a some jalapenos, and a bag of grapes. Oh wait, I think I need four apples for the pie."

# A voice that extracts the task from the thought
bullet_extractor = Voice("Extract the bullet points from this thought.")
bullet_points = bullet_extractor(memory, thought) # call the voice, as it is a callable struct

```

### memory scoping

__Memory scoping__ means "which voices have access to which memories". Memory scoping is a way to ensure that voices can communcate on similar layers of memory. For example, a voice that is reponsible for extracting a task from a user's thought will have access to a "group" memory of all other task extractor processes. This way, each "group" can check whether there are any remaining tasks that have not yet been extracted.

For example, 

- [ ] Function scoping