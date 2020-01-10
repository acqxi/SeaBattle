import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class Fleet {
  final _shipPower = Ship(0).getShipPowerList();
  final _ownerName = ["Start", "Sente", "Gote", "Onlooker"];
  final _shipstateNameList = ["yet", "intact", "deform", "wrecked"];
  final _shipTypeNameList = ["CV", "BB", "CA", "CL", "DD"];

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

  void importFleetData(Map data) {
    data.forEach((indexString, typeShipsString) {
      Map typeShipMap = typeShipsString;
      //print(typeShipMap["num"].toString() + "typeShipMap[num]");
      for (int i = 0; i < int.parse(typeShipMap["num"]); i++) {
        //print(typeShipMap[i.toString()]);
        //print(typeShipMap[i.toString()]["DamagedPart"].toString().split(''));
        List<int> ktemp = [];
        for (var k in typeShipMap[i.toString()]["DamagedPart"]
            .toString()
            .split('')) ktemp.add(int.parse(k));

        //print(_shipTypeNameList.indexOf(indexString));
        //print(ktemp);
        _fleetShips[_shipTypeNameList.indexOf(indexString)].add(Ship(
            _shipTypeNameList.indexOf(indexString),
            TwoPosition(
                SinglePosition(
                    int.parse(typeShipMap[i.toString()]["Pos1"]["X"]),
                    int.parse(typeShipMap[i.toString()]["Pos1"]["Y"])),
                SinglePosition(
                    int.parse(typeShipMap[i.toString()]["Pos2"]["X"]),
                    int.parse(typeShipMap[i.toString()]["Pos2"]["Y"]))),
            _shipstateNameList.indexOf(typeShipMap[i.toString()]["State"]),
            ktemp,
            i));
        print("Fleet Import perfectly Okey");
      }
    });
  }

  List<Ship> torpedoShip() {
    List<Ship> _torpedoShip = [];
    for (var x in [2, 3, 4])
      _fleetShips[x].forEach((ship) {
        if (!ship.isWrecked()) _torpedoShip.add(ship);
      });
    return _torpedoShip;
  }

  void addShip(Ship newShip) {
    newShip.setName(_fleetShips[newShip.shipType].length);
    _fleetShips[newShip.shipType].add(newShip);
  }

  void popShip(int shipType) => _fleetShips[shipType].removeLast();

  void setOwner(int owner) => _owner = owner;
  String getOwner() => _ownerName[_owner];

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

  List<Ship> getSigleTypeShips(int shipType) => _fleetShips[shipType];

  void setSpecificTypeShipWhichIsYet(Ship ship) {
    for (var index in _fleetShips[ship.shipType].asMap().keys) {
      print(_fleetShips[ship.shipType][index].getShipStateName() + "  old one");
      if (_fleetShips[ship.shipType][index].getShipStateName() == "yet") {
        ship.setName(index);
        _fleetShips[ship.shipType][index] = ship;

        /*print("copy " +
            _fleetShips[ship.shipType][index].getShipStateName() +
            "\n ori" +
            ship.getShipStateName());*/
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

  void resetPlace() {
    _fleetShips.forEach((x) => x.forEach((s) {
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

    fireBaseDB.child("State/${this.getOwner()}").set(temp).whenComplete(() {
      print("finish set");
    }).catchError((error) {
      print(error);
    });
  }
}
