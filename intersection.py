#! /usr/bin/env python2

# find the intersection of two lists including duplicate values

from collections import defaultdict

def frequencies(xs):
    freqs = defaultdict(int)
    for x in xs:
        freqs[x] += 1
    return freqs

def intersection(xs, ys):
    freqs1 = frequencies(xs)
    freqs2 = frequencies(ys)

    intersection = []
    for k, v in freqs1.iteritems():
        n = min(v, freqs2[k])
        intersection.extend([k for _ in xrange(n)])
    return intersection

print intersection([1,4,2,6,10,4,4], [7,4,9,10,20,4,10])
