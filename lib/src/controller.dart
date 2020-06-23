part of virusgame;

/*
This class is the controller of the MVC model. It manages all resources of the game.
It creates the game, initializes everything, handles level changes, runs and stops the game
and acts as a communicator between the game engine and the gui.
 */
class VirusController {
  //boolean to save whether game is played on mobile or desktop browser
  bool _mobile;

  //timer to trigger a new frame periodically
  Timer _frameTrigger;

  //the game engine
  VirusGame _game;

  //the gui
  VirusView _view;

  //switches for player movement input, so movement speed is only set once when input is continuous
  bool _left, _right;

  VirusController(bool local) {
    //create entry in local storage if not already present
    html.window.localStorage.putIfAbsent('ktv', () => '1');

    //create a new game
    _game = VirusGame(local);
    _view = VirusView();

    //initialize menu
    _view.initialize(_game);
    _view.updateLvlButtons(_game);

    //hide resume button, since no level is loaded yet
    html.querySelector('#resume').hidden = true;

    /*
    Set initial state to mobile, because otherwise it must be set on every device rotation event, which
    costs resources. When played on a desktop browser, this event is called only one time, so we can change
    it in the corresponding event listener without setting the image source constantly
     */
    _mobile = true;
    (html.querySelector('#help-screen-backgrnd') as html.ImageElement).srcset =
        './data/img/help_backgrnd.png';
    (html.querySelector('#help-screen') as html.ImageElement).srcset =
        './data/img/help_mobile.png';
    //hide help-screen
    html.querySelector('#help-screen').hidden = true;
    html.querySelector('#help-screen-backgrnd').hidden = true;
    html.querySelector('#qr').hidden = true;

    _frameTrigger =
        Timer.periodic(Duration(milliseconds: 15), (t) => updateGame());

    //create listeners for the buttons

    //create listeners for all level buttons
    html.querySelectorAll('.level').onClick.listen((e) {
      var number =
          int.parse((e.currentTarget as html.HtmlElement).getAttribute('lvl'));
      if (_game.max_level >= number) {
        _view.clear(_game);
        //read property "lvl" from the element
        _game.level = number;
        _view.animate(html.querySelector('.level[lvl=\"$number\"]'),
            'turningNumbers', 500, () {
          _view.clear(_game);
          _view.animate(html.querySelector('.level[lvl=\"$number\"]'),
              'turningNumbersBack', 0, () {});
          _game.loadLevel().then((res) {
            _view.clear(_game);
            html.querySelector('#resume').hidden = false;
            html.querySelector('#menu').hidden = true;
            _view.initialize(_game);
            _game.running = true;
          });
        });
      }
    });

    html.querySelector('#resume').onClick.listen((e) {
      html.querySelector('#menu').hidden = true;
      _game.running = true;
    });

    html.querySelector('#help').onClick.listen((e) {
      html.querySelector('#help-screen').hidden = false;
      html.querySelector('#help-screen-backgrnd').hidden = false;
    });

    html.querySelector('#help-screen').onClick.listen((e) {
      html.querySelector('#help-screen').hidden = true;
      html.querySelector('#help-screen-backgrnd').hidden = true;
    });

    html.querySelector('#menu-button').onClick.listen((e) {
      _game.running = false;
      html.querySelector('#menu').hidden = false;
    });

    /*
    When a key is pressed / the device rotated into one direction,
    set the corresponding boolean so the event only adds the
    velocity once to the player (otherwise he would accelerate).

    When the key is released / the device rotated into resting position,
    the boolean is reset and also the opposite velocity is
    added to the player, to stop the movement.

    This only gives a direction for the velocity, the speed is multiplied to it
    in the game engine.
     */
    //set initial values for key booleans to false
    _left = _right = false;

    html.window.onDeviceOrientation.listen((html.DeviceOrientationEvent e) {
      //determine if this is played on desktop or mobile browser and select correct help-screen
      if (e.alpha == null && e.beta == null && e.gamma == null) {
        _mobile = false;
        (html.querySelector('#help-screen') as html.ImageElement).srcset =
            './data/img/help_desktop.png';
        html.querySelector('#menu-button').hidden = true;
        //show qr-code
        html.querySelector('#qr').hidden = false;

        return;
      }

      if (_view.format) {
        if (e.gamma < 0) {
          _game.setPlayerMovement(max(e.gamma / 5, -1));
        }
        if (e.gamma > 0) {
          _game.setPlayerMovement(min(e.gamma / 5, 1));
        }
      } else {
        if (e.beta < 0) {
          _game.setPlayerMovement(max(e.beta / 5, -1));
        }
        if (e.beta > 0) {
          _game.setPlayerMovement(min(e.beta / 5, 1));
        }
      }
    });

    html.querySelector('html').onTouchStart.listen((e) {
      _game.playerJump();
    });

    html.querySelector('body').onKeyDown.listen((html.KeyboardEvent e) {
      if (e.keyCode == html.KeyCode.LEFT && !_left) {
        _left = true;
        _game.movePlayer(-1);
      }
      if (e.keyCode == html.KeyCode.RIGHT && !_right) {
        _right = true;
        _game.movePlayer(1);
      }
      if (e.keyCode == html.KeyCode.SPACE) {
        _game.playerJump();
      }

      if (e.keyCode == html.KeyCode.ESC) {
        _game.running = false;
        html.querySelector('#menu').hidden = false;
      }
    });

    html.querySelector('body').onKeyUp.listen((html.KeyboardEvent e) {
      if (e.keyCode == html.KeyCode.LEFT && _left) {
        _left = false;
        _game.movePlayer(1);
      }
      if (e.keyCode == html.KeyCode.RIGHT && _right) {
        _right = false;
        _game.movePlayer(-1);
      }
    });

    html.window.onResize.listen((e) {
      _view.clear(_game);
      _view.initialize(_game);
    });
  }

  void updateGame() {
    //update the frame if game is running
    if (_game.isRunning) {
      //update and check if player died and stop game if this is the case
      if (_game.update()) {
        //animation
        _view.animate(_game.objects[0].html_element, 'die', 2000, () {
          _game.running = false;
          html.querySelector('#menu').hidden = false;
          html.querySelector('#resume').hidden = true;
        });
      }

      //check if game level is won
      if (_game.won) {
        //stop game
        _view.animate(_game.objects[0].html_element, 'win', 3000, () {
          html.querySelector('#menu').hidden = false;
          html.querySelector('#resume').hidden = true;

          _view.updateLvlButtons(_game);
        });

        _game.running = false;
        if (_game.max_level < 10 && _game.level == _game.max_level) {
          _game.max_level = _game.max_level + 1;
          //save level to local storage
          html.window.localStorage
              .update('ktv', (lvl) => lvl = '${_game.max_level}');
        }
      }

      _view.update(_game);
    }
  }
}
