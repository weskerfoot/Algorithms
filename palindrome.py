#! /usr/bin/env python3

# check if a word is palindromic without reversing it

def isPalindrome(word):
    end = len(word)
    start = 0
    retval = True
    while start < end+1:
        left = word[start]
        right = word[end-1]
        if left != right:
            retval = False
            break
        start += 1
        end -= 1
    return retval

print(isPalindrome("wwaabbaawwz"))
