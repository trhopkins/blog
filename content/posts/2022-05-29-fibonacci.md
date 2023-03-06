---
categories: programming
date: "2022-05-29T01:00:00Z"
title: Fibonacci Numbers and Time Complexity
---

# Simple definitions

One common programming exercise assigned to students is to create a Fibonacci
sequence calculator. The Fibonacci sequence can be defined as follows:

1. start with the numbers 0 and 1 (some versions may start with 1 and 1).
2. to get the next number in the sequence, add the last two numbers in the
   sequence.

Let's try it! We start with zero and one according to the first rule.

> 0, 1

Now let's apply the second rule, adding our zero and one.

> 0, 1, 1

Now we add the last two numbers to get two.

> 0, 1, 1, 2

Adding one and two gives us three.

> 0, 1, 1, 2, 3

Adding two and three gives us five.

> 0, 1, 1, 2, 3, 5

Let's follow this sequence and see where it takes us.

> 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144...

# Let's program this!

The numbers seem to grow quickly! Let's write a program that will calculate the
nth number in the sequence for us:

```python
# Python
def fib(n):
    if n < 2:
        return n
    else:
        return fib(n-1) + fib(n-2)
```

```haskell
-- Haskell
fib :: Integer -> Integer
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
```

This implementation, while simple, is not very efficient. Let's calculate the
expected number of operations required to compute `fib(5)` with a call tree:

![fib(5) call tree](/assets/output-1.svg)

Each number on the tree is a call of `fib`. We can calculate the result by
counting the number of ones that appears in the tree, in this case five. Notice
how we call `fib(1)` five times, `fib(2)` three times, and `fib(3)` two times.
All of these operations are being repeated several times, despite the result
never differing from its definition. You can probably imagine how many
redundant operations may be required to calculate `fib(10)`, which results in
*55* calls to `fib(1)` before terminating. It turns out the time complexity of
this solution is *O(2^n)*, which is awfully slow. We will look further into
this fact later (the *true* time complexity is much more interesting).

# Returning to your roots

Our recursive algorithm doesn't seem to work how we originally defined the
Fibonacci sequence. What we want is an *iterative* solution which will only
look at the previous two results:

```python
# Python
def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a+b
    return a
```

```haskell
-- Haskell
fib :: Integer -> Integer
fib n = iter 0 1 n
  where
    iter a _ 0 = a
    iter a b n = iter b (a+b) (n-1)
```

These definitions are satisfactory, as long as you just want a single value
calculated in O(n) time. We can determine the time complexity of the above code
with the following:

![linear time equation](/assets/lineartime.svg)

# Your memory will serve you well

Now consider the following code snippet:

```python
# Python
[fib(i) for i in range(10)]
```

```haskell
--Haskell
map fib [0..10]
```

Performing an O(n) operation over a list of m elements results a time
complexity of O(n\*m). If we were to calculate a list of Fibonacci numbers
ourselves, we could refer back to previously computed values to prevent
duplicate operations. Making a list of computed values to refer to is known as
memoization, and is an important part of dynamic programming. Let's see how
this can be done:

```python
#Python
lookup = {0: 0, 1: 1}
def fib(n):
    if n in lookup:
        return lookup[n]
    else:
        result = fib(n-1) + fib(n-2)
        lookup[n] = result
        return result
```

```haskell
-- Haskell
fib :: Integer -> Integer
fib n = map f [0..] !! n
   where
     f 0 = 0
     f 1 = 1
     f n = fib (n-1) + fib (n-2)
```

This code closely resembles the tree-recursive, naive definition, with an
important difference: Precomputed values (anything on a right branch) takes
O(1) time to look up after it has been added to the memoized table. Thus, we
can think of our call tree as a straight line down to the bottom, containing n
nodes for `fib(n)`, taking O(n) operations times some constant. (For the Haskell
version of this code, the `!!` operator over the list `[0..]` tabulates values
for us in the background). Repeatedly performing the `fib()` procedure to
calculate values in a table is vastly sped up by dynamic programming for this
reason.

Assuming looking up values in our list of Fibonacci numbers takes O(1) time, we
can speed up all future operations each time we compute a new highest value.
Still, computing a large number like `fib(10**10)` would take 10^10 * k operations
to compute. Worse yet, each call to `fib()` adds to our call stack (as long as
we are not using a language with tail call optimization) and may cause a stack
overflow for inputs over a thousand. Is there anything we can do?

Remember that our iterative and dynamic solutions both take O(n) time to
compute. This is because our current algorithm must compute all n intermediate
values to reach its final result. The fundamental *shape* of our recursive call
tree hasn't become any shorter, we have just pruned many values from the right
side. What we need is a shortcut that can utilize the power of mathematics and
the properties of the Fibonacci sequence to save us some unnecessary
operations.

# Math detour!

Maybe the data structure we are using to maintain previous Fibonacci numbers
lacks the mathematical properties we need to go faster than O(n). For an
example of such a structure, consider this 2x2 matrix which can encode the
Fibonacci sequence through exponentiation:

![matrices are cool](/assets/matrices.svg)

It seems that the bottom-left and top-right values of our matrix contain the most recent
Fibonacci number, while the other values contain the last Fibonacci numbers
needed to continue our algorithm, and all we have to do is keep multiplying
this matrix by our original one! By raising our matrix to the power of n, and
taking the number in the top-left position of our result, we can compute the
nth Fibonacci number.

Now I'd like to bring your attention to some useful facts about exponentiation:

![exponent rules](/assets/exponents.svg)

This means that instead of multiplying x by itself e times, we can square it
log(e) times for some exponent e, until we get an odd e, at which point we
use the fact that

which gives us an even e to continue using our shortcut. This gives us a
O(log n) exponentiation operation!

## Algebra really is useful

Let's combine these two facts to get our final Fibonacci algorithm:

```python
# Python
import numpy

root = numpy.matrix([[1, 1], [1, 0]])

def fast_matrix_expt(base, expt):
    if expt == 0:
        return numpy.identity(base.shape[0])
    elif expt % 2 == 0:
        return numpy.linalg.matrix_power(fast_matrix_expt(base, expt//2), 2)
    else:
        return numpy.matmul(fast_matrix_expt(base, expt-1), base)

def fib(n):
    res = fast_matrix_expt(root, n)
    return int(res[1, 0])
```

```haskell
--Haskell
import Data.List(transpose)

root :: [[Integer]]
root = [[1, 1], [1, 0]]

type Matrix a = [[a]]

idMatrix :: Integer -> Matrix Integer
idMatrix 0 = []
idMatrix n = (1 : replicate (n-1) 0) : map (0:) (idMatrix (n-1))

matrixMult :: Matrix Integer -> Matrix Integer -> Matrix Integer
matrixMult a b = [[row `dot` col | col <- transpose b] | row <- a]
                   where
                     dot v w = sum $ zipWith (*) v w

matrixSquare :: Matrix Integer -> Matrix Integer
matrixSquare a = matrixMult a a

matrixExpt :: Matrix Integer -> Integer -> Matrix Integer
matrixExpt b e | e == 0    = idMatrix $ length b
               | even e    = matrixSquare $ matrixExpt b $ e `div` 2
               | otherwise = matrixMult b $ matrixExpt b $ e - 1

fib :: Integer -> Integer
fib n = matrixExpt root n !! 0 !! 1
```

Whew, that was a lot of code! Much of the Python code above is accessing Numpy
functions, and much of the Haskell code is creating the Matrix data structure
we intend to store our intermediate values in.

## The golden ratio

An O(log n) solution using matrices and exponentiation is pretty neat, but have
we gotten all we can out of the properties of the Fibonacci sequence? How else
can we optimize our algorithm?

One thing we can do is attempt to write a generating function that will
calculate Fibonacci numbers for us. One way of doing this is to see if the
relationships between the numbers in the sequence have a common pattern in a
geometric series or linear recursive series. The important thing to understand
is that we are generalizing away our old number-generating ruleset for new,
equivalent ones. Let's see if the slope of the Fibonacci sequence can give us a
hint:

![finding phi](/assets/findingphi.svg)

Hey, that's the golden ratio! Side note: the golden ratio the number you get
when you pick some a and b such that:

![ratios](/assets/ratios.svg)

It looks like all we have to do is find a base number, start multiplying it by
this ratio (which is irrational by the way), and round to the nearest integer!
To find that number, we'd have to do a bunch of work with generating functions
to find a characteristic function, its roots, go from there. You can read more
about how this is all done
[here](https://austinrochford.com/posts/2013-11-01-generating-functions-and-fibonacci-numbers.html).
Long story short, our chosen starting number is:

![base number](/assets/base.svg)

On many CPU architectures, within a limited range of floating-point values,
simple exponentiation can be done in constant time with some tricky floating
point unit operations in a coprocessor. We can use this fact, combined with our
new definition of Fibonacci numbers, to get the following "O(1)" algorithm, so
long as our resulting number fits within the IEEE 754 specification for
floating point numbers:

```python
# Python
def f(n):
    sq5 = math.sqrt(5)
    phi = (1 + sq5) / 2
    return round(phi**n / sq5)
```

```haskell
-- Haskell
fib :: Integer -> Integer
fib n = round $ phi ** fromIntegral n / sq5
  where
    sq5 = sqrt 5 :: Double
    phi = (1 + sq5) / 2
```

## Wrapping up

Generating Fibonacci numbers is a great exercise for getting a better
understanding of time complexity, recursive functions, and identifying
mathematical relationships in your code. In the words of the great Chess player
Emmanuel Lasker:

> When you find a good move, look for a better one.

We've gone from a horrifically slow but very intuitive definition, to several
clever and unique solutions, some of which show off some fantastic mathematical
properties of this deceptively simple function. As programmers, when we come
across elegant solutions to problems, often these problems are indicative of a
deeper truth embedded into mathematics, which we can use to our advantage. Even
if the resulting code doesn't come as naturally as the naive solution, reaching
for a math textbook can often take you on a journey much more fruitful than
initially anticipated.

