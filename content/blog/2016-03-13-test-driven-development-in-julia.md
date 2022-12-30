---
title: 'Test Driven Development in Julia'
date: '2016-03-13'
tags:
  - 'tdd'
  - 'julia'
---

First, what is Test Driven Development (TDD)?
Well, I'm not an expert, so don't quote me, but in practice it means that you
develop your code to fulfill tests that you define prior to beginning your work.
You do not define **all** your tests first, though. You define a single test,
and produce code to pass it. Then you define another code, and produce code to
pass both. And so forth until you complete your specification.

This is good because:

- Wherever you stop, you know what is working.
- When you finish, your code already has tests.
- [You don't have to optimize prematurely.](http://c2.com/cgi/wiki?PrematureOptimization)

The steps of TDD can be described as [from
Wikipedia](https://en.wikipedia.org/wiki/Test-driven_development)

1. **Add tests**: These should be useful, _and should fail_.
2. **Run tests**: Verify that the test fails. If not, go back to 1.
3. **Write code**: Write enough code to pass the test.
4. **Run tests**: Verify that **all** tests pass. If some of the tests fail, go back to 3.
5. **Refactor**: Now that everything passes, make the code looks nicer. This is harder for non-seasoned programmers, because it's vague. Essentially, it means removing duplicate code, magic numbers, clarifying names, etc.
6. **Run tests**: Again. Should be done during refactoring, to guarantee you're not breaking anything. But just to be very clear: _your tests should pass at the end of refactoring_.
7. **Repeat**.

This is one way of describing TDD, but there are other. Many others, by the way.
In fact, there are many images describing it, so you can print one and staple it
around.

## Julia

First, we are gonna follow the _package_ layout in Julia.
[This post]({{local_prefix}}/automated-testing/) mentions it at the end.
Basically, we need

- Folder PackageName.jl
  - Folder `src`
  - PackageName.jl
  - Folder `test`
  - runtests.jl
  - README.md
  - LICENSE.md

In our example, we're gonna write a program to convert Roman numbers to decimal,
and vice-versa.
This was inspired by [this
site](http://codingdojo.org/cgi-bin/index.pl?KataRomanNumerals).

**Important: You should use git, but I'll skip it here**

Let's begin writing the outline of the project

```
mkdir RomanNumerals.jl
cd RomanNumerals
mkdir src test
```

```
# File src/RomanNumerals.jl
module RomanNumerals

end
```

```
# File test/runtests.jl
using RomanNumerals

include("test_digits.jl")
```

This defines the building blocks. Note that `test_digits.jl` does not exist. We're
gonna create it to test the individuals digits.

Our testing environment will consist of having a terminal open at all
times at the root of this project. Our testing command will be

```
julia -L src/RomanNumerals.jl test/runtests.jl
```

There are different ways to issue the same command, but this is locally good.

## Tests

Julia comes with a `Base.Test` package, which is the least you should use.
For all basic things it is enough. It provides the `@test` macro, which you can
use as

```
using Base.Test
@test 1 == 1 # This will pass
@test 1 == 0 # This will fail
```

We're gonna go a step beyong and use
[FactCheck.jl](https://github.com/JuliaLang/FactCheck.jl).
This provides more information about the tests.

We're gonna implement the function `roman_to_dec` which receives a string with
roman numerals and returns the decimal equivalent of the number.
With `FactCheck`, our first test will be

```
# File test/test_digits.jl
using FactCheck

facts("Testing digits") do
  @fact roman_to_dec("I") --> 1
end
```

When we run our test, we'll get

```
Testing digits
  Error :: (line:-1)
    Expression: roman_to_dec("I") --> 1
    UndefVarError: roman_to_dec not defined
      ...
```

Look, `roman_to_dec not defined`. Well, let's define it.

```
# File src/RomanNumerals.jl
...
export roman_to_dec

function roman_to_dec(s)
end
...
```

Running again, we get an even better message

```
Testing digits
  Error :: (line:-1) :: fact was false
    Expression: roman_to_dec("I") --> 1
      Expected: 1
      Occurred: nothing
Out of 1 total fact:
  Failed:   1
```

Expected 1, nothing ocurred. Well, that's easy.

```
# File src/RomanNumerals.jl
...
function roman_to_dec(s)
  return 1
end
...
```

```
Testing digits
1 fact verified
```

Done. We're successful. Rejoice. Back to work.

We've written a test, we've tested it, we've written code to fix it, we tested
it. Not much to refactor, this is a silly example.

Repeat. Let's improve the tests.

```
# File test/test_digits.jl
...
facts("Testing digits") do
  @fact roman_to_dec("I") --> 1
  @fact roman_to_dec("V") --> 5
end
```

Running, we obtain

```
Testing digits
  Error :: (line:-1) :: fact was false
    Expression: roman_to_dec("V") --> 5
      Expected: 5
      Occurred: 1
Out of 2 total fact:
  Verified: 1
  Failed:   1
```

Now, that's better. Improving the code.

```
# File src/RomanNumerals.jl
...
function roman_to_dec(s)
  if s == "I"
    return 1
  else
    return 5
  end
end
...
```

This too will pass. Notice that this example is very silly. It is instructional,
of course. On a real application, you could start with all digits at once, for
instance.

More tests and solutions:

```
# File test/test_digits.jl
...
facts("Testing digits") do
  @fact roman_to_dec("I") --> 1
  @fact roman_to_dec("V") --> 5
  @fact roman_to_dec("X") --> 10
end
```

```
# File src/RomanNumerals.jl
...
function roman_to_dec(s)
  if s == "I"
    return 1
  elseif s == "V"
    return 5
  else
    return 10
  end
end
...
```

Now we can refactor, because it's getting very ugly.

```
# File src/RomanNumerals.jl
...
const digits = Dict("I"=>1, "V"=>5, "X"=>10)

function roman_to_dec(s)
  return digits[s]
end
...
```

We can also refactor the test.

```
# File test/test_digits.jl
...
facts("Testing digits") do
  for (digit,value) in [("I",1), ("V",5), ("X",10)]
    @fact roman_to_dec(digit) --> value
  end
end
```

Test. Now we can add more tests for digits, and it will be much easier (because
it's refactored) to both create the test and to solve it.

Understanding the logic now, you can add all the rest of the digits at once.
**Remember to test before start fixing,** even though is very easy now.
This could be a breaking moment on your code. If, when trying to fix it, you
realize it's not as simple as you expected. Remove the test, and add a smaller
one. At this time it will be very useful to have been using git.

```
# File test/test_digits.jl
...
facts("Testing digits") do
  for (digit,value) in [("I",1), ("V",5), ("X",10), ("L",50), ("C",100),
      ("D",500), ("M",1000)]
    @fact roman_to_dec(digit) --> value
  end
end
```

```
# File src/RomanNumerals.jl
...
const digits = Dict("I"=>1, "V"=>5, "X"=>10, "L"=>50, "C"=>100, "D"=>500,
  "M"=>1000)
...
```

## Next test

We've completed a test. Let's do the next.

```
# File test/runtests.jl
using RomanNumerals

include("test_digits.jl")
include("test_double_digits.jl")
```

Double digits are more complex that single digits (by at least at factor of 2?
:) ). Let's break it down using `context`.

```
# File test/test_double_digits.jl
using FactCheck

facts("Testing double digits") do
  context("Repeated digits") do
    @fact roman_to_dec("II") --> 2
  end
end
```

Testing this will fail (as it should), with a `KeyError: II not found`, because
we're using the dictionary, and "II" is not in it.

Before reading the solution, try to fix it yourself. There are many ways to do
it.

```
# File src/RomanNumerals.jl
...
function roman_to_dec(s)
  dec = 0
  for i = 1:length(s)
    dec += digits[s[i:i]]
  end
  return dec
end
```

This fixes it. Now to refactor. You may have noticed that `s[i]` does not work
inside `digits`. That is because julia differentiates characters and single
digits strings (like C, unlike Python). One refactor option is to change the
dictionary to use chars.
Another option is to use a better variable instead of s, since it start to
become a nuisance to read.
Yet another, is to use another way to make the sum.

Since this post explains the usage of TDD, it ends here.
You can continue with this problem until you can make a complete conversor of
roman to decimal.
