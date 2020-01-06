import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class Fleet {
  final _shipPower = Ship(0).getShipPowerList();
  final _ownerName = ["Start", "Sente", "Gote", "Onlooker"];

  int _owner;

  List<List<Ship>> _fleetShips = [[], [], [], [], []];

  Fleet([this._owner = 0]);

  List<int> howMuchShipFormed() =>
      List<int>.generate(5, (x) => _fleetShips[x].length);

  int howMuchAreaIsHeld() {
    var temp = 0;
    _fleetShips
        .asMap()
        .forEach((index, value) => temp += value.length * _shipPower[index]);
    return temp;
  }

  void addShip(Ship newShip) => _fleetShips[newShip.shipType].add(newShip);
  void popShip(int shipType) => _fleetShips[shipType].removeLast();

  void setOwner(int owner) => _owner = owner;

  List<int> getYetShips() {
    List<int> temp = [];
    for (var i in _fleetShips.asMap().values) {
      var tem = 0;
      for (var j in i.asMap().values) {
        tem += j.isYet() ? 1 : 0;
      }
      temp.add(tem);
    }

    return temp;
  }

  void setSpecificTypeShipWhichIsYet(Ship ship) {
    for (var index in _fleetShips[ship.shipType].asMap().keys) {
      print(_fleetShips[ship.shipType][index].getShipStateName() + "  old one");
      if (_fleetShips[ship.shipType][index].getShipStateName() == "yet") {
        _fleetShips[ship.shipType][index] = ship;

        print("copy " +
            _fleetShips[ship.shipType][index].getShipStateName() +
            "\n ori" +
            ship.getShipStateName());
        break;
      }
    }
  }

  bool isWholeFleetIntact() {
    var temp = 0;
    _fleetShips.forEach(
        (type) => type.forEach((ship) => temp += ship.isIntact() ? 0 : 1));
    return temp == 0 ? true : false;
  }

  String getOwnerName() => _ownerName[_owner];

  void resetPlace(){
    _fleetShips.forEach((x)=>x.forEach((s){
      s.setPosition(new TwoPosition());
      s.changeShipState(0);
    }));
  }

  void updateWholeFleetData() {
    Map<String, Map<String, Object>> temp = {};
    _fleetShips.asMap().forEach((index, singleTypeShips) {
      temp[Ship(index).getShipTypeName()] = {
        "num": singleTypeShips.length.toString()
      };
      singleTypeShips.asMap().forEach((shipOrdinal, singleShip) {
        print(singleShip.getShipStateName());
        temp[Ship(index).getShipTypeName()][shipOrdinal.toString()] = {
          "State": singleShip.getShipStateName(),
          "Pos1": {
            "X": singleShip.getPosition().position1.x.toString(),
            "Y": singleShip.getPosition().position1.y.toString()
          },
          "Pos2": {
            "X": singleShip.getPosition().position2.x.toString(),
            "Y": singleShip.getPosition().position2.y.toString()
          },
          "DamagedPart": singleShip.getDamagedPart2String()
        };
      });
    });

    fireBaseDB.child("State/${_ownerName[_owner]}").set(temp).whenComplete(() {
      print("finish set");
    }).catchError((error) {
      print(error);
    });
  }
}
