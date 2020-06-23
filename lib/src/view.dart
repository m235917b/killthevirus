part of virusgame;

const ZOOM_X = 0.05;

class VirusView {
  var _zoom_y;

  VirusView();

  bool get format => ZOOM_X > _zoom_y;

  //Animation method
  void animate(html.HtmlElement e, String name, int duration, Function f) {
    e.style.animation = name;
    e.style.animationDuration = '${duration}ms';
    Timer(Duration(milliseconds: duration), f);
  }

  void updateLvlButtons(VirusGame game) {
    for (var i = 10; i > 0; --i) {
      if (i > game.max_level) {
        html.querySelector('.level[lvl = "$i"]').style.opacity = '20%';
      } else {
        html.querySelector('.level[lvl = "$i"]').style.opacity = '100%';
      }
    }
  }

  /*
  Creates an html element for every object in the game and sets a reference for each object
  so the game knows which html element corresponds to which object
   */
  void initialize(VirusGame game) {
    _zoom_y = ZOOM_X * html.window.innerWidth / html.window.innerHeight;

    for (var o in game.objects) {
      //create an image element

      final e = html.ImageElement();
      /*
      set coordinates and transform them by the negative of the players position and
      half the screen, so the player is always in the center
       */
      if (o is Player) {
        e.srcset = './data/img/${o.texture}_r.png';
        e.style.left = '50%';
        e.style.top = '50%';
        e.style.width = '${ZOOM_X * o.dim.x}%';
        e.style.height = '${_zoom_y * o.dim.y}%';
      } else if (o is Enemy) {
        e.srcset = './data/img/${o.texture}_r.png';
        e.style.left = '${50 + ZOOM_X * o.pos.x - ZOOM_X * game.playerPos.x}%';
        e.style.top = '${50 + _zoom_y * o.pos.y - _zoom_y * game.playerPos.y}%';
        e.style.width = '${ZOOM_X * o.dim.x}%';
        e.style.height = '${_zoom_y * o.dim.y}%';
      } else {
        //set image source
        e.srcset = './data/img/${o.texture}.png';
        e.style.left = '${50 + ZOOM_X * o.pos.x - ZOOM_X * game.playerPos.x}%';
        e.style.top = '${50 + _zoom_y * o.pos.y - _zoom_y * game.playerPos.y}%';
        e.style.width = '${ZOOM_X * o.dim.x}%';
        e.style.height = '${_zoom_y * o.dim.y}%';
      }
      //add element to DOM-Tree
      html.querySelector('#game-view').children.add(e);
      //set reference to html element
      o.html_element = e;
    }

    html.querySelector('#sun').style.width = '${ZOOM_X * 1500}%';
    html.querySelector('#sun').style.height = '${_zoom_y * 420}%';

    html.querySelector('#danger').style.left = '${50 - ZOOM_X * 220}%';
    html.querySelector('#danger').style.top = '${50 - _zoom_y * 220}%';
    html.querySelector('#danger').style.width = '${ZOOM_X * 440}%';
    html.querySelector('#danger').style.height = '${_zoom_y * 440}%';

    html.querySelector('#help-screen').style.left = '${50 - ZOOM_X * 345}%';
    html.querySelector('#help-screen').style.top = '${50 - _zoom_y * 256}%';
    html.querySelector('#help-screen').style.width = '${ZOOM_X * 690}%';
    html.querySelector('#help-screen').style.height = '${_zoom_y * 512}%';

    html.querySelector('#lvlselect').style.left = '${50 - ZOOM_X * 275}%';
    html.querySelector('#lvlselect').style.top = '0%';
    html.querySelector('#lvlselect').style.width = '${ZOOM_X * 550}%';
    html.querySelector('#lvlselect').style.height = '${_zoom_y * 100}%';

    //initialize player health images
    html.querySelector('#h1').style.left = '${95 - ZOOM_X * 32}%';
    html.querySelector('#h1').style.width = '${ZOOM_X * 32}%';
    html.querySelector('#h1').style.height = '${_zoom_y * 32}%';
    html.querySelector('#h2').style.left = '${95 - ZOOM_X * 64}%';
    html.querySelector('#h2').style.width = '${ZOOM_X * 32}%';
    html.querySelector('#h2').style.height = '${_zoom_y * 32}%';
    html.querySelector('#h3').style.left = '${95 - ZOOM_X * 96}%';
    html.querySelector('#h3').style.width = '${ZOOM_X * 32}%';
    html.querySelector('#h3').style.height = '${_zoom_y * 32}%';

    //initialize buttons
    html.querySelectorAll('.level').style.width = '${ZOOM_X * 64}%';
    html.querySelectorAll('.level').style.height = '${_zoom_y * 64}%';
    html.querySelector('#menu-button').style.width = '${ZOOM_X * 32}%';
    html.querySelector('#menu-button').style.height = '${_zoom_y * 32}%';
    html.querySelector('#resume').style.width = '${ZOOM_X * 200}%';
    html.querySelector('#resume').style.height = '${_zoom_y * 64}%';
    html.querySelector('#help').style.width = '${ZOOM_X * 200}%';
    html.querySelector('#help').style.height = '${_zoom_y * 64}%';
    html.querySelector('#qr').style.width = '${ZOOM_X * 400}%';
    html.querySelector('#qr').style.height = '${_zoom_y * 400}%';
  }

  void clear(VirusGame game) {
    for (var o in game.objects) {
      if (o.html_element != null) {
        o.html_element.remove();
      }
    }
  }

  void update(VirusGame game) {
    //update the positions inside the viewport for every element

    for (var o in game.objects) {
      if (o is Virus) {
        if (o.html_element == null) {
          var e = html.ImageElement();
          e.srcset = './data/img/${o.texture}.png';
          e.style.left =
              '${50 + ZOOM_X * o.pos.x - ZOOM_X * game.playerPos.x}%';
          e.style.top =
              '${50 + _zoom_y * o.pos.y - _zoom_y * game.playerPos.y}%';
          e.style.width = '${ZOOM_X * o.dim.x}%';
          e.style.height = '${_zoom_y * o.dim.y}%';
          html.querySelector('#game-view').children.add(e);
          o.html_element = e;
        }
      }

      //update coordinates for each html element and textures for blobs
      if (o is Player) {
        o.direction == -1
            ? o.html_element.srcset = './data/img/${o.texture}_l.png'
            : null;
        o.direction == 1
            ? o.html_element.srcset = './data/img/${o.texture}_r.png'
            : null;

        o.html_element.style.width = '${ZOOM_X * o.dim.x}%';
        o.html_element.style.height = '${_zoom_y * o.dim.y}%';
      } else {
        if (o is Enemy) {
          o.direction == -1
              ? o.html_element.srcset = './data/img/${o.texture}_l.png'
              : null;
          o.direction == 1
              ? o.html_element.srcset = './data/img/${o.texture}_r.png'
              : null;
        }

        o.html_element.style.left =
            '${50 + ZOOM_X * o.pos.x - ZOOM_X * game.playerPos.x}%';
        o.html_element.style.top =
            '${50 + _zoom_y * o.pos.y - _zoom_y * game.playerPos.y}%';
        o.html_element.style.width = '${ZOOM_X * o.dim.x}%';
        o.html_element.style.height = '${_zoom_y * o.dim.y}%';
      }
    }

    //update corona masks (player health)
    switch (game.playerHealth) {
      case 0:
        html.querySelector('#h1').hidden = true;
        html.querySelector('#h2').hidden = true;
        html.querySelector('#h3').hidden = true;
        break;

      case 1:
        if (!html.querySelector('#h2').hidden) {
          animate(game.objects[0].html_element, 'shot', 500, () {});
          html.querySelector('#h1').hidden = false;
          html.querySelector('#h2').hidden = true;
          html.querySelector('#h3').hidden = true;
        }
        break;

      case 2:
        if (!html.querySelector('#h3').hidden) {
          animate(game.objects[0].html_element, 'shot', 500, () {});
          html.querySelector('#h1').hidden = false;
          html.querySelector('#h2').hidden = false;
          html.querySelector('#h3').hidden = true;
        }
        break;

      case 3:
        html.querySelector('#h1').hidden = false;
        html.querySelector('#h2').hidden = false;
        html.querySelector('#h3').hidden = false;
        break;

      default:
        break;
    }

    //bring menu button and corona masks always to front
    html.querySelectorAll('.health').style.zIndex = '${game.objects.length}';
    html.querySelector('#menu-button').style.zIndex = '${game.objects.length}';
  }
}
