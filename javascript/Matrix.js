export class Matrix {
  constructor(dim, sls, words) {
    this.dim = dim;
    this.sls = sls;
    this.words = words;
    this.self = null;
    this.createMatrix();
  }

  createMatrix() {
    this.self = new Array(this.dim);
    for (let i = 0; i < this.dim; i++) {
      this.self[i] = new Array(this.dim);
      for (let j = 0; j < this.dim; j++) {
        this.self[i][j] = '-';
      }
    }

    for (let sl of this.sls) {
      this.self[sl[0]][sl[1]] = sl[2];
    }
  }

  display() {
    let wi = 0;
    const wl = this.words.length;

    const wpl = 2;

    for (let i = 0; i < this.dim; i++) {
      for (let j = 0; j < this.dim; j++) {
        process.stdout.write(this.self[i][j] + ' ');
      }

      for (let k = 0; wi < wl && k < wpl; k++, wi++) {
        process.stdout.write('\t');
        process.stdout.write(this.words[wi]);
      }

      process.stdout.write('\n');
    }
  }
}

export class AnswerMatrix {
  constructor(dim, answer) {
    this.dim = dim;
    this.answer = answer;
    this.self = null;
    this.createMatrix();
  }

  createMatrix() {
    this.self = new Array(this.dim);
    for (let i = 0; i < this.dim; i++) {
      this.self[i] = new Array(this.dim);
      for (let j = 0; j < this.dim; j++) {
        this.self[i][j] = this.answer[i][j];
      }
    }
  }

  check(test) {
    for (let i = 0; i < this.dim; i++) {
      for (let j = 0; j < this.dim; j++) {
        if (this.self[i][j] != test.self[i][j]) {
          return false;
        }
      }
    }
    return true;
  }
}
