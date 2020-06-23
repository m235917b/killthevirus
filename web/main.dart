import 'package:virusgame/virusgame.dart';

//set this to true for starting the ai trainer
final bool train = false;
//set this to true for playing on local server
final bool local = false;

void main() {
  if (train) {
    var trainer = Trainer();
  } else {
    var ctlr = VirusController(local);
  }
}
