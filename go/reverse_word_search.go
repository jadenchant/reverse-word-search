package main

import (
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"
)

// b - a - -     angle   blank
// s - - - -     leap    link
// t - - - -     sink    snack
// - * - - -     stop    tag
// - - - l s

// b l a n k     angle   blank
// s i n k c     leap    link
// t a g n a     sink    snack
// o * l i n     stop    tag
// p a e l s

type StartingLetter interface {
  GetRow() int
  GetCol() int
  GetChar() string
}

type SL struct {
  row int
  col int
  c string
}

func (sl *SL) GetRow() int {
  return sl.row
}

func (sl *SL) GetCol() int {
  return sl.col
}

func (sl *SL) GetChar() string {
  return sl.c
}


type Matrix struct {
	dim int
	self [][]string
	words []string
}

func CreateMatrix(dim int, words []string, sls []SL) *Matrix {
	matrix := Matrix{
		dim: dim,
		self: make([][]string, dim),
		words: words,
	}

	for i := range matrix.self {
		matrix.self[i] = make([]string, dim)
		for j := range matrix.self[i] {
			matrix.self[i][j] = "-"
		}
	}

  for _, sl := range sls {
    matrix.self[sl.GetRow()][sl.GetCol()] = sl.GetChar()
  }

	return &matrix
}

func CreateAnswer(dim int, rows []string) *Matrix {
  matrix := Matrix{
    dim: dim,
    self: make([][]string, dim),
    words: rows,
  }

  for i := range matrix.self {
		matrix.self[i] = make([]string, dim)
		for j := range matrix.self[i] {
			matrix.self[i][j] = string(rows[i][j])
		}
	}

  return &matrix
}

func IsSolved(m *Matrix, a *Matrix) bool {
  for i := range m.self {
    for j := range m.self[i] {
      if m.self[i][j] != a.self[i][j] {
        return false
      }
    }
  }
  return true
}

func CheckStartingChar(x int, y int, sls []SL) bool {
  for _, sl := range sls {
    if sl.GetRow() == x && sl.GetCol() == y {
      return true
    }
  }
  return false
}

func IsAlpha(s string) bool {
  pattern := "^[a-zA-Z]+$"
  matched, _ := regexp.MatchString(pattern, s)
  return matched
}

func GetChar() string {
  var b []byte = make([]byte, 3)
  os.Stdin.Read(b)
  if b[1] == 0 && b[2] == 0 {
    return string(b[0])
  } else {
    return string(b)
  }
}

func csi(s string) {
  fmt.Print("\x1b[" + s)
}

func RunCommand(s ...string) {
  cmd := exec.Command(s[0], s[1])
  cmd.Stdin = os.Stdin
  cmd.Run()
}

func InitializeTerminal() {
  RunCommand("stty", "raw") // stop buffering keypresses
  csi("?47h") // save current screen
  csi("?25l") // make cursor invisible
}

func RestoreTerminal() {
  RunCommand("stty", "sane") // restore keypress handling
  csi("?25h") // make cursor visible again
  csi("?47l") // restore original screen
}

func PrintUsingColor(color_code string, text string) {
  // colors here: https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
  csi(color_code)
  fmt.Print(text)
  csi("0m") // reset colors
}

func DrawDisplay(matrix *Matrix, pos []int, c string, sls []SL) {
  csi("2J") // clear the screen
  csi("H") // move to home position (row=1, col=1)

	wi := 0
	wl := len(matrix.words)
	// Words Per Line
	wpl := 2

	for i := range matrix.self {
		for _, val := range matrix.self[i] {
			fmt.Print(val, " ")
		}
		for k := 0 ; wi < wl && k < wpl; k, wi = k+1, wi+1 {
			fmt.Print("\t", matrix.words[wi])
		}
		fmt.Println("\r")
	}

	fmt.Println()

  PrintUsingColor("42m", "press arrow keys to move, press character to insert,\r\n")
  PrintUsingColor("42m", "q to quit\r\n")
  csi("49m") // default background color

  // draw character at position pos
  csi(strconv.Itoa(pos[0]) + ";" + strconv.Itoa(pos[1]) + "H")
  x := pos[0] - 1
  y := pos[1] / 2
  if IsAlpha(c) && !CheckStartingChar(x, y, sls) {
    PrintUsingColor("33m", c)
  } else {
    PrintUsingColor("33m", "@")
  }
}

func HandleKeypress(c string, matrix *Matrix, pos []int, dim int, sls []SL) {
  // c is keypress, pos is current position
  switch c {
  case "q":
    CleanExit("Quitting Search")
  case "\x1b[D":
    pos[1] -= 2
		if pos[1] < 1 {
			pos[1] = 1
		}
  case "\x1b[A":
    pos[0] -= 1
		if pos[0] < 1 {
			pos[0] = 1
		}
  case "\x1b[B":
    pos[0] += 1
		if pos[0] > dim {
			pos[0] = dim
		}
  case "\x1b[C":
    pos[1] += 2
		if pos[1] > (2*dim) - 1 {
			pos[1] = (2*dim) - 1
		}
  }

  
  if IsAlpha(c) {
    x := pos[0] - 1
    y := pos[1] / 2

    if !CheckStartingChar(x, y, sls) {
      matrix.self[x][y] = c
    }
  }
}

func CleanExit(message string) {
  RestoreTerminal()
  if message != ""  {
    fmt.Println(message)
  }
  os.Exit(0)
}

func main() {
	InitializeTerminal()
	dim := 5
	words := []string{"angle", "blank", "leap", "link", "sink", "snack", "stop", "tag"}
  sls := []SL{{0,0,"b"}, {0,2,"a"},{1,0,"s"},{2,0,"t"},{3,1,"*"},{4,3,"l"},{4,4,"s"}}

	matrix := CreateMatrix(5, words, sls)
  answer := CreateAnswer(5, []string{"blank", "sinkc", "tagna", "o*lin", "paels"})
  
  pos := []int{1, 3}

  DrawDisplay(matrix, pos, "", sls)
  for {
    c := GetChar()
    HandleKeypress(c, matrix, pos, dim, sls)
    DrawDisplay(matrix, pos, c, sls)

    if IsSolved(matrix, answer) {
      CleanExit("You Win")
    }
  }
}
