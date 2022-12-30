---
title: 'Installing Gurobi 7 on Linux'
date: '2017-03-13'
tags:
  - 'work'
  - 'gurobi'
  - 'linux'
---

_Disclaimer:_ What I did here might work on Windows or OSX, but I give no
guarantee.

_Request by Clóvis Gonzaga._

First, create an account [here](http://www.gurobi.com/) and login.

Secondly, download the appropriate Gurobi version clicking on [_Gurobi
Optimizer_](http://www.gurobi.com/downloads/user/gurobi-optimizer).
In my case, it is Linux 64 bits. Where to download this is optional, but you
have to remember, as we'll use later. I use a folder `packages` on my home
folder.

Third, unpack the file. For linux, you might have a _file-roller_ that allows
clicking and unpacking trivially, but I'll use the command line.
Open a terminal and navigate to the folder where you downloaded the file.

```
tar -zxf gurobi7.0.2_linux64.tar.gz
```

This creates folder `gurobi702`. Inside is folder `linux64`.
Inside are many folders, one being `docs` which include the quick start guide
you might want to read (or not).

Fourth, your system needs to see this installation. On `bash` (the usual
terminal on Ubuntu), you have to open file `.bashrc` on your home folder, to
input some variables.

```
gedit $HOME/.bashrc
```

input the following at the end of the file:

```
export GUROBI_HOME="/FULL/PATH/gurobi702/linux64"
export PATH="${PATH}:${GUROBI_HOME}/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
export GRB_LICENSE_FILE="$HOME/gurobi.lic"
```

Notice the `/FULL/PATH` part. This is where you downloaded the package, but it
has to be the full path there. You can use `$HOME` to reference your home
folder. For instance, your `Desktop` is in `$HOME/Desktop`. My packages folder
is `$HOME/packages`.
Also notice the `GRB_LICENSE_FILE` variable. If you intend to put your license
somewhere else, you'll need to change that part.

After that is done you need to either (a) close and reopen the terminal or (b)
input `source $HOME/.bashrc`.

**To know that it's working** enter `grbgetkey` on the terminal. If it's working,
a message like

```
Gurobi license key client (version 7.0.2)
Copyright (c) 2017, Gurobi Optimization, Inc.

Enter the Key Code for the license you are activating
(format is xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx):
```

will appear. Press "CTRL+C" or close the terminal, because you need to get the
license.

## Getting the LICENSE

If you already applied for a license before installing Gurobi, you can go to
[this page](https://user.gurobi.com/download/licenses/current) to see your
available licenses. Otherwise, you need to (a) buy a license; (b) apply for
an academic license or (c) ask for a trial license.
I'm gonna focus on the academic license.

Get your academic license clicking on ["Academic
Licenses"](http://www.gurobi.com/downloads/user/licenses/free-academic).
Accept the conditions and agreements and click "Request License".
Notice that you need to fulfill some requirement to ask for an academic
license, like being a student or professor.

After requesting your license, you will get to a page showing your license
information and a line saying

```
grbgetkey xxxxxxxxxxxxxx
```

Copy all that line and paste on your terminal.

The software will connect to Gurobi and check that it's a valid serial number,
and then will download a file `gurobi.lic`. (Press ENTER or choose a different
folder). If you choose a different folder, remember to change `.bashrc`
accordingly.

To check that it's working, enter

```
gurobi.sh
```

on a terminal. It will a "Gurobi Interactive Shell" message and a prompt
"gurobi> ". It if gives any error, check the Quick User Guide.

## Gurobi with JuMP in Julia

For the advanced students, if you know the [Julia
Language](https://julialang.org), and the [JuMP Modelling
Language](https://github.com/JuliaOpt/JuMP.jl), you should be able to install
Gurobi with the julia command `Pkg.add("Gurobi")` now. Make sure you're in a
terminal with all variables set.

The following examples solves a simple problem with JuMP and Gurobi:

```
using JuMP, Gurobi

m = Model(solver=GurobiSolver(Presolve=0)) # Presolve=0 otherwise it will be trivial
@variable(m, x[1:2] >= 0, Int)
@objective(m, Max, x[1] + 2*x[2])
@constraint(m, x[1] + 10*x[2] <= 30)
@constraint(m, 10*x[1] + x[2] <= 29)
solve(m)
getvalue(x)
```
