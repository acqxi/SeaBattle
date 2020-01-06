import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class Fleet {
  final _shipPower = Ship(0).getShipPowerList();
  final _ownerName = ["Start", "Sente", "Gote", "Onlooker"];

  int _owner;

  List<List<Ship>> _fleet = [[], [], [], [], []];

  Fleet([this._owner=0]);

  List<int> howMuchShipFormed() =>
      List<int>.generate(5, (x) => _fleet[x].length);

  int howMuchAreaIsHeld() {
    var temp = 0;
    _fleet
        .asMap()
        .forEach((index, value) => temp += value.length * _shipPower[index]);
    return temp;
  }

  void addShip(Ship newShip) => _fleet[newShip.shipType].add(newShip);
  void popShip(int shipType) => _fleet[shipType].removeLast();

  void setOwner(int owner) => _owner = owner;

  String getOwnerName()=>_ownerName[_owner];

  void updateWholeFleetData() {
    Map<String, Map<String, Object>> temp = {};
    _fleet.asMap().forEach((index, singleTypeShips) {
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
