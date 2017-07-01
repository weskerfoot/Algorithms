#! /usr/bin/env python3

# reverse a linked list

class LinkedList:
    def __init__(self, head, tail):
        self.head = head
        self.tail = tail

    def __repr__(self):
        return "%s%s" % (self.head, "" if self.tail is None else ",%s" % repr(self.tail))

def cons(x, xs):
    return LinkedList(x, xs)

xs = cons(1, cons(2, cons(3, cons(4, cons(5, None)))))

def push(x, xs):
    prev = xs.head
    xs.head = x
    xs.tail = cons(prev, xs.tail)

def reverseLinkedList(xs):
    current = xs.head
    rest = xs.tail
    revd = None
    while True:
        if revd is None:
            revd = cons(current, None)
        else:
            push(current, revd)
        if rest is None:
            break
        current = rest.head
        rest = rest.tail

    return revd

print(reverseLinkedList(xs))
