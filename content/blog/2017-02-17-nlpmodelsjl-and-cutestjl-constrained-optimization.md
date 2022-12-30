---
title: 'NLPModels.jl and CUTEst.jl: Constrained optimization'
date: '2017-02-17'
tags:
  - 'julia'
  - 'nlpmodels'
  - 'cutest'
  - 'work'
  - 'optimization'
  - 'constrained'
---

This is a continuation of [this
post](https://abelsiqueira.github.io{{local_prefix}}nlpmodelsjl-cutestjl-and-other-nonlinear-optimization-packages-on-julia/).
And again, you can follow the commands of this post in the
[asciinema](https://asciinema.org/a/103654).

If you followed along last post, you should know the basics of our
NLPModels API, including CUTEst access.

One thing I didn't explore, though, was constrained problems.
It'd complicate too much.

However, now that we know how to handle the basics, we can move to the
advanced.

**Nonlinear Programming format**

The NLPModels internal structure is based on the CUTEst way of storing a
problem.
We use the following form for the optimization problem:

$$
\begin{align}
\min \quad & f(x) \\
s.t. \quad & c_L \leq c(x) \leq c_U \\
& \ell \leq x \leq u\end{align}
$$

Given an `AbstractNLPModel` named `nlp`, the values for $\ell$, $u$, $c_L$ and
$c_U$ are stored in an `NLPModelMeta` structure, and can be accessed by
through `nlp.meta`.

Let's look back at the simple Rosenbrock problem of before.

```
using NLPModels

f(x) = (x[1] - 1)^2 + 100*(x[2] - x[1]^2)^2
x0 = [-1.2; 1.0]
nlp = ADNLPModel(f, x0)
print(nlp.meta)
```

You should be seeing this:

```
Minimization problem Generic
nvar = 2, ncon = 0 (0 linear)
lvar = -Inf  -Inf
uvar = Inf  Inf
lcon = ∅
ucon = ∅
x0 = -1.2  1.0
y0 = ∅
nnzh = 4
nnzj = 0
```

Although the meaning of these values is reasonably straigthforward, I'll explain a bit.

- `nvar` is the number of variables in a problem;
- `ncon` is the number of constraints, without counting the bounds;
- `lvar` is the vector $\ell$, the lower bounds on the variables;
- `uvar` is the vector $u$, the upper bounds on the variables;
- `lcon` is the vector $c_L$, the lower bounds of the constraints function;
- `ucon` is the vector $c_U$, the upper bounds of the constraints function;
- `x0` is the initial approximation to the solution, aka the starting point;
- `y0` is the initial approximation to the Lagrange multipliers;
- `nnzh` is the number of nonzeros on the Hessian¹;
- `nnzj` is the number of nonzeros on the Jacobian¹;

_¹ `nnzh` and `nnzj` are not consistent between models, because some consider the dense matrix, and for the Hessian, some consider only the triangle. However, if you're possibly considering using `nnzh`, you're probably looking for `hess_coord` too, and `hess_coord` returns with the correct size._

These values can be accessed directly as fields in `meta` with the same name above.

```
nlp.meta.ncon
nlp.meta.x0
nlp.meta.lvar
```

**Bounds**

Now, let's create a bounded problem.

```
nlp = ADNLPModel(f, x0, lvar=zeros(2), uvar=[0.4; 0.6])
print(nlp.meta)
```

Now the bounds are set, and you can access them with

```
nlp.meta.lvar
nlp.meta.uvar
```

That's pretty much it. For `SimpleNLPModel`, it's the same thing.
`MathProgNLPModel` inherits the bounds, as expected:

```
using JuMP

jmp = Model()
u = [0.4; 0.6]
@variable(jmp, 0 <= x[i=1:2] <= u[i], start=(x0[i]))
@NLobjective(jmp, Min, (x[1] - 1)^2 + 100*(x[2] - x[1]^2)^2)
mpbnlp = MathProgNLPModel(jmp)
print(mpbnlp.meta)
```

For CUTEst, there is no differentiation on creating a problem with bounds or
not, since it uses the internal description of the problem.
For instance, `HS4` is a bounded problem.

```
using CUTEst

clp = CUTEstModel("HS4")
print(clp.meta)
finalize(clp)
```

Notice that it can happen that one or more of the variables is unlimited
(lower, upper or both). This is represented by the value `Inf` in Julia.
This should be expected since the unconstrained problem already used these
`Inf` values.

On the other hand, it could happen that $\ell_i = u_i$, in which case the
variable is fixed, or that $\ell_i > u_i$, in which case the variable (and the
problem) is infeasible.
Note that `NLPModels` only creates the model, it doesn't check whether it is
feasible or not, even in this simple example. That said, CUTEst shouldn't have
any infeasible variable.

Furthermore, all these types of bounds can be accessed from `meta`. Notice that
there are 6 possible situations:

- Free variables, stored in `meta.ifree`;
- Fixed variables, stored in `meta.ifix`;
- Variables bounded below, stored in `meta.ilow`;
- Variables bounded above, stored in `meta.iupp`;
- Variables bounded above and below, stored in `meta.irng`;
- Infeasible variables, stored in `meta.iinf`.

Here is one example with one of each of them

```
nlp = ADNLPModel(x->dot(x,x), zeros(6),
  lvar = [-Inf, -Inf, 0.0, 0.0, 0.0,  0.0],
  uvar = [ Inf,  1.0, Inf, 1.0, 0.0, -1.0])
nlp.meta.ifree
nlp.meta.ifix
nlp.meta.ilow
nlp.meta.iupp
nlp.meta.irng
nlp.meta.iinf
```

**Constraints**

Constraints are stored in NLPModels following in the format $c_L \leq c(x) \leq c_U$.
That means that an equality constraint happens when $c_{L_j} = c_{U_j}$.
Let's look at how to create a problem with constraints.

For `ADNLPModel`, you need to pass three keywords arguments: `c`, `lcon` and `ucon`,
which represent $c(x)$, $c_L$ and $c_U$, respectively.
For instance, the problem

$$
\begin{align}
\min \quad & x_1^2 + x_2^2 \\
s.t. \quad & x_1 + x_2 = 1
\end{align}
$$

is created by doing

```
c(x) = [x[1] + x[2] - 1]
lcon = [0.0]
ucon = [0.0]
nlp = ADNLPModel(x->dot(x,x), zeros(2), c=c, lcon=lcon, ucon=ucon)
```

or alternatively, if you don't want the intermediary functions

```
nlp = ADNLPModel(x->dot(x,x), zeros(2), c=x->[x[1]+x[2]-1], lcon=[0.0], ucon=[0.0])
```

Another possibility is to do

```
nlp = ADNLPModel(x->dot(x,x), zeros(2), c=x->[x[1]+x[2]], lcon=[1.0], ucon=[1.0])
```

Personally, I prefer the former.

For inequalities, you can have only lower, only upper, and both.
The commands

```
nlp = ADNLPModel(x->dot(x,x), zeros(2),
  c=x->[x[1] + x[2]; 3x[1] + 2x[2]; x[1]*x[2]],
  lcon = [-1.0; -Inf; 1.0],
  ucon = [Inf;   3.0; 2.0])
```

implement the problem

$$
\begin{align}
\min \quad & x_1^2 + x_2^2 \\
s.t. \quad & x_1 + x_2 \geq -1 \\
& 3x_1 + 2x_2 \leq 3 \\
& 1 \leq x_1x_2 \leq 2.
\end{align}
$$

Again, the types of constraints can be accessed in `meta`, through
`nlp.meta.jfix`, `jfree`, `jinf`, `jlow`, `jrng` and `jupp`.
Notice if you forget to set `lcon` and `ucon`, there will be no
constraints, even though `c` is set. This is because the number of
constraints is taken from the lenght of these vectors.

Now, to access these constraints, let's consider this simple problem.

```
nlp = ADNLPModel(f, x0, c=x->[x[1]*x[2] - 0.5], lcon=[0.0], ucon=[0.0])
```

The function `cons` return $c(x)$.

```
cons(nlp, nlp.meta.x0)
```

The function `jac` returns the Jacobian of $c$. `jprod` and `jtprod` the
Jacobian product times a vector, and `jac_op` the LinearOperator.

```
jac(nlp, nlp.meta.x0)
jprod(nlp, nlp.meta.x0, ones(2))
jtprod(nlp, nlp.meta.x0, ones(1))
J = jac_op(nlp, nlp.meta.x0)
J * ones(2)
J' * ones(1)
```

To get the Hessian we'll use the same functions as the unconstrained case,
with the addition of a keyword parameter `y`.

```
y = [1e4]
hess(nlp, nlp.meta.x0, y=y)
hprod(nlp, nlp.meat.x0, ones(2))
H = hess_op(nlp, nlp.meta.x0, y=y)
H * ones(2)
```

If you want to ignore the objective function, or scale it by some value,
you can use the keyword parameter `obj_weight`.

```
s = 0.0
hess(nlp, nlp.meta.x0, y=y, obj_weight=s)
hprod(nlp, nlp.meat.x0, ones(2), obj_weight=s)
H = hess_op(nlp, nlp.meta.x0, y=y, obj_weight=s)
H * ones(2)
```

Check the
[API](http://juliasmoothoptimizers.github.io/NLPModels.jl/stable/api.html)
for more details.

We can also create a constrained JuMP model.

```
x0 = [-1.2; 1.0]
jmp = Model()
@variable(jmp, x[i=1:2], start=(x0[i]))
@NLobjective(jmp, Min, (x[1] - 1)^2 + 100*(x[2] - x[1]^2)^2)
@NLcontraint(jmp, x[1]*x[2] == 0.5)
mpbnlp = MathProgNLPModel(jmp)
cons(mpbnlp, mpbnlp.meta.x0)
jac(mpbnlp, mpbnlp.meta.x0)
hess(mpbnlp, mpbnlp.meta.x0, y=y)
```

And again, the access in CUTEst problems is the same.

```
clp = CUTEstModel("BT1")
cons(clp, clp.meta.x0)
jac(clp, clp.meta.x0)
hess(clp, clp.meta.x0, y=clp.meta.y0)
finalize(clp)
```

**Convenience functions**

There are some convenience functions to check whether a problem has only
equalities, only bounds, etc.
For clarification, we're gonna say function constraint to refer to constraints that are not bounds.

- `has_bounds`: Returns `true` is variable has bounds.
- `bound_constrained`: Returns `true` if `has_bounds` and no function
  constraints;
- `unconstrained`: No function constraints nor bounds;
- `linearly_constrained`: There are function constraints, and they are
  linear; _obs: even though a `bound_constrained` problem is linearly
  constrained, this will return false_.
- `equality_constrained`: There are function constraints, and they are all equalities;
- `inequality_constrained`: There are function constraints, and they are all inequalities;

**Example solver**

Let's implement a "simple" solver for constrained optimization.
Our solver will loosely follow the Byrd-Omojokun implementation of

> M. Lalee, J. Nocedal, and T. Plantenga. **On the implementation of an algorithm for large-scale equality constrained optimization**. SIAM J. Optim., Vol. 8, No. 3, pp. 682-706, 1998.

```
function solver(nlp :: AbstractNLPModel)
  if !equality_constrained(nlp)
    error("This solver is for equality constrained problems")
  elseif has_bounds(nlp)
    error("Can't handle bounds")
  end

  x = nlp.meta.x0

  fx = obj(nlp, x)
  cx = cons(nlp, x)

  ∇fx = grad(nlp, x)
  Jx = jac_op(nlp, x)

  λ = cgls(Jx', -∇fx)[1]
  ∇ℓx = ∇fx + Jx'*λ
  norm∇ℓx = norm(∇ℓx)

  Δ = max(0.1, min(100.0, 10norm∇ℓx))
  μ = 1
  v = zeros(nlp.meta.nvar)

  iter = 0
  while (norm∇ℓx > 1e-4 || norm(cx) > 1e-4) && (iter < 10000)
    # Vertical step
    if norm(cx) > 1e-4
      v = cg(Jx'*Jx, -Jx'*cx, radius=0.8Δ)[1]
      Δp = sqrt(Δ^2 - dot(v,v))
    else
      fill!(v, 0)
      Δp = Δ
    end

    # Horizontal step
    # Simplified to consider only ∇ℓx = proj(∇f, Nu(A))
    B = hess_op(nlp, x, y=λ)
    B∇ℓx = B * ∇ℓx
    gtBg = dot(∇ℓx, B∇ℓx)
    gtγ = dot(∇ℓx, ∇fx + B * v)
    t = if gtBg <= 0
      norm∇ℓx > 0 ? Δp/norm∇ℓx : 0.0
    else
      t = min(gtγ/gtBg, Δp/norm∇ℓx)
    end

    d = v - t * ∇ℓx

    # Trial step acceptance
    xt = x + d
    ft = obj(nlp, xt)
    ct = cons(nlp, xt)
    γ = dot(d, ∇fx) + 0.5*dot(d, B * d)
    θ = norm(cx) - norm(Jx * d + cx)
    normλ = norm(λ, Inf)
    if θ <= 0
      μ = normλ
    elseif normλ > γ/θ
      μ = min(normλ, 0.1 + γ/θ)
    else
      μ = 0.1 + γ/θ
    end
    Pred = -γ + μ * θ
    Ared = fx - ft + μ * (norm(cx) - norm(ct))

    ρ = Ared/Pred
    if ρ > 1e-2
      x .= xt
      fx = ft
      cx .= ct
      ∇fx = grad(nlp, x)
      Jx = jac_op(nlp, x)
      λ = cgls(Jx', -∇fx)[1]
      ∇ℓx = ∇fx + Jx'*λ
      norm∇ℓx = norm(∇ℓx)
      if ρ > 0.75 && norm(d) > 0.99Δ
        Δ *= 2.0
      end
    else
      Δ *= 0.5
    end

    iter += 1
  end

  return x, fx, norm∇ℓx, norm(cx)
end
```

Too loosely, in fact.

- The horizontal step computes only the Cauchy step;
- No special updates;
- No second-order correction;
- No efficient implementation beyond the easy-to-do.

To test how good it is, let's run on the Hock-Schittkowski constrained problems.

```
function runcutest()
  problems = filter(x->contains(x, "HS") && length(x) <= 5, CUTEst.select(only_free_var=true, only_equ_con=true))
  sort!(problems)
  @printf("%-7s  %15s  %15s  %15s\n",
          "Problem", "f(x)", "‖∇ℓ(x,λ)‖", "‖c(x)‖")
  for p in problems
    nlp = CUTEstModel(p)
    try
      x, fx, nlx, ncx = solver(nlp)
      @printf("%-7s  %15.8e  %15.8e  %15.8e\n", p, fx, nlx, ncx)
    catch
      @printf("%-7s  %s\n", p, "failure")
    finally
      finalize(nlp)
    end
  end
end
```

I'm gonna print the output of this one, so you can compare it with yours.

```
Problem             f(x)        ‖∇ℓ(x,λ)‖           ‖c(x)‖
HS26      5.15931251e-07   9.88009545e-05   5.24359322e-05
HS27      4.00000164e-02   5.13264248e-05   2.26312672e-09
HS28      7.00144545e-09   9.46563681e-05   2.44249065e-15
HS39     -1.00000010e+00   1.99856691e-08   1.61607518e-07
HS40     -2.50011760e-01   4.52797064e-05   2.53246505e-05
HS42      1.38577292e+01   5.06661945e-05   5.33092868e-05
HS46      3.56533430e-06   9.98827045e-05   8.00086215e-05
HS47      3.53637757e-07   9.71339790e-05   7.70496596e-05
HS48      4.65110036e-10   4.85457139e-05   2.27798719e-15
HS49      3.14248189e-06   9.94899395e-05   2.27488138e-13
HS50      1.36244906e-12   2.16913725e-06   2.90632554e-14
HS51      1.58249170e-09   8.52213221e-05   6.52675179e-15
HS52      5.32664756e+00   3.35626559e-05   3.21155766e-14
HS56     -3.45604528e+00   9.91076239e-05   3.14471179e-05
HS6       5.93063756e-13   6.88804464e-07   9.61311292e-06
HS61     -1.43646176e+02   1.06116455e-05   1.80421875e-05
HS7      -1.73205088e+00   1.23808109e-11   2.60442422e-07
HS77      2.41501014e-01   8.31210333e-05   7.75367223e-05
HS78     -2.91972281e+00   2.27102179e-05   2.88776440e-05
HS79      7.87776482e-02   4.77319205e-05   7.55827729e-05
HS8      -1.00000000e+00   0.00000000e+00   2.39989802e-06
HS9      -5.00000000e-01   1.23438228e-06   3.55271368e-15
```

If you compare against the Hock-Schitkowski paper, you'll see that
the method converged for all 22 problems.
Considering our simplifications, this is a very exciting.

That's all for now. Use our RSS feed to keep updated.
