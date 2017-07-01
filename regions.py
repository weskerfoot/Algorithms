#! /usr/bin/env python2

# counts the number of regions in a matrix
# vertically and horizontally connected
# e.g.
# [1, 0, 1, 1]
# [0, 1, 0, 0]
# [1, 1, 0, 1]
#  has 4 regions

class Patch(object):
    def __init__(self, visited, value):
        self.visited = visited
        self.value = value

    def __repr__(self):
        return "visited = %s, value = %s" % (self.visited, self.value)

def initialize(region):
    for row in region:
        yield [Patch(visited=False, value=field) for field in row]

testregion = list(initialize([
        [True, False, True, True],
        [False, True, False, False],
        [True, True, False, True]
]))

def exploreField(region, x, y):

    # check if we've reached the edge of the matrix
    if (x < 0 or y < 0):
        return True
    try:
        if region[y][x].visited or not region[y][x].value:
            return True
    except IndexError:
        return True

    region[y][x].visited = True

    exploreField(region, y+1, x)
    exploreField(region, y-1, x)
    exploreField(region, y, x+1)
    exploreField(region, y, x-1)

count = 0

for y, row in enumerate(testregion):
    for x, patch in enumerate(row):

        # if a patch is both unvisited and true
        # this means exploreField will eliminate it
        # so it counts as one region
        if not patch.visited and patch.value:
            count += 1
        exploreField(testregion, x, y)

print count
