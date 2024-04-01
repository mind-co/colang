module Co

using PromptingTools

const DEFAULT_SCHEMA = PromptingTools.OllamaSchema()
const DEFAULT_LOCAL_MODEL = "phi"

# Retyping
const AbstractMessage = PromptingTools.AbstractMessage
const SysMessage = PromptingTools.SystemMessage
const UserMessage = PromptingTools.UserMessage

# 
# Function shortcuts
# 
"""
    sys(x)::SysMessage

Shortcut for `SysMessage(x)`.
"""
sys(x) = SysMessage(x)
export sys

"""
    usr(x)::UserMessage

Shortcut for `UserMessage(x)`.
"""
usr(x) = UserMessage(x)
export usr

# 
# Includes for the module
# 
include("prompts.jl") # goes first, no deps
include("voice.jl") # goes second because it uses AbstractPromt

end # end module

using .Co
using .Co: echo_sys, echo_user

# Test the simple prompt
prompt = Co.SimplePrompt()
voice = Co.Voice(prompt, "phi")
history = echo_sys("System message")
history = echo_user("My name is Cameron, I make an artificial general intelligence.")
history = (Co.Append())(history, Co.usr("I am a cat."))

# # Test the system prompt
# sys = Co.SystemPrompt()
# voice = Co.Voice(sys, "phi")
# cat_response = voice("You are a cat.")

# # Ask cat to respond again
# cat_redux("You are a cat.", cat_response)

# explorer = Co.Voice(Co.SystemPrompt(), "phi")
# explorer("You are an interrogater. Ask questions to learn as much as possible.", cat_response)