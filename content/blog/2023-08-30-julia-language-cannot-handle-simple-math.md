---
title: "Julia Language Can't Even Handle Simple Math"
date: '2023-08-30'
featured_image: 'blog/2023-08-30/banner.gif'
tags:
  - 'julia'
  - 'floating-point'
  - 'scientific-computing'
  - 'numerical-methods'
  - 'math'
---

I have a new video up about how Julia cannot even handle simple math! [Check the video out](https://youtu.be/siCWLWHSrvo) or check an edited written version below.

Don't forget to like and subscribe

[![Banner for youtube video](/blog/2023-08-30/banner.gif)](https://youtu.be/siCWLWHSrvo)

---

## Introduction

Julia is supposed to be a great programming language, but it can't even do simple math correctly.
Take a look at this:

```julia
julia> 0.1 + 0.2 - 0.3
5.551115123125783e-17
```

It should be zero, but it's actually not.
The notation means

$$5.551115123125783 \times 10^{-17},$$

which is a number with 16 zeros after the period and then a bunch of "random" values.
So it's close to zero, but it's not zero.

So why is it not zero?
What are they not telling us? Why is this not being fixed?
**Is Julia dying?**

---

Don't worry, Julia is not dying.
This is actually a very common source of confusion.
You will find many questions on Stack Overflow, Discourse, Slack, asking why this happens.
Why is this not zero?

Applied mathematicians and computer scientists have known about this for a while now.
This is part of something called floating point arithmetic, and it's not just in Julia, it is common in many programming languages.

> [In the video, I show that **Python, R, Javascript, C**, and **Rust** have the same behaviour, watch it now.](https://youtu.be/siCWLWHSrvo)

## Why is it not 0?

So why is it not 0?
In most modern computers, numbers are represented using 64 bits.
So that means you have a sequence of either 0s or 1s, and that sequence of length 64 is associated with a real number.
So you have $2^{64}$ possibilities, which is much less than infinite real numbers.
So you can only represent a finite amount of the real numbers.
This means that some of the numbers that you would like to represent cannot be represented at all.

Second, these numbers are in binary.
For instance, $(101)_2$ is binary number.
It's value is obtained by taking each one of these digits and multiplying by a specific power of two.

$$(101)_2 = 1\times2^2 + 0\times2^1 + 1\times2^0 = 5$$

So the first digit (from right to left) is multiplied by $2^0$.
The next one by $2^1$, and the next one by $2^2$.
If you count from zero, you can verify this:

$$\begin{aligned}
(0)_2 & = 0 \\
(1)_2 & = 1 \\
(10)_2 & = 2 \\
(11)_2 & = 3 \\
(100)_2 & = 4 \\
(101)_2 & = 5.
\end{aligned}$$

So that's how integer binary numbers are represented, but we are not using integer numbers here.
We are concerned about more general numbers.
In particular, we are looking at rational numbers so you can also have things like

$$(11.01)_2.$$

This is a non-integer binary number, so here again, the right-most digit before the period is multiplied by $2^0$.
Each step to the left get a higher power, and each step to the right gets a lower power.

$$(11.01)_2 = 1\times2^1 + 1\times2^0 + 0\times2^{-1} + 1\times2^{-2} = 3.25.$$

So you can represent even numbers that are not integers in binary format.
So this means that when you write something in your computer, like 3 point 14, it is actually being translated into binary and truncated into one of these $2^{64}$ numbers that the computer can represent.
So in general, you cannot be sure that the number that you want to represent is possible to be represented in your computer.

And this is the root of all problems, you have these two things together.
You cannot represent all numbers because you only have a finite amount of numbers that can be represented with 64 bits, and these numbers are represented in binary.
So what happens with the specific numbers that we used?

In binary, the number 0.1, 0.2, and 0.3 are

$$\begin{aligned}
0.1 & = (0.0\overline{0011})_2 = (0.0001100110011\dots)_2 \\
0.2 & = (0.\overline{0011})_2 = (0.001100110011\dots)_2 \\
0.3 & = (0.01\overline{0011})_2 = (0.01001100110011\dots)_2.
\end{aligned}$$

So in base 10, these number are finite, they look nice.
But when you convert them to binary, they actually need an infinite amount of digits to be described correctly.
So they will need to be truncated at some point.

> Note: This has been simplified.

So let's make an example using 6 digits:

$$\begin{aligned}
0.1 & \approx (0.000110)_2 \\
0.2 & \approx (0.001100)_2 \\
0.3 & \approx (0.010011)_2.
\end{aligned}$$

This means that

$$0.1 + 0.2 \approx (0.000110)_2 + (0.001100)_2 = (0.010010)_2.$$

However, the approximate value of $0.3$ differs on the last bit, and that is why it is not zero.
Something similar happens with 64 bits (which is not the same as 64 digits).

This is a problem when you want to do these computations, and that's why there is a whole field of study dedicated for this.
So if you have the chance, I recommend looking into some kind of class for numerical methods, or specifically floating point arithmetic.

## Are they not gonna fix this?

So now for the second question, are they not going to fix this? And the answer is no, there is nothing to be fixed.
It is working as expected.
The IEEE-754 specification (that defines these floating points), which was defined in 1985, is being implemented in probably 99% of all the computers.

If you're using something from the hardware and you want it to be fast, it's probably the IEEE-754.
So that's what you want if you want speed.
And if you want to make sure that things are working correctly with the numerical errors that are a part of the floating point arithmetic, you have to do the math.

Essentially, that's the basic answer, the straightforward but not easy answer, for this problem.
You have to do the math and make sure that you're doing it right.

Let's say, however, that you are not going to do the math or that you actually know that you can't allow any of these errors because your objectives are not to do this kind of scientific computing, but something else.
Well, you have a few options to avoid or mitigate this problem.
Be aware that you're paying something in all of these cases.

The first situation is where you don't care so much that you have an error.
You care that the error is too large.
So you can use a higher precision.
So let's say that 10 to the minus 17 is not good, but if it were like 10 to the minus 300, that would be fine.
The first thing that you can do is use big float.

So if instead of doing that computation, 0 point 1, 0 point 2, with normal numbers, you use big floats, you're actually going to be able to have a much smaller error, depending on the precision that you select.
So that's one solution for you.

So another possibility is that you want the numbers to be exact.
So one thing that you can use, use rational numbers.
So the rational numbers are also part of the base of Julia.
You just use a double back slash and that will be available to you immediately.
Just.
Look for rational numbers, or if you really want something more complicated, especially if you're dealing with irrational numbers you can look into symbolics but I'll be honest, I haven't checked it for this kind of application.
I don't know what it does.
There are some irrational numbers in Julia, like PI and E, but in general, it will be much more complicated to handle it.
If our application is in finance, it is also common instead of worrying about binary numbers at all to just use decimal numbers.

So there are actually packages for that.
You have a package called DecFP.
jl for decimal floating point and something else called decimals.
jl.
Both of them are part of the Julia math organization.
So you can check those things out.

Is your application covered in these things that I mentioned? If yes or no, please let me know in the comments because it's very important statistics for me so I know what to do next.

Also, if you think this kind of numerical methods are interesting and you want to know more and you would like me to talk about it because of course you can always just look for it elsewhere.
Well, leave a comment saying that you would be up to more videos in numerical methods and floating point arithmetic.

I did teach classes about this in my previous job, so I kinda have some material in Portuguese, not in English yet.
And finally thanks a lot for watching.
Thanks for the patience for the delay in the videos.
I hope to be more frequent.
If you have anything in mind that you would like me to talk about, leave in the comments.
Otherwise, please like subscribe and press the bell button.
I'll see you next time.
Bye bye.
