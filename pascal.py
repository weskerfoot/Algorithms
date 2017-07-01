#! /usr/bin/env python3

# find the rows of pascal's triangle

def choose(n, k):
    if k == 0:
        return 1
    return choose(n, k-1) * (n-k) / k

def pascal(n):
    return [choose(n, i) for i in range(0, n)]

for i in range(1, 11):
    print(pascal(i))
