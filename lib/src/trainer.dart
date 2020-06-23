part of virusgame;

class Trainer {
  //timer to trigger a new frame periodically
  Timer _frameTrigger;

  //time limit for each generation
  Timer _generationTimer;

  //the game engine
  VirusGame _game;

  //the gui
  VirusView _view;

  var _lvlCtr = -1;

  Trainer() {
    //create a new local game
    _game = VirusGame(true);
    _view = VirusView();

    //initialize menu
    _view.initialize(_game);

    html.querySelector('#resume').hidden = false;
    html.querySelector('#menu').hidden = true;

    html.window.onKeyDown.listen((key) {
      if (key.keyCode == html.KeyCode.ESC) {
        _generationTimer.cancel();
        evaluateTraining();
      }
      if (key.keyCode == html.KeyCode.SPACE) {
        _generationTimer.cancel();
        _frameTrigger.cancel();

        _game.running = false;
        _view.clear(_game);

        html.HttpRequest.getString(
                Uri.http('localhost:80', '/data/network1.json').toString())
            .then((r) {
          final brainData = jsonDecode(r);

          var matrices = [];
          for (var m in brainData) {
            var mat = Matrix(int.parse(m['rows']), int.parse(m['cols']));
            for (var i = 0; i < mat.rows; ++i) {
              for (var j = 0; j < mat.cols; ++j) {
                mat.setVal(i, j, double.parse(m['${i},${j}']));
              }
            }
            matrices.add(mat);
          }
          var brain = Network.loadNet(matrices);

          _game.loadLevel().then((res) {
            _view.initialize(_game);
            //share genes of fittest individual
            _game.objects
                .whereType<Enemy>()
                .forEach((e) => e.brain = brain.clone());

            _game.running = true;
          });

          _generationTimer = Timer(Duration(seconds: 15), evaluateTraining);
          _frameTrigger = Timer(Duration(microseconds: 10), updateTraining);
        });
      }
    });

    _generationTimer = Timer(Duration(seconds: 15), evaluateTraining);
    _frameTrigger = Timer(Duration(microseconds: 10), updateTraining);

    _view.clear(_game);
    _game.level = _lvlCtr--;
    _game.loadLevel().then((res) {
      _view.initialize(_game);
      _game.running = true;
    });
  }

  void evaluateTraining() {
    _game.running = false;

    var fittest = _game.objects[1] as Enemy;

    for (var o in _game.objects) {
      if (o is Enemy) {
        if (((o.pos - _game.objects[0].pos).length <
                    (fittest.pos - _game.objects[0].pos).length &&
                fittest.playerClose == o.playerClose) ||
            (o.playerClose && !fittest.playerClose)) {
          fittest = o;
        }
      }
    }

    http.post(Uri.http('localhost:80', '').toString(),
        body: fittest.brain.toJSON());

    //restart level with new generation
    _view.clear(_game);
    _game.level = _lvlCtr--;

    if (_lvlCtr == -5) {
      _lvlCtr = -1;
    }

    _game.loadLevel().then((res) {
      _view.initialize(_game);
      //share genes of fittest individual
      _game.objects
          .whereType<Enemy>()
          .forEach((e) => e.brain = fittest.brain.clone());
      //mutate each enemy
      _game.objects.whereType<Enemy>().forEach((e) => e.brain.mutate(0.03));
      (_game.objects[1] as Enemy).brain = fittest.brain.clone();

      _game.running = true;
    });

    _generationTimer = Timer(Duration(seconds: 15), evaluateTraining);
  }

  void updateTraining() {
    //update the frame if game is running
    if (_game.isRunning) {
      //update
      _game.update();
      _view.update(_game);

      if (_game.objects.where((e) => e is Enemy && e.playerClose).isNotEmpty) {
        _generationTimer.cancel();
        evaluateTraining();
      }
    }

    _frameTrigger = Timer(Duration(microseconds: 10), updateTraining);
  }
}
