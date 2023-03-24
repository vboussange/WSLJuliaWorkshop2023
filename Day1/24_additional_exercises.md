# Additional exercise: palindromes

Palindromes are sequences of symbols which read the same forward and
backwards, for example "otto" or "qannaq".  This exercise looks at
numbers in their decimal representation, e.g. "1881".

Write a function which checks whether an integer is a palindrome.
(Hint look up `string` and `reverse`).  Write the function in short
form, long form and anonymous.

Make a function which prints all palindromes in a range of numbers, say
`(4956, 56768)`.  Hint: just make a loop.

Make another function which just returns the number of palindromes
within a range.  How long does it take to compute for `(1,1000)`, `(1,
10^6)`, `(1, typemax(Int))` (not sure this will return).  Use the
`@time` macro for this (run the function once before timing to get it
compiled).

Make a function which returns the next higher palindrome.

Are there ways to be clever about it for all of above functions,
instead of just iterating?
