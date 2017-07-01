#! /usr/bin/env python2

# find the intersection of two lists including duplicate values

from collections import defaultdict

def frequencies(xs):
    freqs = defaultdict(int)
    for x in xs:
        freqs[x] += 1
    return freqs

def intersection(fs1, fs2):
    xs = []
    for k, v in fs1.iteritems():
        n = min(v, fs2[k])
        xs.extend([k for _ in xrange(n)])
    return xs

fs1 = frequencies([1,4,2,6,10,4,4])
fs2 = frequencies([7,4,9,10,20,4,10])

print intersection(fs1, fs2)
