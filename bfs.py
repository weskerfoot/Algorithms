#! /usr/bin/env python3

# breadth first traversal of a binary tree

from collections import deque

class Branch:
    def __init__(self, v, left, right):
        self.v = v
        self.left = left
        self.right = right

def bfs(tree, process):
    nodes = deque([tree])
    current_node = None
    while nodes:
        current_nodes = list(nodes)
        for node in current_nodes:
            current_node = node
            process(current_node.v)
            nodes.popleft()
            if not current_node.left is None:
                nodes.appendleft(current_node.left)
            if not node.right is None:
                nodes.appendleft(current_node.right)

test = Branch(1, Branch(2, Branch(3, None, None), Branch(4, None, None)),
                 Branch(5, None, None))

bfs(test, print)
