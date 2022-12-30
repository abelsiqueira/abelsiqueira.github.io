---
title: 'Package Development in Julia 1.0 using the REPL'
date: '2018-12-05'
tags:
  - 'julia'
  - 'pkg'
  - 'test'
  - 'dev'
---

This is a quick post on package development in Julia 1.0. Let me know if you're
interested in more, and what.

Suppose you're developing a package - say, `MyPackage.jl` - whether from scratch, or
updating from Julia 0.6.
First, and foremost, you need to be able to run and test it.
On Julia 1.0, this is one possible way, while using the REPL.

**Choose a folder to develop it and create the necessary files**

You'll need

```
- MyPackage.jl/
  - src/
    - MyPackage.jl
  - test/
    - runtests.jl
  - README.md (eventually)
  - LICENSE.md (eventually)
  - .travis.yml (eventually)
```

The file `src/MyPackage.jl` is the file included by Julia when you enter
`Using MyPackage`. `test/runtests.jl` is what is run to test your package. It is
required if you intend to publish your package, but most important, you need to test
your package before trying to publish it. README gives information about your package,
LICENSE gives information about its license, and .travis.yml defines the online testing
with continuous integration by Travis. These are usual, but not require when you're
starting to develop your package.

For instance, consider the following files

```
# src/MyPackage.jl
module MyPackage

export pi_approximation

function pi_approximation()
  return 22.0 / 7.0
end

end # module
```

```
# test/runtests.jl
using MyPackage, Test

function tests()
  @testset "Subset of tests" begin
    @test pi_approximation() ≈ pi atol=1e-2
  end
end

tests()
```

**Open the REPL and add your package under the development version**

_I assume Linux, but this will work with minor modifications on OSX and Windows._

On the terminal, enter julia to open the REPL

```
julia>
```

Enter `pkg` mode by pressing `]`.

```
(v1.0) pkg>
```

Inform `pkg` that your package folder exists and is under development with `dev`.

```
(v1.0) pkg> dev SOME_PATH/MyPackage.jl

[ Info: Assigning UUID XXXXXX to MyPackage
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [XXX] + MyPackage v0.0.0 [`SOME_PATH/MyPackage.jl`]
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [XXX] + MyPackage v0.0.0 [`SOME_PATH/MyPackage.jl`]
```

Check that you can see your package

```
(v1.0) pkg> status
    Status `~/.julia/environments/v1.0/Project.toml`
  ...
  [XXX] MyPackage v0.0.0 [`SOME_PATH/MyPackage.jl`]
  ...
```

Check that everything passes according to your (evil) plan.

```
(v1.0) pkg> test MyPackage
   Testing MyPackage
 Resolving package versions...
    Status `/tmp/tmpO7CsSr/Manifest.toml`
  [XXX] MyPackage v0.0.0 [`SOME_PATH/MyPackage.jl`]
  ...
Test Summary:   | Pass  Total
Subset of tests |    1      1
   Testing MyPackage tests passed
```

When you're done with your package, you can `rm MyPackage` to remove your package from
consideration without deleting the code.

If your package was already released, then it'll have a different version number. Other
differences may apply.
