#! /usr/bin/env python3

from random import randint
from pprint import PrettyPrinter

# Construct a binary search tree
# Also create a function to search it

pp = PrettyPrinter(indent=4)

class Branch:
    def __init__(self, left, value, right):
        self.value = value
        self.left = left
        self.right = right

    def __repr__(self):
        return "(%s) %s (%s)" % (repr(self.left), self.value, repr(self.right))

def split(xs):
    l = int(len(xs) / 2)
    return (xs[0:l], xs[l], xs[l+1:])

def bst(xs):
    if not xs:
        return None
    left, middle, right = split(xs)
    return Branch(bst(left), middle, bst(right))

def makeBST(xs):
    return bst(sorted(xs))

def findBST(tree, x):
    if tree is None:
        return None
    if tree.value == x:
        return tree
    if x < tree.value:
        return findBST(tree.left, x)
    else:
        return findBST(tree.right, x)

test = [randint(1,50) for _ in range(20)]

print(test)
print("finding %s" % test[4])
print(findBST(makeBST(test), test[4]))
