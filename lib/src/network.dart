part of virusgame;

class Matrix {
  List<List<double>> _mat;
  final int _rows;
  final int _cols;

  Matrix(this._rows, this._cols) {
    _mat = List<List<double>>(_rows);
    for (var i = 0; i < _rows; ++i) {
      _mat[i] = List<double>(_cols);
    }
  }

  int get rows => _rows;

  int get cols => _cols;

  double val(int i) => _mat[i ~/ _cols][i % _cols];

  Matrix row(int i) {
    var out = Matrix(1, _cols);

    for (var j = 0; j < _cols; ++j) {
      out.setVal(0, j, _mat[i][j]);
    }

    return out;
  }

  Matrix col(int j) {
    var out = Matrix(_rows, 1);

    for (var i = 0; i < _rows; ++i) {
      out.setVal(i, 0, _mat[i][j]);
    }

    return out;
  }

  double at(int i, int j) => _mat[i][j];

  void setVal(int i, int j, double val) => _mat[i][j] = val;

  double sProd(Matrix m1, Matrix m2) {
    var res = 0.0;

    for (var i = 0; i < m1.cols * m1.rows; ++i) {
      res += m1.val(i) * m2.val(i);
    }

    return res;
  }

  Matrix operator *(Matrix m) {
    var res = Matrix(_rows, m.cols);

    for (var i = 0; i < _rows; ++i) {
      for (var j = 0; j < m.cols; ++j) {
        res.setVal(i, j, sProd(row(i), m.col(j)));
      }
    }

    return res;
  }

  Matrix operator +(Matrix m) {
    var res = Matrix(_rows, _cols);

    for (var i = 0; i < _rows; ++i) {
      for (var j = 0; j < _cols; ++j) {
        res.setVal(i, j, _mat[i][j] + m.at(i, j));
      }
    }

    return res;
  }

  Matrix operator -(Matrix m) {
    var res = Matrix(_rows, _cols);

    for (var i = 0; i < _rows; ++i) {
      for (var j = 0; j < _cols; ++j) {
        res.setVal(i, j, _mat[i][j] - m.at(i, j));
      }
    }

    return res;
  }

  Matrix clone() {
    var clone = Matrix(_rows, _cols);
    for (var i = 0; i < _rows; ++i) {
      for (var j = 0; j < _cols; ++j) {
        clone.setVal(i, j, _mat[i][j]);
      }
    }

    return clone;
  }

  Matrix map(double Function(double) f) {
    for (var i = 0; i < _rows; ++i) {
      for (var j = 0; j < _cols; ++j) {
        _mat[i][j] = f(_mat[i][j]);
      }
    }

    return this;
  }

  @override
  String toString() {
    var out = '';

    for (var i = 0; i < _rows; ++i) {
      for (var j = 0; j < _cols; ++j) {
        out += _mat[i][j].toString() + '    ';
      }
      out += '\n';
    }

    return out;
  }
}

class Network {
  List<Matrix> _net;
  List<Matrix> _bias;
  final _random = Random();
  final int _memory_size = 4;
  Matrix _memory;

  Network(List<int> structure) {
    _net = List<Matrix>(structure.length - 1);
    _bias = List<Matrix>(structure.length - 1);

    for (var i = 1; i < structure.length; ++i) {
      if (i == 1) {
        _net[i - 1] = Matrix(structure[i], structure[i - 1] + _memory_size)
            .map((d) => (-1000 + _random.nextInt(2000)) / 1000);
        _bias[i - 1] = Matrix(structure[i], 1)
            .map((d) => (-1000 + _random.nextInt(2000)) / 1000);
      } else if (i == structure.length - 1) {
        _net[i - 1] = Matrix(structure[i] + _memory_size, structure[i - 1])
            .map((d) => (-1000 + _random.nextInt(2000)) / 1000);
        _bias[i - 1] = Matrix(structure[i] + _memory_size, 1)
            .map((d) => (-1000 + _random.nextInt(2000)) / 1000);
      } else {
        _net[i - 1] = Matrix(structure[i], structure[i - 1])
            .map((d) => (-1000 + _random.nextInt(2000)) / 1000);
        _bias[i - 1] = Matrix(structure[i], 1)
            .map((d) => (-1000 + _random.nextInt(2000)) / 1000);
      }
    }

    _memory = Matrix(_memory_size, 1).map((d) => 0);
  }

  Network.loadNet(List mat) {
    _net = List<Matrix>(mat.length ~/ 2);
    _bias = List<Matrix>(mat.length ~/ 2);

    for (var i = 0; i < mat.length ~/ 2; ++i) {
      _net[i] = mat[i * 2];
      _bias[i] = mat[i * 2 + 1];
    }
  }

  Network clone() {
    var structure = List<int>(_net.length + 1);
    structure[0] = _net[0].cols;
    for (var i = 0; i < _net.length; ++i) {
      structure[i + 1] = _net[i].rows;
    }
    var clone = Network(structure);

    for (var i = 0; i < _net.length; ++i) {
      clone._net[i] = _net[i].clone();
      clone._bias[i] = _bias[i].clone();
    }

    return clone;
  }

  Matrix forward(Matrix input) {
    var mem_input = Matrix(input.rows + _memory_size, 1);

    for (var i = 0; i < input.rows; ++i) {
      mem_input.setVal(i, 0, input.at(i, 0));
    }
    for (var i = 0; i < _memory_size; ++i) {
      mem_input.setVal(input.rows + i, 0, _memory.at(i, 0));
    }

    input = mem_input;

    for (var i = 0; i < _net.length; ++i) {
      input = _net.elementAt(i) * input + _bias.elementAt(i);

      for (var j = 0; j < input.rows; ++j) {
        //input.setVal(j, 0, 1 / (1 + exp(-input.at(j, 0))));
        input.setVal(j, 0, atan(input.at(j, 0) * 2 / pi));
      }
    }

    return input;
  }

  double cut(double limit, double val) {
    if (val > limit) {
      return limit;
    }
    if (val < -limit) {
      return -limit;
    }

    return val;
  }

  void mutate(double rate) {
    _net.forEach((m) => m
        .map((d) => cut(3, d + rate * (-1000 + _random.nextInt(2000)) / 1000)));
    _bias.forEach((m) => m
        .map((d) => cut(3, d + rate * (-1000 + _random.nextInt(2000)) / 1000)));
  }

  @override
  String toString() {
    var out = '';

    for (var i = 0; i < _net.length; ++i) {
      out += _net[i].toString() + '\n';
      out += _bias[i].toString() + '\n';
    }

    return out;
  }

  String toJSON() {
    var net = [];

    for (var x = 0; x < _net.length; ++x) {
      var map = {
        'type': 'layer',
        'rows': '${_net[x].rows}',
        'cols': '${_net[x].cols}'
      };
      for (var i = 0; i < _net[x].rows; ++i) {
        for (var j = 0; j < _net[x].cols; ++j) {
          map.addAll({'${i},$j': '${_net[x].at(i, j)}'});
        }
      }
      net.add(map);

      map = {'type': 'bias', 'rows': '${_bias[x].rows}', 'cols': '1'};
      for (var i = 0; i < _bias[x].rows; ++i) {
        map.addAll({'${i},0': '${_bias[x].at(i, 0)}'});
      }
      net.add(map);
    }

    return jsonEncode(net);
  }
}
