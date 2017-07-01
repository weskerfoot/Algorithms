#! /usr/bin/env python2

# find all possible permutations of a sequence of phone pad digits (other than 1 and 0)

from itertools import chain

mappings = {
        2 : "ABC",
        3 : "DEF",
        4 : "GHI",
        5 : "JKL",
        6 : "MNO",
        7 : "PQRS",
        8 : "TUV",
        9 : "WXYZ"
    }

def generate(letter, letters):
    return [letter + c for c in letters]

def genWords(one, two):
    return list(chain.from_iterable([generate(c, two) for c in one]))

def genAll(lettersets):
    if len(lettersets) == 1:
        return lettersets

    first = lettersets[0]
    rest = lettersets[1:]
    return [genWords(first, ls) for ls in genAll(rest)]

def numToWords(num):
    lettersets = [mappings[int(n)] for n in num]
    return genAll(lettersets)[0]

for num in numToWords("353346"):
    print num
