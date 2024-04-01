function replacesysprompt(new_prompts, history)
    # Get the total number of prompts
    n_prompts = length(history) + length(new_prompts)
    history_sysprompts = filter(x -> x isa PromptingTools.SystemMessage, history)
    n_history_sysprompts = length(history_sysprompts)
    n_new_prompts = length(new_prompts)
    new_sysprompts = filter(x -> x isa PromptingTools.SystemMessage, new_prompts)

    new_history = new_sysprompts


    # @info "" n_history_sysprompts n_new_prompts n_prompts
    return new_history
end
