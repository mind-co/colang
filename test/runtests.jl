using Revise
using Test

using Co

using Co: Thought, asthought
using Co: Stack, Empty
using Co: @thought_str

# using Aqua
# Aqua.test_all(Co)

# Core thought from string
core = thought"a"
@test core.content == "a"

# Empty thought
empty_thought = Empty()

# Make an empty Stack
stack = Stack(core, new_thought)

# Make a stack with a core thought