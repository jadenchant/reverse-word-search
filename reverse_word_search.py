#!/usr/bin/python3
import os, sys, re

# 5x5 matrix
# reverse word search grid:

# b - a - -     angle   blank
# s - - - -     leap    link
# t - - - -     sink    snack
# - * - - -     stop    tag
# - - - l s


# b l a n k     angle   blank
# s i n k c     leap    link
# t a g n a     sink    snack
# o * l i n     stop    tag
# p a e l s

# Global vars
row = ["-"] * 5
row.copy()
matrix = [row, row.copy(), row.copy(), row.copy(), row.copy()]

words = ["angle", "blank", "leap", "link", "sink", "snack", "stop", "tag"]

starting_letters = [
    (0, 0, "b"),
    (0, 2, "a"),
    (1, 0, "s"),
    (2, 0, "t"),
    (3, 1, "*"),
    (4, 3, "l"),
    (4, 4, "s"),
]

answer = [
    ["b", "l", "a", "n", "k"],
    ["s", "i", "n", "k", "c"],
    ["t", "a", "g", "n", "a"],
    ["o", "*", "l", "i", "n"],
    ["p", "a", "e", "l", "s"],
]


def init_matrix(letters: [(int, int, chr)]) -> None:
    for i, j, c in letters:
        matrix[i][j] = c


def check_starting_char(x: int, y: int) -> bool:
    "checks if inserted char is going to override starting char"
    isStartingLetter = False
    for i, j, char in starting_letters:
        if i == x and j == y:
            isStartingLetter = True

    return isStartingLetter


def getchar() -> chr:
    "get a keypress"
    char = os.read(sys.stdin.fileno(), 1).decode("utf-8")
    if char == "\x1b":
        char += os.read(sys.stdin.fileno(), 2).decode("utf-8")
    return char


def csi(s: str) -> None:
    "send an ANSI escape code to the terminal"
    print("\x1b[" + s, end="")


def initialize_terminal():
    os.system("/bin/stty raw")  # stop buffering keypresses
    csi("?47h")  # save current screen
    csi("?25l")  # make cursor invisible


def restore_terminal() -> None:
    os.system("/bin/stty cooked")  # restore keypress handling
    csi("?25h")  # make cursor visible again
    csi("?47l")  # restore original screen


def clean_exit(message: str = "") -> None:
    "exits terminal with message"
    restore_terminal()
    if "" != message:
        print(message)
    exit()


def draw_display(c: chr, pos: [int]) -> None:
    "draw matrix and search words"
    csi("2J")  # clear the screen
    csi("H")  # move to home position (row=1, col=1)

    for i in range(5):
        for j in range(5):
            print(matrix[i][j], end=" ")
        if i < 4:
            print(f"\t{words[i*2]}\t{words[i*2 + 1]}\r")
        elif i == 4:
            print("\r")

    print()
    csi("42m")  # green background color
    print("press arrow keys to move, press character to insert,\r")
    print("q to quit")
    csi("49m")  # default background color

    # draw character at position pos, and flush to do it right away
    csi(str(pos[0]) + ";" + str(pos[1]) + "H")  # move to position given by pos

    csi("33m")
    x = pos[0] - 1
    y = pos[1] // 2
    if c.isalpha() and not check_starting_char(x, y):
        print(c, end="", flush=True)
    else:
        print("@", end="", flush=True)
    csi("0m")


def handle_keypress(c: chr, pos: [int]) -> None:
    "c is keypress, pos is current position"
    if "q" == c:
        clean_exit("Quiting search")
    elif c == "\x1b[D":
        pos[1] -= 2
        if pos[1] < 1:
            pos[1] = 1
    elif c == "\x1b[A":
        pos[0] -= 1
        if pos[0] < 1:
            pos[0] = 1
    elif c == "\x1b[B":
        pos[0] += 1
        if pos[0] > 5:
            pos[0] = 5
    elif c == "\x1b[C":
        pos[1] += 2
        if pos[1] > 9:
            pos[1] = 9
    elif c.isalpha():
        x = pos[0] - 1
        y = pos[1] // 2

        if not check_starting_char(x, y):
            matrix[x][y] = c


def check_solved() -> bool:
    "check if the user matrix equals answer matrix"
    for i in range(5):
        for j in range(5):
            if matrix[i][j] != answer[i][j]:
                return False
    return True


def main():
    initialize_terminal()
    pos = [1, 3]  # current position as row, column
    init_matrix(starting_letters)
    draw_display("", pos)
    while True:  # main loop
        c = getchar()  # get a keypress
        handle_keypress(c, pos)
        draw_display(c, pos)

        if check_solved():
            clean_exit("You Win")


if __name__ == "__main__":
    main()
