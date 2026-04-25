---
title: "TestItems - Modern Julia testing"
date: '2026-04-25'
image: '/blog/2026-04-25.jpg'
tags:
  - 'julia'
  - 'test'
  - 'testitem'
  - 'youtube'
  - 'ai'
  - 'llm'
---

This post is the written companion for my video on [TestItems](https://youtu.be/vr2P9t-EnuU).
Liking and subscribing there is appreciated.

TestItems is a modern testing framework for Julia allowing parallel testing, isolation, setup steps, and filtering.
It has a nice VSCode integration, and through TestItemRunner, it can be used with Revise to automatically rerun tests, or by AI agents via julia-mcp to improve iteration speed.
The official website is <https://julia-testitems.org/>.

This post is aimed at anyone developing packages in Julia.

Summary:

- Organize test in `@testitem`s, they are isolated test groups
- Use `@run_package_tests` from `TestItemRunner` to au
- Use `@testsnippets` and `@testmodule` to setup multiple tests at once
- Add tags and filter by them, or test and file names
- Use through VSCode, `Revise.entr`, or AI agents (via julia-mcp)

## Set up the example package

We **need** a package to use TestItems properly, so we will kickstart one using [BestieTemplate](https://github.com/JuliaBesties/BestieTemplate.jl).
Feel free to write one down by hand, if you haven't installed Bestie yet, otherwise, we recommend installed Bestie in the global or a shared environment:

```julia-repl
pkg> activate --shared bestie
(@bestie) pkg> add BestieTemplate
julia> using BestieTemplate
julia> BestieTemplate.new_pkg_quick("LikeNSub.jl", "abelsiqueira", "Abel Soares Siqueira <abel.s.siqueira@gmail.com", :tiny)
```

A tiny package will be created with Julia files `src/LikeNSub.jl` and `test/runtests.jl`, and these will be our main files.

## Introduction to TestItems and TestItemRunner

Julia already has an official testing package, part of the standard library, called `Test`.
With `Test` you can create named `@testset`s and run tests with `@test <condition>` and other convenience functions like `@test_logs` and `@test_throws`.
These are still the main functions, so let's focus on the extras.

### Getting started (`@testitem` and `@run_package_tests`)

A new `@testitem` defines a new group of tests, and can be added anywhere in the folder of the package.
Normal approaches are to add them to the `test` folder or directly inline in the code, but they could be in files in other places as well.

The way I've been using it, is to have files `test-<something>.jl` in the `test` folders, as I was before using `TestItems` anyway.

Following that approach, let's create `test/test-item-examples.jl` with something like the following:

```julia
# File test/test-item-examples.jl
@testitem "Basic example" begin
  @test 1 + 1 == 2
  @test_broken 1 - 1 > 0
  @test_throws DomainError sqrt(-1.0)
  @testset "Blah $x" for x = 1:3
    @test isapprox(exp(log(x)), x)
  end
end
```

Just having `@testitem`s won't be enough to integrate them into the tests.
We also need a way to run them, and that is achieved by the package `TestItemRunner`.

So, open Julia and activate the `test/` environment, and add **only** `TestItemRunner`:

```julia-repl
pkg> activate test/
(LikeNSub/test) pkg> add TestItems, TestItemRunner
```

To test that things are working as expected, do the following:

```julia-repl
julia> using TestItemRunner
julia> @run_package_tests
Test Summary: | Pass  Broken  Total  Time
Package       |    5       1      6  0.5s

julia> @run_package_tests verbose=true
Test Summary:                            | Pass  Broken  Total  Time
Package                                  |    5       1      6  0.1s
  LikeNSub.jl/test/test-item-examples.jl |    5       1      6  0.1s
    Basic 1                              |    5       1      6  0.1s
      Blah 1                             |    1              1  0.0s
      Blah 2                             |    1              1  0.0s
      Blah 3                             |    1              1  0.0s
```

We can notice a few interesting things:

- `LikeNSub`, `Test`, and `TestItems` are automatically imported by `TestItemRunner`
  - It is possible to inhibit this behaviour by using `default_imports=false` in the `@testitem` call.
- The files are automatically identified by the runner, so we don't have to do any `include`ing.
- Normal `Test` syntax works, so it's easy to migrate

### Setup multiple tests with `@testsnippet` and `@testmodule`

Both `@testsnippet` and `@testmodule` allow us to create setup steps that we can attach to our tests.
The snippets will be run for each test item, while the module will be run once.
Furthermore, the module objects are stored inside a new module, as named by `@testmodule`, while the snippet objects are plainly available.

As example, consider a new file `test/test-setup-examples.jl`:

```julia
# File test/test-setup-examples.jl
@testsnippet BasicSnippetSetup begin
  @info "On @testsnippet"

  test_snippet_var = 1

  function test_snippet_foo()
    return 3.14
  end

  @kwdef mutable struct TestsSnippetStruct
    s :: String = "alice"
  end
end

@testsnippet ExtraSnippet begin
  @info "On extra snippet"
end

@testmodule BasicModuleSetup begin
  @info "On @testmodule"

  test_module_var = 2

  function test_module_foo()
    return 6.66
  end

  @kwdef mutable struct TestModuleStruct
    s :: String = "bob"
  end
end

@testsnippet ExtraModule begin
  @info "On extra module"
end

@testitem "Example with snippet and setup 1" setup = [BasicSnippetSetup, BasicModuleSetup] begin
  @test test_snippet_var == 1
  @test BasicModuleSetup.test_module_var == 2
end

@testitem "Example with snippet and setup 2" setup = [BasicModuleSetup, BasicSnippetSetup] begin
  @test test_snippet_foo() == 3.14
  @test BasicModuleSetup.test_module_foo() == 6.66
end

@testitem "Example with snippet and setup 3" setup = [ExtraSnippet, ExtraModule, BasicModuleSetup, BasicSnippetSetup] begin
  @test TestsSnippetStruct().s == "alice"
  @test BasicModuleSetup.TestModuleStruct().s == "bob"
end
```

Running the `@run_package_tests` will give us:

```julia-repl
julia> @run_package_tests verbose=true
[ Info: On @testmodule
[ Info: On @testsnippet
[ Info: On @testsnippet
[ Info: On extra snippet
[ Info: On extra module
[ Info: On @testsnippet
Test Summary:                             | Pass  Broken  Total  Time
Package                                   |   11       1     12  0.1s
  LikeNSub.jl/test/test-setup-examples.jl |    6              6  0.0s
    Example with snippet and setup 1      |    2              2  0.0s
    Example with snippet and setup 2      |    2              2  0.0s
    Example with snippet and setup 3      |    2              2  0.0s
...
```

Some remarks:

- The order of setup execution seems to be per testitem, but inside the testitem, it doesn't necessarily follows the listed `setup` order.
  - I.e., don't assume execution order.
- `@testmodule` can be used for expensive operations, and must be accessed via the module syntax.
- `@testsnippet` should be used for less expensive operations.
- It is not possible to have setup steps depending on other setup steps.

### Test filtering and tags

One of the most relevant features of test items is the `filter` argument of `@run_package_tests`.
Try the following:

```julia-repl
julia> @run_package_tests filter=test_item->(println(test_item); true)
(filename = "<path>/test-setup-examples.jl", name = "Example with snippet and setup 1", tags = Symbol[])
(filename = "<path>/test-setup-examples.jl", name = "Example with snippet and setup 2", tags = Symbol[])
(filename = "<path>/test-setup-examples.jl", name = "Example with snippet and setup 3", tags = Symbol[])
(filename = "<path>/test-item-examples.jl", name = "Basic 1", tags = Symbol[])
```

We can see that test items actually keep some extra information and that we can filter the tests that we want to run using them.
For instance,

```julia-repl
julia> @run_package_tests verbose=false filter=ti->contains(ti.filename, "item-example")
Test Summary: | Pass  Broken  Total  Time
Package       |    5       1      6  0.1s
```

Notably, we can also see that there is a tags field, that we haven't used.
So let's create a new test to use it, `test/test-item-tags.jl`:

```julia
# File test/test-item-tags.jl
@testitem "Unit test 1" tags = [:unit, :math, :fast] begin
  @test true
end

@testitem "Unit test 2" tags = [:unit, :ui, :slow] begin
  @test true
end

@testitem "Integration test 1" tags = [:integration, :slow] begin
  @test true
end
```

Using it is as simple as before:

```julia-repl
julia> @run_package_tests verbose=true filter=ti->:unit in ti.tags
Test Summary:                        | Pass  Total  Time
Package                              |    2      2  0.0s
  LikeNSub.jl/test/test-item-tags.jl |    2      2  0.0s
    Unit test 1                      |    1      1  0.0s
    Unit test 2                      |    1      1  0.0s

julia> @run_package_tests verbose=true filter=ti->contains(ti.filename, "tags") && !(:slow in ti.tags)
Test Summary:                        | Pass  Total  Time
Package                              |    1      1  0.0s
  LikeNSub.jl/test/test-item-tags.jl |    1      1  0.0s
    Unit test 1                      |    1      1  0.0s
```

## Integrating in your workflow

### runtests.jl

To make sure that your normal `Pkg.test()` usage keeps running, you should

- Add `TestItemRunner` to your `test` environment
- Add `using TestItemRunner` to your `test/runtests.jl` file
- Run `@run_package_tests verbose=true` in your `test/runtests.jl` file

It is also recommended to add your other files that have `@testitem`s, since it doesn't create any overhead and it allows Julia to parse these files to catch any errors before running the tests.

### Integrate on VScode

Given the nature of blog posts, it is especially annoying to try to explain the usage of a graphical tool like VSCode.
So let me just list the relevant remarks, and link to further resources:

- [Related video](https://youtu.be/vr2P9t-EnuU)
- [Official documentation for test item](https://www.julia-vscode.org/docs/stable/userguide/testitems/)

Relevant remarks:

- The VSCode Julia extension comes with the tests integration
- We can run test items via buttons in the test files directly
- It is possible to run tests from the "Testing" tab
- Julia processes remain open, allowing fast testing
- Parallel testing is possible
- Debugging and code coverage are available

### `entr` to run tests automatically in a loop

There is a command line tool called [`entr`](https://eradman.com/entrproject/) that allows you to run arbitrary commands when files change, and `Revise.jl` has a `entr` function that works in a similar way:

```julia
Revise.entr(FILES, MODULES) do
  # Commands that run whenever FILES change or one of MODULES change.
end
```

Using `entr` we can implement or fix tests and see the tests run quickly on the side:

```julia
julia> Revise.entr(["test/test-item-tags.jl"], [LikeNSub]) do
           try
               @run_package_tests verbose=true filter=ti->contains(ti.filename, "item-tags")
           catch ex
               @error ex
           end
       end
```

This way, we can just keep the terminal open on the side, and keep implementing and fixing the tests.

### Integrating with an AI coding agent via julia-mcp

If you're using AI agents, you should consider [julia-mcp](https://github.com/aplavin/julia-mcp).
It allows running Julia code while keeping the Julia process alive, per environment, which is perfect for our TestItem usage.
You need to clone it and run the relevant `mcp add` or similar command.

Make sure to create a [AGENTS.md](https://agents.md) file or similar to inform your agent on how to use. Something like the following might be useful:

```plaintext
### Julia MCP

To run Julia code or tests, use the [Julia MCP](https://github.com/aplavin/julia-mcp). It maintains a warm session and avoids recompilation on every run.

Use `env_path` with the **absolute path** to the `test/` directory (e.g., `/full/path/to/test/`). The test env has its own `Project.toml` with the package as a path source. 

Always run `using TestItemRunner` first, then call `@run_package_tests verbose=... filter=...`. The filter is a Julia function applied to the TestItem object. Some filter options:

- Filter by file: `filter=ti->contains(ti.filename, "part-of-filename")`
- Filter by name: `filter=ti->contains(ti.name, "part-of-test-name")`
- Filter by tags: `filter=ti->all(tag in ti.tags for tag in [:unit, :fast])`
- Exclude slow tests: `filter=ti->!(:slow in ti.tags)`
```

The agent can now run the tests quickly, making developer speed much better.

### Bestie's testitem_cli script

[BestieTemplate](https://github.com/JuliaBesties/BestieTemplate.jl) provides a script to parse command line arguments into a filter.
Running `BestieTemplate.add_feature(:testitem_cli)` will modify `test/runtests.jl` to create a full solution that allows running the testitems from the terminal, such as

```bash
julia --project=test test/runtests.jl --tags fast
```

It is less relevant now, given the other options

### TestItemREPL

It is also worth mentioning that there is a new package in development for managing the testitem via the REPL: [TestItemREPL](https://julia-testitems.org/guide/repl).
It is very new, and I haven't tested enough to have an opinion about it.

## Closing notes

Thanks for checking out this post and video.
If you found this useful and want to support me, liking the video and subscribing to my channel help a lot.
