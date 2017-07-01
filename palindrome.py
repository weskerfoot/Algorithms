#! /usr/bin/env python2

# check if a word is palindromic without reversing it

def isPalindrome(word):
    end = len(word)
    start = 0
    foo = True
    while start < end+1:
        left = word[start]
        right = word[end-1]
        if left != right:
            foo = False
            break
        start += 1
        end -= 1
    return foo

print isPalindrome("wwaabbaawwz")
