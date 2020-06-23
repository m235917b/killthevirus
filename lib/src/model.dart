part of virusgame;

const double PLAYER_VEL = 3;
const double GRAVITY = 1;

/*
Model part of MVC for the Game.

Positions, directions, velocities, accelerations, and other 2-dimensional values are modelled by objects
of the class "Vector". Note that the origin for coordinates is the top left corner of the browser screen
while positive x direction is to the right and positive y direction to the bottom of the screen.

Behaviour of movable objects is calculated via simple newtonian equations, which makes handling of the
physics engine easier and makes the game more extensible.

Every coordinate is saved in integer pairs, since the game engine is pixel based.
 */

//class that represents a 2-dimensional vector
class Vector {
  //x and y coordinates
  final double _x;
  final double _y;

  const Vector(this._x, this._y);

  //operator definitions for standard vector arithmetics
  Vector operator +(Vector v) => Vector(_x + v._x, _y + v._y);

  Vector operator -(Vector v) => Vector(_x - v._x, _y - v._y);

  Vector operator *(double i) => Vector(_x * i, _y * i);

  Vector operator /(double i) => Vector(_x / i, _y / i);

  @override
  bool operator ==(Object v) =>
      _x == (v as Vector)._x && _y == (v as Vector)._y;

  double get x => _x;

  double get y => _y;

  //get pythagorean length of vector
  double get length => sqrt(_x * _x + _y * _y);

  //is the vector = (0, 0)?
  bool get isZero => _x == 0 && _y == 0;

  @override
  String toString() => '($_x' ', ' '$_y' ')';
}

/*
class that represents all objects inside the game world;
each object is a simple rectangle with an image as a texture;
 */
class WorldObject {
  //position of top left corner
  Vector _position;

  /*
  width and height saved as a vector that spans diagonally
  from the top left to the bottom right corner
   */
  final Vector _dimensions;
  Vector _velocity;
  Vector _acceleration;

  //file name of the texture without path or file extension
  String _texture;

  html.ImageElement _img;

  WorldObject(this._position, this._dimensions, this._texture, this._velocity,
      this._acceleration);

  Vector get pos => _position;

  Vector get dim => _dimensions;

  set acceleration(Vector a) => _acceleration = a;

  set velocity(Vector v) => _velocity = v;

  //this method adds a speed vector to the current speed
  void giveVelocity(Vector v) => _velocity += v;

  String get texture => _texture;

  html.ImageElement get html_element => _img;

  set html_element(html.ImageElement e) => _img = e;

  //moves the object to position + dir
  void move(Vector dir) => _position = _position + dir;

  /*
  calculate new velocity based on current
  acceleration and new position based on this velocity
  and update object based on its behaviour
   */
  void update() {
    /*
    set constraint on velocity; if it gets too high, the objects would
    start to glitch through solids because collision can no longer be
    detected
     */
    if (_velocity.x.abs() >= 20) {
      _velocity = Vector(20 * _velocity.x.sign, _velocity.y);
    }
    if (_velocity.y.abs() >= 20) {
      _velocity = Vector(_velocity.x, 20 * _velocity.y.sign);
    }

    _position += _velocity;
    /*
    acceleration must be added to velocity after the position is updated,
    to ensure, that its effect can be nullified, if a collision in that
    direction happens (see collidesWith() and VirusGame::update())
     */
    _velocity += _acceleration;
  }

  //method to handle collision events, if they happened
  void collision(WorldObject o, Vector setback) {
    //when a collision happened:
    if (!(o is Player ||
        o is Enemy ||
        o is Virus ||
        o is Switch ||
        setback.isZero ||
        this == o)) {
      //if a movable object hit a solid object, set it to closest border of that object
      move(setback);
      /*
       Set all velocities on that object that go into the direction of collision
       to 0 in that component, so the object stops being accelerated.
       */
      if (setback.x.sign == -_velocity.x.sign) {
        velocity = Vector(0, _velocity.y);
      }
      if (setback.y.sign == -_velocity.y.sign) {
        _velocity = Vector(_velocity.x, 0);
      }
    }
  }

  /*
  Checks if this object x is colliding with another object o by first checking for each corner
  of x if this corner is inside o. If this is the case, the vector v from the colliding corner
  to the corresponding corner of o that geometrically now also must lie inside x is calculated.

  Then the shortest path to the next edge is calculated and returned as a vector. This return
  value can then be used by the engine, to push the object back in case of a collision.

  Since the calculations for each corner are not commutative but ordered clockwise beginning
  from the top left corner, this algorithm can lead to bugs, if more than three corners are
  within o, but since this situation is considered a bug anyway, this behaviour is tolerated.

  A collision must be detected even one pixel before the edge, so accelerations of objects can
  be nullified in the direction of collision one frame before they take effect. Otherwise the
  behaviour of collisions near corners is buggy (for example, when the player moves slower
  than gravitational pull per frame, and he moves over a corner of an object, the game would
  set the players movement back, since the shortest path out of the object is taken for this)
   */
  Vector collidesWith(WorldObject o) {
    //if top left corner is inside o
    if (_position.x >= o.pos.x &&
        _position.x <= o.pos.x + o.dim.x &&
        _position.y >= o.pos.y &&
        _position.y <= o.pos.y + o.dim.y) {
      final v = (o.pos + o.dim) - _position;
      return v.x.abs() < v.y.abs() ? Vector(v.x, 0) : Vector(0, v.y);
    }

    //if top right corner is inside o
    if (_position.x + _dimensions.x >= o.pos.x &&
        _position.x + _dimensions.x <= o.pos.x + o.dim.x &&
        _position.y >= o.pos.y &&
        _position.y <= o.pos.y + o.dim.y) {
      final v =
          (o.pos + Vector(0, o.dim.y)) - (_position + Vector(_dimensions.x, 0));
      return v.x.abs() < v.y.abs() ? Vector(v.x, 0) : Vector(0, v.y);
    }

    //if bottom right corner is inside o
    if (_position.x + _dimensions.x >= o.pos.x &&
        _position.x + _dimensions.x <= o.pos.x + o.dim.x &&
        _position.y + _dimensions.y >= o.pos.y &&
        _position.y + _dimensions.y <= o.pos.y + o.dim.y) {
      final v = o.pos - (_position + _dimensions);
      return v.x.abs() < v.y.abs() ? Vector(v.x, 0) : Vector(0, v.y);
    }

    //if bottom left corner is inside o
    if (_position.x >= o.pos.x &&
        _position.x <= o.pos.x + o.dim.x &&
        _position.y + _dimensions.y >= o.pos.y &&
        _position.y + _dimensions.y <= o.pos.y + o.dim.y) {
      final v =
          (o.pos + Vector(o.dim.x, 0)) - (_position + Vector(0, _dimensions.y));
      return v.x.abs() < v.y.abs() ? Vector(v.x, 0) : Vector(0, v.y);
    }

    return Vector(0, 0);
  }
}

/*
this extension class of "WorldObject" models all objects that are static and don't have
any movement on their own
 */
class StaticObject extends WorldObject {
  StaticObject(Vector pos, Vector dim, String tex)
      : super(pos, dim, tex, Vector(0, 0), Vector(0, 0));

  //this object has no internal behaviour
  @override
  void update() {}

  //this object don't need to handle collision since its static
  @override
  void collision(WorldObject o, Vector setback) {}
}

//this class models the player
class Player extends WorldObject {
  int _life = 3;

  //boolean to safe whether the blob is currently on solid ground or not
  bool _onGround = false;

  /*
  integer to safe where the blob is looking; needed for the correct textures;
  -1 = left, 0 = no change, 1 = right
   */
  int _lookDir = 0;

  Player(Vector pos, Vector velocity, Vector acceleration)
      : super(pos, Vector(32, 32), 'player', velocity, acceleration);

  //is player dead?
  bool get isDead => _life <= 0 ? true : false;

  int get health => _life;

  int get direction => _lookDir;

  //remove a life point
  void removeLife() => --_life;

  //add a life point
  void addLife() => ++_life;

  //reset life points to 3
  void resetLife() => _life = 3;

  set direction(int d) => _lookDir = d;

  @override
  void update() {
    /*
    reset _onGround; this is reverted, when the game detected, that the player
    is on solid ground after the collision calculations
     */
    _onGround = false;
    /*
    set constraint on velocity; if it gets too high, the objects would
    start to glitch through solids because collision can no longer be
    detected
     */
    if (_velocity.x.abs() >= 20) {
      _velocity = Vector(20 * _velocity.x.sign, _velocity.y);
    }
    if (_velocity.y.abs() >= 20) {
      _velocity = Vector(_velocity.x, 20 * _velocity.y.sign);
    }

    _position += _velocity;
    /*
    acceleration must be added to velocity after the position is updated,
    to ensure, that its effect can be nullified, if a collision in that
    direction happens (see collidesWith() and VirusGame::update())
     */
    _velocity += _acceleration;

    if (_position.y > 5000) {
      _life = 0;
    }
  }

  //initialize a jumping process
  void jump() {
    /*
    player is only able to jump if it is on solid ground;
    this prevents blobs from being able to "fly"
     */
    if (_onGround) {
      /*
      adding an upward speed to the blob, which automatically leads to a jumping animation
      because of the newtonian behaviour of all objects in the physics engine (bc science works! :) )
       */
      giveVelocity(Vector(0, -15));
    }
  }

  //special behaviour for player on collision
  @override
  void collision(WorldObject o, Vector setback) {
    if (!(o is Player || o is Enemy || o is Virus)) {
      //when a collision happened:
      if (!setback.isZero) {
        //handle all different collision events

        //if player collided with a switch
        if (o is Switch) {
          //activate the switch
          o.activate();
          //player should not be blocked by a switch
          return;
        }

        //if player collided with a box
        if (o is Box) {
          //if a player collides with a box, it gets set back into the x direction
          o.move(Vector(-setback.x, 0));
        }

        move(setback);
        /*
       Set all velocities on that object that go into the direction of collision
       to 0 in that component, so the object stops being accelerated.
       */
        if (setback.x.sign == -_velocity.x.sign) {
          _velocity = Vector(0, _velocity.y);
        }
        if (setback.y.sign == -_velocity.y.sign) {
          _velocity = Vector(_velocity.x, 0);
        }
      }

      //set him down 10 pixel
      move(Vector(0, 10));
      //and check whether it then collides with something
      final setback2 = collidesWith(o);
      //when a collision happened: the blob must be on solid ground
      if (setback2.y.sign == -1) {
        _onGround = true;
      }
      //revert the changes of the position, so this temporary state wont be visible next frame
      move(Vector(0, -10));
    }
  }
}

//this class models the enemies; since its a special Blob it derives from that class
class Enemy extends WorldObject {
  /*
  integer to safe where the blob is looking; needed for the correct textures;
  -1 = left, 0 = no change, 1 = right
   */
  int _lookDir = 0;

  //neural network; the brain of the enemy
  Network _brain;

  //input vector for neural network; senses of the enemy
  final Matrix _senses;

  //Timer for reloading shots
  Timer _timer;
  bool _reloaded = true;

  //only for training purposes
  bool _playerClose = false;
  int _shots = 0;
  int _playerHits = 0;

  Enemy(Vector pos, Vector velocity, Vector acceleration)
      : _senses = Matrix(12, 1),
        _brain = Network([12, 15, 10, 8, 3]),
        super(pos, Vector(32, 32), 'enemy', velocity, acceleration);

  Network get brain => _brain;

  int get direction => _lookDir;

  bool get playerClose => _playerClose;

  int get shots => _shots;

  int get playerHits => _playerHits;

  set direction(int d) => _lookDir = d;

  set brain(Network n) => _brain = n;

  set shots(int n) => _shots = n;

  set playerHits(int n) => _playerHits = n;

  @override
  void update() {
    super.update();
    _senses.map((d) => 0);
  }

  bool vectorCollidesWith(Vector v, WorldObject o) {
    //if top left corner is inside o
    if (v.x >= o.pos.x &&
        v.x <= o.pos.x + o.dim.x &&
        v.y >= o.pos.y &&
        v.y <= o.pos.y + o.dim.y) {
      return true;
    }

    return false;
  }

  //special behaviour for Enemy on collision
  @override
  void collision(WorldObject o, Vector setback) {
    if (!(o == this || o is Virus)) {
      if (!(o is Player)) {
        //test for collision with sense vectors
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(0, -60), o)) {
          _senses.setVal(0, 0, 1);
        }
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(60, -60), o)) {
          _senses.setVal(1, 0, 1);
        }
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(60, 0), o)) {
          _senses.setVal(2, 0, 1);
        }
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(60, 60), o)) {
          _senses.setVal(3, 0, 1);
        }
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(0, 60), o)) {
          _senses.setVal(4, 0, 1);
        }
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(-60, 60), o)) {
          _senses.setVal(5, 0, 1);
        }
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(-60, 0), o)) {
          _senses.setVal(6, 0, 1);
        }
        if (vectorCollidesWith(
            pos + Vector(dim.x / 2, dim.y / 2) + Vector(-60, -60), o)) {
          _senses.setVal(7, 0, 1);
        }

        //when a collision happened:
        if (!setback.isZero) {
          //handle all different collision events

          //if an enemy hit a solid object, set it to closest border of that object
          move(setback);
          /*
          Set all velocities on that object that go into the direction of collision
          to 0 in that component, so the object stops being accelerated.
          */
          if (setback.x.sign == -_velocity.x.sign) {
            _velocity = Vector(0, _velocity.y);
          }
          if (setback.y.sign == -_velocity.y.sign) {
            _velocity = Vector(_velocity.x, 0);
          }
        }
      } else if (!setback.isZero) {
        _playerClose = true;
      }
    }
  }

  void action(List<WorldObject> objects) {
    //for performance only do something, if player is close
    if ((pos - objects[0].pos).length > 1000) {
      return;
    }

    //add vector to player position to the senses
    _senses.setVal(8, 0, (objects[0].pos - pos).x.sign);
    _senses.setVal(9, 0, (objects[0].pos - pos).y.sign);
    //add own velocity to the senses
    _senses.setVal(10, 0, _velocity.x.sign);
    _senses.setVal(11, 0, _velocity.y.sign);

    //process input with the neural network
    final out = _brain.forward(_senses);

    //set velocity according to the output of the neural net
    velocity = Vector(out.at(0, 0) * 1, out.at(1, 0) * 1);

    if (out.at(2, 0) > 0.5 && _reloaded) {
      ++_shots;
      final velocity = (objects[0].pos - pos) / (objects[0].pos - pos).length;
      var virus = Virus(pos + dim * 0.5, velocity * 5);
      virus.enemy = this;
      objects.add(virus);
      _reloaded = false;
      _timer = Timer(Duration(seconds: 3), reload);
    }

    //update looking direction
    if (out.at(0, 0) < 0) {
      _lookDir = -1;
    }
    if (out.at(0, 0) > 0) {
      _lookDir = 1;
    }
  }

  void reload() {
    _reloaded = true;
  }
}

/*
this class models the viruses that can be shot by the ai;
since they can have their own movement, they derive from MovableObject
 */
class Virus extends WorldObject {
  /*
  boolean, to save, whether the virus hit anything; VirusGame checks that after
  calculating collisions and then removes this virus, if it hit anything (_hit == true)
   */
  bool _hit;

  //for training purposes only
  Enemy _enemy;

  Virus(Vector pos, Vector velocity)
      : _hit = false,
        super(pos, Vector(10, 10), 'virus', velocity, Vector(0, 0));

  bool get hit => _hit;

  Enemy get enemy => _enemy;

  set enemy(Enemy e) => _enemy = e;

  @override
  void collision(WorldObject o, Vector setback) {
    if (!(setback.isZero || o is Virus || o is Enemy)) {
      /*
      virus hit anything, set _hit to false, so VirusGame can remove it
      and remove life from player if he got hit
       */
      _hit = true;
      if (o is Player) {
        o.removeLife();
        _enemy.playerHits = _enemy.playerHits + 1;
      }
    }
  }
}

//this class models the doors
class Door extends WorldObject {
  //saves whether the door is open or not
  bool _isOpen;

  Door(Vector pos)
      : _isOpen = false,
        super(pos, Vector(10, 150), 'door', Vector(0, 0), Vector(0, 0));

  bool get isOpen => _isOpen;

  //when door is opened, it is set 50 units up, so the player can pass through
  void open() {
    if (!_isOpen) {
      move(Vector(0, -50));
    }
    _isOpen = true;
  }

  //when door is closed, it is set 50 units down, so the player can't pass
  void close() {
    if (_isOpen) {
      move(Vector(0, 50));
    }
    _isOpen = false;
  }

  //a door has no internal behavior that changes every frame
  @override
  void update() {}

  /*
  If a movable object hits the door, it gets set back to the opposite
  direction. This symmetric collision handling is needed, because the
  door is so thin. If now a broader object hits it from above or below,
  collision sometimes is not detected otherwise (because no corner of
  the broader object is inside the door).
   */
  @override
  void collision(WorldObject o, Vector setback) {
    if (!(o is StaticObject || setback.isZero || o == this)) {
      o.move(setback * -1);
    }
  }
}

//this class models the switches
class Switch extends WorldObject {
  //saves whether the switch is activated or not
  bool _isActive;

  //saves the door that this switch opens
  final Door _door;

  Switch(Vector pos, this._door)
      : _isActive = false,
        super(pos, Vector(32, 10), 'switch_off', Vector(0, 0), Vector(0, 0));

  bool get isActive => _isActive;

  Door get door => _door;

  /*
  when a switch gets activated, its texture changes
  and the corresponding door gets opened
   */
  void activate() {
    _isActive = true;
    _door.open();
    _texture = 'switch_on';
    _img.srcset = './data/img/${_texture}.png';
  }

  /*
  when a switch gets deactivated, its texture changes
  and the corresponding door gets closed
   */
  void deactivate() {
    _isActive = false;
    _door.close();
    _texture = 'switch_off';
    _img.srcset = './data/img/${_texture}.png';
  }

  //deactivate switch every frame, so it only stays activated, when something is colliding with it
  @override
  void update() {
    deactivate();
  }

  //a gets activated, if it collides with something other than static objects
  @override
  void collision(WorldObject o, Vector setback) {
    if (!(o is StaticObject || o == this || setback.isZero)) {
      activate();
    }
  }
}

/*
this class models boxes that are movable by the player and can be used to activate
switches or climb up some obstacles
 */
class Box extends WorldObject {
  Box(Vector pos)
      : super(pos, Vector(64, 64), 'box', Vector(0, 0), Vector(0, GRAVITY));

  //method to handle collision events, if they happened
  @override
  void collision(WorldObject o, Vector setback) {
    //when a collision happened:
    if (!setback.isZero && this != o) {
      //handle all different collision events

      //if box collided with a switch
      if (o is Switch) {
        //activate the switch
        o.activate();
        //box should not be blocked by a switch
        return;
      }

      //if a movable object hit a solid object, set it to closest border of that object
      if (!(o is Player || o is Enemy || o is Virus)) {
        move(setback);
        /*
        Set all velocities on that object that go into the direction of collision
        to 0 in that component, so the object stops being accelerated.
         */
        if (setback.x.sign == -_velocity.x.sign) {
          _velocity = Vector(0, _velocity.y);
        }
        if (setback.y.sign == -_velocity.y.sign) {
          _velocity = Vector(_velocity.x, 0);
        }
      }
    }
  }
}

/*
This class is the main engine for the game mechanics.
It contains the information about the entire level setup and current state and
recalculates every frame as well as handling any events that may occur in the current
frame.

The update method for calculating the next frame is triggered by a frame timer
from the controller class VirusController.
 */
class VirusGame {
  bool loc;

  //saves at which level the player currently plays
  int _level;
  var _max_level = 1;

  /*
  saves the distance in the x-direction the player has to move until
  reaching the finish line for this level;
  victory is achieved, when the player crosses that line
   */
  int _finishLine;

  //saves if the game is running or paused
  bool _running;

  //list of every object in the level
  List<WorldObject> _objects;

  //int to save player movement direction
  double _playerMovement;

  VirusGame(bool local)
      : _running = false,
        _playerMovement = 0,
        _objects = [],
        loc = local {
    //load max level from local storage
    var localStorage = html.window.localStorage.entries.toList();
    for (var m in localStorage) {
      if (m.key == 'ktv') {
        _max_level = int.parse(m.value);
      }
    }
  }

  //has the player won the level?
  bool get won => _objects[0].pos.x >= _finishLine;

  bool get isRunning => _running;

  int get level => _level;

  int get max_level => _max_level;

  Vector get playerPos => _objects[0].pos;

  int get playerHealth => (_objects[0] as Player).health;

  List<WorldObject> get objects => _objects;

  set running(bool b) => _running = b;

  set level(int n) => _level = n;

  set max_level(int n) => _max_level = n;

  //reads the data for the level setup from a json file and sets up the level
  Future<bool> loadLevel() async {
    //clear the list of objects in case a previous level has been loaded
    _objects = [];
    //create / reinitialize player and put him in first position of _objects
    _objects.add(Player(Vector(0, 0), Vector(0, 0), Vector(0, GRAVITY)));

    //initialize training levels
    if (_level < 0) {
      var random = Random();

      _objects[0] = Player(Vector(0, 0), Vector(0, 0), Vector(0, 0));

      final xx = -1000 + random.nextInt(2000) as double;
      final yy = -1000 + random.nextInt(2000) as double;

      for (var i = 0; i < 20; ++i) {
        _objects.add(Enemy(Vector(xx, yy), Vector(0, 0), Vector(0, 0)));
      }
    }

    //open the json level file and read it
    final data = loc
        ? jsonDecode(await html.HttpRequest.getString(
            Uri.http('localhost:80', '/data/lvl/lvl$_level.json').toString()))
        : jsonDecode(await html.HttpRequest.getString(
            'https://webtech.mylab.th-luebeck.de/ss2020/team-04-d/data/lvl/lvl$_level.json'));
    //open the json file for the ai network and read it
    final brainData = loc
        ? jsonDecode(await html.HttpRequest.getString(
            Uri.http('localhost:80', '/data/network.json').toString()))
        : jsonDecode(await html.HttpRequest.getString(
            'https://webtech.mylab.th-luebeck.de/ss2020/team-04-d/data/network.json'));

    //create ai-brain

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

    //go through the data map and create objects / set values
    for (var obj in data) {
      switch (obj['type']) {
        //TODO: finish list
        case 'finish_line':
          _finishLine = int.parse(obj['length']);
          break;
        case 'StaticObject':
          //read position and dimension values
          final x = double.parse(obj['x']);
          final y = double.parse(obj['y']);
          final w = double.parse(obj['w']);
          final h = double.parse(obj['h']);
          _objects.add(StaticObject(Vector(x, y), Vector(w, h), obj['tex']));
          break;

        case 'WorldObject':
          //read position and dimension values
          final x = double.parse(obj['x']);
          final y = double.parse(obj['y']);
          final w = double.parse(obj['w']);
          final h = double.parse(obj['h']);
          //create object and add gravitational force
          _objects.add(WorldObject(Vector(x, y), Vector(w, h), obj['tex'],
              Vector(0, 0), Vector(0, GRAVITY)));
          break;

        case 'DoorSwitch':
          //read position and dimension values
          final x = double.parse(obj['x']);
          final y = double.parse(obj['y']);
          final x_sw = double.parse(obj['x_sw']);
          final y_sw = double.parse(obj['y_sw']);
          //create object and add gravitational force
          final door = Door(Vector(x, y));
          _objects.add(door);
          _objects.add(Switch(Vector(x_sw, y_sw), door));
          break;

        case 'Box':
          //read position and dimension values
          final x = double.parse(obj['x']);
          final y = double.parse(obj['y']);
          //create object and add gravitational force
          _objects.add(Box(Vector(x, y)));
          break;

        case 'Enemy':
          final x = double.parse(obj['x']);
          final y = double.parse(obj['y']);
          final enemy = Enemy(Vector(x, y), Vector(0, 0), Vector(0, GRAVITY));
          enemy.brain = brain.clone();
          _objects.add(enemy);
          break;

        default:
          break;
      }
    }

    return true;
  }

  //update the frame and handle any events that occur during that operation
  bool update() {
    //handle player movement by controls
    _objects[0].move(Vector(_playerMovement * PLAYER_VEL, 0));

    //handle each object
    for (var obj in _objects) {
      //first update the object according to its behaviour
      obj.update();

      //then calculate possible collisions
      _objects.forEach((o) => obj.collision(o, obj.collidesWith(o)));

      if (obj is Virus) {
        if (obj.hit) {
          if (obj.html_element != null) {
            obj.html_element.remove();
          }
          _objects.remove(obj);
        }
      }

      if (obj is Enemy) {
        obj.action(_objects);
      }
    }

    return (_objects[0] as Player).isDead;
  }

  void movePlayer(int dir) {
    _playerMovement += dir;
    //save looking direction in player
    (_objects[0] as Player).direction += dir;
  }

  void setPlayerMovement(double dir) {
    _playerMovement = dir;

    if (dir > 0) {
      (_objects[0] as Player).direction = 1;
    } else if (dir < 0) {
      (_objects[0] as Player).direction = -1;
    }
  }

  void playerJump() {
    (_objects[0] as Player).jump();
  }
}
