---
title: 'NLPModels.jl, CUTEst.jl and other Nonlinear Optimization Packages on Julia'
date: '2017-02-07'
tags:
  - 'julia'
  - 'optimization'
  - 'nlpmodels'
  - 'cutest'
  - 'work'
  - 'juliasmoothoptimizers'
  - 'tutorial'
---

A couple of weeks ago me and Professor [Dominique Orban](https://dpo.github.io) have finally made a release of
CUTEst.jl, a wrapper for the CUTEst repository of problems for nonlinear
optimization (which I've mentioned before).
Along with this release, we've done a release of NLPModels.jl, the underlying
package. I think it's time I explain a little about these packages, others,
and how to use them together.
If you want to see the output of the commands, you can open
[this ASCIInema](https://asciinema.org/a/102371)
side by side.

_Obs.: Tutorial using Julia 0.5.0_

_Edit: Second part is
[here](https://abelsiqueira.github.io{{local_prefix}}nlpmodelsjl-and-cutestjl-constrained-optimization/)._

**JuliaSmoothOptimizers**
[![JuliaSmoothOptimizers logo](https://juliasmoothoptimizers.github.io/assets/logo.png){: .img-view }](https://juliasmoothoptimizers.github.io)

Most packages mentioned here will be a part of the JuliaSmoothOptimizers (JSO)
organization. There are more packages in the organization that I won't mention here, but you should check it out.

**NLPModels.jl**

NLPModels is a package for creating Nonlinear Optimization Models. It is
focused on the needs of the solver writer, such as the ability to write one
solver that works on many models.
The package defines a few models, and there are others on the horizon.
The ones already done are:

- **ADNLPModel**: A model with automatic differentiation;
- **MathProgNLPModel**: A model for [MathProgBase](https://github.com/JuliaOpt/MathProgBase.jl)/[JuMP](http://github.com/JuliaOpt/JuMP.jl) conversion, whose utility will be shown below (obs: MPB and JuMP are packages from the JuliaOpt organization);
- **SimpleNLPModel**: A model in which nothing is automatic, i.e., all functions have to be provided by the user.
- **SlackModel**: A model that changes all inequalities to equalities adding extra variables;
- **LBFGSModel** and **LSR1Model**: Models that create quasi-Newton models from another model.

The first two models are designed to be easy to use; the third is useful for
efficient model creation in specific cases; the last ones are utility models.

Let's begin by installing NLPModels.jl, and a couple of optional requirements.

```
Pkg.add("NLPModels.jl")
Pkg.add("JuMP.jl") # Installs ForwardDiff also.
```

This should install version 0.1.0. After that, just do

```
using NLPModels
```

Now, let's create a simple function: Rosenbrock's.

```
f(x) = (x[1] - 1)^2 + 100*(x[2] - x[1]^2)^2
```

The Rosenbrock problem traditionally starts from $(-1.2,1.0)$.

```
x0 = [-1.2; 1.0]
```

Now, we are ready to create the problem.

```
adnlp = ADNLPModel(f, x0)
```

Now, we can access the function and derivatives using the [NLPModels API](https://juliasmoothoptimizers.github.io/NLPModels.jl/stable/api.html)

```
obj(adnlp, adnlp.meta.x0)
grad(adnlp, adnlp.meta.x0)
hess(adnlp, adnlp.meta.x0)
objgrad(adnlp, adnlp.meta.x0)
hprod(adnlp, adnlp.meta.x0, ones(2))
H = hess_op(adnlp, adnlp.meta.x0)
H * ones(2)
```

At this point, we can't differentiate many things from simply using
`ForwardDiff` interface directly, but two things stand out: `objgrad` returns
both functions at once, and `hess_op` returns a
[LinearOperator](https://github.com/JuliaSmoothOptimizers/LinearOperators.jl),
another structure created in JuliaSmoothOptimizers.
This one defines a linear operator, extending Julia matrices in the sense that if

```
using LinearOperators
n = 100
A = rand(n, n)
B = rand(n, n)
opA = LinearOperator(A)
opB = LinearOperator(B)
v = rand(n)
```

then `(A * B) * v` computes the matrix product, whereas `(opA * opB) * v` won't.
Furthermore, the linear operator can be created from the functions
`v->Mp(v)` and `v->Mtp(v)`, defining the product of the linear operator times a vector and its transpose times a vector.

```
T = LinearOperator(2, 2, # sizes
                   false, false,
                   v->[-v[2]; v[1]], v->[v[2]; -v[1]])
v = rand(2)
T * v
T' * v
```

_Obs: In the `ADNLPModel` case, `hess_op` returns a linear operator that is actually
computing the matrix, but this is a issue to be tackled on the future (PRs
welcome). But we'll be back with uses for `hess_op` soon._

The next model is the `MathProgNLPModel`. This model's main use is the `JuMP`
modelling language. This is very useful for more elaborate writing, specially
with constraints. It does create a little more overhead though, so keep that
in mind.

```
using JuMP
jmp = Model()
@variable(jmp, x[i=1:2], start=(x0[i])) # x0 from before
@NLobjective(jmp, Min, (x[1] - 1)^2 + 100*(x[2] - x[1]^2)^2)
mpbnlp = MathProgNLPModel(jmp)
```

Try the commands again.

```
obj(mpbnlp, mpbnlp.meta.x0)
grad(mpbnlp, mpbnlp.meta.x0)
hess(mpbnlp, mpbnlp.meta.x0)
objgrad(mpbnlp, mpbnlp.meta.x0)
hprod(mpbnlp, mpbnlp.meta.x0, ones(2))
H = hess_op(mpbnlp, mpbnlp.meta.x0)
H * ones(2)
```

It should be pretty much the same, though there is a little difference in `hess`.
JuMP creates the sparse Hessian, which is better, from a computational point of
view.

Notice how the commands are the same. I've actually copy-pasted the commands
from above.
This allows the write of a solver in just a couple of commands.
For instance, a simple **Newton method**.

```
function newton(nlp :: AbstractNLPModel)
  x = nlp.meta.x0
  fx = obj(nlp, x)
  gx = grad(nlp, x)
  ngx = norm(gx)
  while ngx > 1e-6
    Hx = hess(nlp, x)
    d = -gx
    try
      G = chol(Hermitian(Hx, :L)) # Make Cholesky work on lower-only matrix.
      d = -G\(G'\gx)
    catch e
      if !isa(e, Base.LinAlg.PosDefException); rethrow(e); end
    end
    t = 1.0
    xt = x + t * d
    ft = obj(nlp, xt)
    while ft > fx + 0.5 * t * dot(gx, d)
      t *= 0.5
      xt = x + t * d
      ft = obj(nlp, xt)
    end
    x = xt
    fx = ft
    gx = grad(nlp, x)
    ngx = norm(gx)
  end
  return x, fx, ngx
end
```

And we run in the problems with

```
newton(adnlp)
newton(mpbnlp)
```

_Write once, use on problems from different sources._

Now, to have more fun, let's get another package:
[OptimizationProblems.jl](https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl).
This package doesn't have a release yet, so we have to clone it:

```
Pkg.clone("https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl")
```

What we have here is a collection of JuMP models implementing some of the
CUTEst problems. Together with `NLPModels.jl`, we have a good opportunity to test our Newton implementation.

```
using OptimizationProblems

x, fx, ngx = newton(MathProgNLPModel( rosenbrock() ))
x, fx, ngx = newton(MathProgNLPModel( dixmaanj() ))
x, fx, ngx = newton(MathProgNLPModel( brownbs() ))
```

_An issue with OptimizationProblems is that it still doesn't have a way to get
all unconstrained problems, for instance. (PRs are welcome)._

So far we used 3 packages from JSO: `NLPModels.jl`, `LinearOperators.jl` and `OptimizationProblems.jl`. It's time to meet another important package.

**CUTEst.jl**

CUTEst, the Constrained and Unconstrained Testing Environment with safe
threads, is a package written in Fortran providing over a thousand problems to
allow testing of Nonlinear Programming solvers. However, CUTEst is hard to use
by first-timers. Just installing it was already hard.
CUTEst.jl provides an interface for CUTEst that is simple to install and use
(comparing to the original).

_Obs.: CUTEst.jl does not work on Windows for now. In fact, there is no plan to
make it work on Windows because "people interested in doing it"∩"people capable
of doing it" = ∅, as far as we've looked. If you are in this set, PRs are
welcome._

To install CUTEst.jl you need to install something manually. Unfortunately,
this is specific for each system. Except for OSX, actually, which is using
[homebrew-cutest](https://github.com/optimizers/homebrew-cutest).

For Linux users, check out [this
page](http://juliasmoothoptimizers.github.io/CUTEst.jl/latest/#Installing-1).
Essentially, we need `libgfortran.so` in a visible place. And it's especially
annoying that some distritions don't put it in a visible place.

With that done, enter

```
Pkg.add("CUTEst")
```

which should install CUTEst.jl 0.1.0.

Yes, it takes some time.

Finally, we start using CUTEst with

```
using CUTEst

nlp = CUTEstModel("ROSENBR")
```

`ROSENBR` is a CUTEst problem, in case you want the list, see
[here](http://www.cuter.rl.ac.uk/Problems/mastsif.html). Keep reading for a way
to select them, though.

Now, let's solve this CUTEst problem with our Newton method.

```
x, fx, ngx = newton(nlp)
```

**Yes, exactly like before!**.

CUTEst is a little more annoying in other aspect also. Like, you can't have two
or more problems open at the same time, and you have to close this problem
before opening a new one. (Again, PRs are welcome).

```
finalize(nlp)
nlp = CUTEstModel("HIMMELBB")
x, fx, ngx = newton(nlp)
finalize(nlp)
```

This allows a simple workflow for writing optimization solvers.

- Write some problems by hand (using `ADNLPModel` or `MathProgNLPModel`);
- Test your solvers with these hand-written problems;
- Repeat last two steps until you believe you're ready to competitive comparison;
- Test with CUTEst problems seamlessly.

Now, let's get back to `hess_op`. Remember that it used Matrix vector products?
Well, CUTEst has separate functions for the product of the Hessian at a point
and a vector. Which means that `hprod` actually computes this product without
having to create the matrix. Which means it is, at least, memory-efficient.
Furthermore, `hess_op` will be created with the `hprod` function, which means
it is also memory-efficient.

Let's look at a huge problem to feel the difference.

```
nlp = CUTEstModel("BOX")
nlp.meta.nvar
```

Let's make a simple comparison

```
function foo1()
  H = hess(nlp, nlp.meta.x0)
  v = ones(nlp.meta.nvar)
  return Hermitian(H, :L) * v
end

function foo2()
  H = hess_op(nlp, nlp.meta.x0)
  v = ones(nlp.meta.nvar)
  return H * v
end

@time w1 = foo1();
@time w2 = foo2();
norm(w1 - w2)
```

Yes, that's a huge difference.

This is a very good reason to use `hess_op` and `hprod`. But let's take a step further.

We can't implement Cholesky using only `hprod`s, so our Newton method would
actually take a long time to reach a solution for the problem above.
To circunvent that, we could try using the Conjugate Gradients Method instead
of Cholesky. This would only use Hessian-vector products.

We arrive on a new package,
[Krylov.jl](https://github.com/JuliaSmoothOptimizers/Krylov.jl), which
implements Krylov methods. In particular, Conjugate Gradients.
This package is also unreleased, so we need to clone it.

```
Pkg.clone("https://github.com/JuliaSmoothOptimizers/Krylov.jl")
```

Consider a simple example

```
using Krylov
A = rand(3,3)
A = A*A'
b = A*ones(3)
cg(A, b)
```

As expected, the system is solver, and the solution is $(1,1,1)$.
But let's do something more.

```
A = -A
cg(A, b)
```

Yes, Krylov does indeed solves the non-positive definite system using Conjugate Gradient.
Well, actually, a variant.

That's not enough tough. Krylov.jl also accepts an additional argument `radius`
to set a trust-region radius.

```
cg(A, b, radius=0.1)
```

Well, as an exercise I suggest you implement a trust-region version of Newton
method, but for now, let's continue with our line-search version.

We know now how `cg` behaves for non-positive definite systems, we can't make
the changes for a new method.

```
function newton2(nlp :: AbstractNLPModel)
  x = nlp.meta.x0
  fx = obj(nlp, x)
  gx = grad(nlp, x)
  ngx = norm(gx)
  while norm(gx) > 1e-6
    Hx = hess_op(nlp, x)
    d, _ = cg(Hx, -gx)
    slope = dot(gx, d)
    if slope >= 0 # Not a descent direction
      d = -gx
      slope = -dot(d,d)
    end
    t = 1.0
    xt = x + t * d
    ft = obj(nlp, xt)
    while ft > fx + 0.5 * t * slope
      t *= 0.5
      xt = x + t * d
      ft = obj(nlp, xt)
    end
    x = xt
    fx = ft
    gx = grad(nlp, x)
    ngx = norm(gx)
  end
  return x, fx, ngx
end
```

Now, running `newton2` on our large problem, we obtain

```
x, fx, ngx = newton2(nlp)
```

Which is the method working very fast. Less that a second here.

---

There is actually another package I'd like to talk about, but it needs some
more work for it to be ready for a release:

**Optimize.jl**

Optimize.jl is a package with solvers. We intend to implement some high quality
solvers in there, but there is actually more to it. We have in there tools to
benchmark packages. These tools should allow the testing of a set of solvers in
a set of problems without much fuss, while creating the comparison information,
including the performance profile.
It also includes, or will include, "parts" of solvers to create your own
solver. Like trust-region and line-search algorithms and auxiliary functions
and types.
Unfortunately, it's not done enough for me to extend on it, and this is already
getting too long.

**End**

I hope you enjoyed this overview of packages.
Subscribe to the RSS feed to keep updated in future tutorials. I intend to talk
about the constrained part of NLPModels soon.
