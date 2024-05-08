import readline from 'readline';
import { Matrix, AnswerMatrix } from './Matrix.js';

// b l a n k     angle   blank
// s i n k c     leap    link
// t a g n a     sink    snack
// o * l i n     stop    tag
// p a e l s

const csi = (s) => {
  process.stdout.write('\x1b[' + s);
};

const initializeTerminal = () => {
  csi('?47h'); // Save current screen
  csi('?25l'); // Make cursor invisible
  process.stdin.setRawMode(true);
};

const restoreTerminal = () => {
  process.stdin.setRawMode(false);
  csi('?25h'); // Make cursor visible again
  csi('?47l'); // Restore original screen
  csi('2J'); // Clear screen
  csi('0;0H'); // Move cursor to top left
};

const checkStartingChar = (i, j, sls) => {
  const x = i - 1;
  const y = Math.floor(j / 2);
  for (let sl of sls) {
    if (sl[0] === x && sl[1] === y) {
      return true;
    }
  }
  return false;
};

const handleKeypress = (matrix, key, pos) => {
  const c = key.name;
  let isArrow = false;
  switch (c) {
    case 'escape':
      restoreTerminal();
      process.exit();
    case 'up':
      pos[0]--;
      isArrow = true;
      if (pos[0] < 1) {
        pos[0] = 1;
      }
      break;
    case 'down':
      pos[0]++;
      isArrow = true;
      if (pos[0] > matrix.dim) {
        pos[0] = matrix.dim;
      }
      break;
    case 'left':
      pos[1] -= 2;
      isArrow = true;
      if (pos[1] < 1) {
        pos[1] = 1;
      }
      break;
    case 'right':
      pos[1] += 2;
      isArrow = true;
      if (pos[1] > matrix.dim * 2 - 1) {
        pos[1] = matrix.dim * 2 - 1;
      }
      break;
  }

  if (
    c.charCodeAt(0) &&
    !isArrow &&
    !checkStartingChar(pos[0], pos[1], matrix.sls)
  ) {
    matrix.self[pos[0] - 1][Math.floor(pos[1] / 2)] = c;
    return { pos, c };
  } else {
    return { pos, c: '' };
  }
};

const drawDisplay = (matrix, pos, c) => {
  csi('2J');
  csi('H');

  matrix.display();

  process.stdout.write('\n');
  csi('42m');
  process.stdout.write(
    'press arrow keys to move, press character to insert,\n'
  );
  process.stdout.write('escape to quit');
  csi('49m');

  csi(pos[0] + ';' + pos[1] + 'H');

  csi('33m');

  if (c.charCodeAt(0) && !checkStartingChar(pos[0], pos[1], matrix.sls)) {
    process.stdout.write(c);
  } else {
    process.stdout.write('@');
  }
  csi('0m');
};

const main = () => {
  initializeTerminal();
  const dim = 5;
  const words = [
    'angle',
    'blank',
    'leap',
    'link',
    'sink',
    'snack',
    'stop',
    'tag',
  ];
  const sls = [
    [0, 0, 'b'],
    [0, 2, 'a'],
    [1, 0, 's'],
    [2, 0, 't'],
    [3, 1, '*'],
    [4, 3, 'l'],
    [4, 4, 's'],
  ];

  const strAnswer = ['blank', 'sinkc', 'tagna', 'o*lin', 'paels'];

  const matrix = new Matrix(dim, sls, words);
  const answerMatrix = new AnswerMatrix(dim, strAnswer);

  readline.emitKeypressEvents(process.stdin);

  let pos = [1, 3];
  let c = '';
  drawDisplay(matrix, pos, c);

  process.stdin.on('keypress', (_, key) => {
    ({ pos, c } = handleKeypress(matrix, key, pos));
    drawDisplay(matrix, pos, c);

    if (answerMatrix.check(matrix)) {
      restoreTerminal();
      csi('33m');
      process.stdout.write('You Win!!!');
      csi('0m');
      process.exit();
    }
  });
};

main();
