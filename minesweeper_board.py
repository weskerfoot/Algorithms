#! /usr/bin/env python3

from itertools import product
from random import choices
from collections import deque
from sys import stdout

import attr, cattr

# Serialization helpers for persisting games
def serialize_board(board):
    """
    Returns a dict representation of the game board
    """
    return {
        "cell_rows" : [[cattr.unstructure(cell) for cell in row] for row in board.cells],
        "height" : board.height,
        "width" : board.width,
        "probability" : board.board_probability
    }

def deserialize_board(board_data):
    """
    Returns a Board object given a dict serialized from it
    """
    return Board(
            cells=[[cattr.structure(cell, Cell) for cell in row]
                    for row in board_data.get("cell_rows", [])],
            width=board_data.get("width", 8),
            height=board_data.get("height", 8),
            board_probability=board_data.get("probability", 0.10)
        )

def gen_board(width, height, p):
    """
    Generate a fresh board
    """
    return [
        [Cell((w, h), is_mine=gen_cell(p)) for w in range(width)] for
            h in range(height)
    ]

def gen_cell(probability):
    """
    Generate a single cell with probability p that it is a mine
    True = has a mine
    False = is clear
    """
    return choices((True, False), (probability, (1 - probability)))[0]

@attr.s
class Cell:
    location = attr.ib()
    is_mine = attr.ib(default=False)

    @property
    def x(self):
        return self.location[0]

    @property
    def y(self):
        return self.location[1]

@attr.s
class Board:
    height = attr.ib(default=20)
    width = attr.ib(default=20)
    cells = attr.ib(factory=list)
    board_probability = attr.ib(default=0.10)

    def __iter__(self):
        return iter(self.cells)

    def print_board(self):
        for y in range(self.height):
            for x in range(self.width):
                stdout.write("x" if self.get_cell(x, y).is_mine else "0")
            stdout.write("\n")

    def show_board(self):
        """
        Convert to a representation we can show on the frontend
        """
        return [
                [(0, self.get_cell(x, y).is_mine) for x in range(self.width)]
                    for y in range(self.height)
                ]


    def get_cell(self, x, y):
        """
        Get the value of an individual cell
        """
        # Handle boundary conditions
        if (x >= self.width or
            y >= self.height or
            x < 0 or y < 0):
            return None
        try:
            return self.cells[y][x]
        except IndexError:
            return None

    def get_adjacent(self, x, y):
        """
        Get a list of all cells adjacent to this location
        """
        return [
            self.get_cell(x, y) for x, y in [
                (x+1, y), (x+1, y+1), (x+1, y-1),
                (x, y+1), (x, y-1),
                (x-1, y+1), (x-1, y), (x-1, y-1)
            ]
            if self.get_cell(x, y)
        ]

    def count_adjacent(self, cells):
        """
        How many mines are adjacent to this cell?
        """
        return sum([c.is_mine for c in cells])

    def flip_cell(self, x, y):
        """
        Flip over a cell
        Three potential cases:
            Uncovering a mine
            A clear cell with 1 or more adjacent mines
            A clear cell with no adjacent mines, then we keep clearing
        """
        clicked_cell = self.get_cell(x, y)

        if clicked_cell is None:
            return []

        if clicked_cell.is_mine:
            # if it's a mine, we're done
            return [(0, clicked_cell)]

        cells = deque([clicked_cell])
        uncovered = []
        processed_locations = set()

        # do a breadth-first search of the surrounding cells
        while cells:
            for cell in list(cells):
                cells.popleft()
                adjacent_cells = self.get_adjacent(cell.x, cell.y)
                num_adjacent = self.count_adjacent(adjacent_cells)

                if not (cell.location in processed_locations):
                    if not cell.is_mine:
                        # This is the mine we "clicked" on
                        uncovered.append((num_adjacent, cell))

                    # add to the set of processed cells
                    processed_locations.add(cell.location)

                    # skip processing the surrounding ones
                    # if it has at least one adjacent mine
                    if num_adjacent > 0:
                        continue
                    else:
                        # Process surrounding cells that themselves have 0 adjacent mines
                        # This adds them to the queue of cells to be processed
                        cells.extend([c for c in adjacent_cells if self.count_adjacent(self.get_adjacent(*c.location)) == 0])

                        # Add the surrounding adjacent cells to the uncovered list
                        for cell in adjacent_cells:
                            adjacent_count = self.count_adjacent(self.get_adjacent(*cell.location))

                            # small optimization to prevent it from processing mines
                            if cell.is_mine:
                                processed_locations.add(cell.location)

                            elif adjacent_count > 0 and (not (cell.location in processed_locations)):
                                processed_locations.add(cell.location)
                                uncovered.append((adjacent_count, cell))
        return uncovered

# Helper functions to handle playing the game
def click_cell(game_board, display_board, x, y):
    """
    Game board: the full board object
    Display board: the board displayed to users
    x, y: coordinates ot the cell to be uncovered
    Mutates `display_board` and returns it, or False if it is a mine.
    """
    uncovered = game_board.flip_cell(x, y)
    for cell in uncovered:
        if cell[1].is_mine:
            return False

    for adjacent_num, cell in uncovered:
        display_board[cell.y][cell.x] = (adjacent_num, cell.is_mine)

    return display_board

def won(game_board, display_board):
    """
    Determine if the only remaining uncovered cells are mines
    This determins if the player has won
    """
    won = True
    for y, row in enumerate(display_board):
        for x, cell in enumerate(row):
            if (cell is None) and (not game_board.get_cell(x, y).is_mine):
                # if it's uncovered and it's not a mine
                # then they haven't won yet
                won = False
    return won

def new_board(x=8, y=8, p=0.10):
    """
    Generate a new game board, and display board
    The game board never changes
    The display board gets updated each time a cell is revealed
    """
    game_board = Board(cells=gen_board(x, y, p), width=x, height=y, board_probability=p)
    display_board = [[None for _ in range(x)] for _ in range(y)]

    return (game_board, display_board)
