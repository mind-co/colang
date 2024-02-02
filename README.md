# co

co is a linguistic programming language, built on top of [Julia](https://julialang.org). Make AIs and stuff.

Written by Cameron Pfiffer. I run [mindco](https://github.com/mind-co/), an organization creating [comind](https://www.comind.me). Comind is a weird-ass communal thinking tool and AI-interface I'm working on a lot. I hope that'll make money someday for right now I'm having the time of my life.

**There is a [Patreon](https://www.patreon.com/Comind) if you would like to support my work.** Most of this repo is speculative, so the README is more of a manifesto than a declaration of functionality.

co is some internally tooling that has come to resemble very simple computer programs. I think I'd like it to be public. All this AI shit is crazy and I hope we can make it a good thing and not a weird nightmare that ruins all our lives.

**The idea is this**. You have some flow of language. Think a series of interactions with a user,
and you want a complicated chain of language queries to run. Suppose you get a short message from a user, and you have a language function `todo`. `todo` extracts all items from a query that appear to represent a task indicated in the query.

Let's say we had the `Thought`

> dude I fucked up, i forgot to get cat litter and now there's pee all over!

`todo(thought)` would look something like (this won't work but it's the shape)

- Q1: does this contain any tasks
    - A1: yes, buy cat litter, clean the pee
- Q2: list todo items in order, separated by a comma.
    - A2: buy cat litter, clean the pee
- Q3: Assign a priority to each item in the todo list, using P1 (highest priority), P2, and P3 (lowest)
    - A3: buy cat litter (P2), clean the pee (P1)
- Q4: Split on comma

At the end `todo(thought)`, after parsing and doing some stuff, returns a `Vector{Task}`, where `Task` has the fields `priority` and `task`.

co is (supposed to be) a language that lets you write out these chains of language queries in a way that
is easy to read and write.

Currently only has boolean logic. Goals are to support arbitrary complex linguistic queries in a low-overhead way,
as well as a set of primitive language gates that can be used to build up more complex queries.

## Usage

I wouldn't even try yet. You can run some of this but it currently enforces an [ollama](https://ollama.ai) setup. 

## Goals

- [ ] multiple language models. You may want a fine-tuned yes/no model, a fine-tuned model that is good at detecting questions, locations, producing lists, etc. This should be easy to express at the language level.
- [ ] multiple choice questions, i.e. "is this a question or a statement?" or "is this a question, a statement, or a command?"
- [ ] error checking, i.e. "what type of error is this?" as well as other error checks to attempt to correct the problem by investigating,
reading the code, etc.
- [ ] request for location indicated by the user, i.e. "where is this?" or "where is this located?". May be constrained to a region, a part of a room, etc. as dictated by the prompt context.
- [ ] request for a list of items, i.e. "what are the items in this list?" or "what are the items in this list of items?". This should
basically give you a `Vector{ThoughtItem}` representing the extracted thoughts.
    - Useful for queries like "Which items does the person want to buy?" or "What are the items in the person's shopping list?"
- [ ] creating question designs. This is a bit more complex, but it's basically a way to generate a question from a given context. For example, if you have a list of items, you can generate a question like "is there anything missing in the list?" or "what is the most important item in the list?".

It's an early project but I am excited to see where it goes. I'd love to be able to see very large linguistic programs
written in co. Setting up servers? Processing giant amounts of text? Writing whole data pipelines, adjusting to experiments, etc.? I think co could be a great way to do it.

It'll be sick but anyway here's a brief demo.

## Examples

```julia
#
# NOT RUNNABLE YET
# 

# This is a question, something we want a "yes" or "no" answer to.
question = "Does a coin flip heads 50% of the time?"

# We want to ask 10 people and see what they say. Language models are inherently 
# probabilistic, so we can't just ask one person and expect a definitive answer.
# 
# Besides, some people are idiots, and we should expect the same here.
# 
# This bit here asks the question 10 times, and returns a `ThoughtBool` representing
# a "yes" or "no" answer.
answers = Co.yesorno.(repeat([question], 10))

# We can then poll the answers to see what the consensus is.
# For this answer, you should expect to get all "yes" or all "no" answers.
println("Question: $question")
```

Since I anticipate doing this kind of stuff at actually a fairly large scale (lots of voices, lots of questions, etc.), I want to produce a token-dense representation of the results. A vector of voices
yields a string that can be passed later to another query.

I'm calling these dense representations `polls`. A `poll` is a difficult to read string that represents the results of a query in a series of single-character tokens. For example, booleans in this system
can be either `y` for yes, `n` for no, and `?` for brain fart. 

Brain farts (or, just "farts") are a special case, because they indicate that your language program did not produce an interpretable answer. In other words, the model has spun out, and you will need to do some extra work to handle cases where there is an abnormal amount of brain farting.

Specifically, a __fart__ is a case where the language model did not say something immediately interpretable as a yes or no (either "yes" or "y" are permitted as yeses). This could be because the language model said something like "Yes, but..." or gave a long-winded exclamation.

In our case, we might have something like

```julia
poll(answers)
```

which should yield

```
yyyyyyny?n
```

This indicates that there were 10 answers, and 7 of them were yes, 2 of them were no, and 1 of them was a fart.

