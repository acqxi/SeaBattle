//import 'package:firebase_database/firebase_database.dart';
import 'package:sea_battle_nutn/basic_class.dart';
import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class Fleet {
  final int _owner;

  List<List<Ship>> _fleetShips = [[], [], [], [], []];

  Fleet([this._owner = 0]);

  List<int> howMuchShipFormed() =>
      List<int>.generate(5, (x) => _fleetShips[x].length);

  int howMuchAreaIsHeld() {
    var temp = 0;
    _fleetShips.asMap().forEach(
        (index, value) => temp += value.length * ToolRefer.shipPower[index]);
    return temp;
  }

  /*void importFleetData() {
    fireBaseDB
        .child("State")
        .once()
        .then((DataSnapshot snapshot) {
          Map data = snapshot.value;
          data.forEach((indexString, typeShipsString) {
            Map typeShipMap = typeShipsString;
            //print(typeShipMap["num"].toString() + "typeShipMap[num]");
            for (int i = 0; i < int.parse(typeShipMap["num"]); i++) {
              //print(typeShipMap[i.toString()]);
              //print(typeShipMap[i.toString()]["DamagedPart"].toString().split(''));

              //print(_shipTypeNameList.indexOf(indexString));
              //print(ktemp);
              _fleetShips[ToolRefer.shipTypeNameList.indexOf(indexString)].add(
                  Ship(
                      _owner,
                      ToolRefer.shipTypeNameList.indexOf(indexString),
                      i,
                      TwoPosition(
                          SinglePosition(
                              int.parse(typeShipMap[i.toString()]["Pos1"]["X"]),
                              int.parse(
                                  typeShipMap[i.toString()]["Pos1"]["Y"])),
                          SinglePosition(
                              int.parse(typeShipMap[i.toString()]["Pos2"]["X"]),
                              int.parse(
                                  typeShipMap[i.toString()]["Pos2"]["Y"]))),
                      ToolRefer.shipStateNameList
                          .indexOf(typeShipMap[i.toString()]["State"])));
              
            }

            print("Fleet Import perfectly Okey");
          });
        })
        .whenComplete(() => print("Teb Fleet Imported"))
        .catchError((e) => print(e));
  }*/

  List<Ship> torpedoShip() {
    List<Ship> _torpedoShip = [];
    for (var x in [2, 3, 4])
      _fleetShips[x].forEach((ship) {
        if (!ship.isWrecked()) _torpedoShip.add(ship);
      });
    return _torpedoShip;
  }

  Ship getShip(int shiptype,int shipName) =>_fleetShips[shiptype][shipName];

  void addShip(Ship newShip) {
    newShip.setName(_fleetShips[newShip.shipType].length);
    _fleetShips[newShip.shipType].add(newShip);
  }

  void popShip(int shipType) => _fleetShips[shipType].removeLast();

  String getOwnerName() => ToolRefer.ownerNameList[_owner];
  int getOwner() => _owner;
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
        /*print("copy " +            _fleetShips[ship.shipType][index].getShipStateName() +            "\n ori" +            ship.getShipStateName());*/
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

  void resetPlace() {
    _fleetShips.forEach((x) => x.forEach((s) {
          s.setPosition(new TwoPosition());
          s.changeShipState(0);
        }));
  }

  List fleetToListMap(int shipType) {
    List temp = [];
    _fleetShips[shipType].forEach((ship) {
      temp.add({
        "State": ship.getShipStateName(),
        "Pos1": {
          "X": ship.getShipPosition().pos1.x.toString(),
          "Y": ship.getShipPosition().pos1.y.toString()
        },
        "Pos2": {
          "X": ship.getShipPosition().pos2.x.toString(),
          "Y": ship.getShipPosition().pos2.y.toString()
        },
        "DamagedPart": ship.getDamagedPartString()
      });
    });
    return temp;
  }

  void updateWholeFleetData() {
    Map<String, Map<String, Object>> temp = {};
    _fleetShips.asMap().forEach((index, singleTypeShips) {
      temp[singleTypeShips[0].getShipTypeName()] = {
        "num": singleTypeShips.length.toString()
      };
      fleetToListMap(singleTypeShips[0].shipType).asMap().forEach((index,
              value) =>
          temp[singleTypeShips[0].getShipTypeName()][index.toString()] = value);
    });

    fireBaseDB.child("State/${this.getOwnerName()}").set(temp).whenComplete(() {
      print("finish set ");
    }).catchError((error) {
      print(error);
    });
  }

  @override
  String toString() =>
      "{${ToolRefer.ownerNameList[_owner]}'s Fleet\n\tCV : total ${getSigleTypeShips(0).length}\n\tBB : total ${getSigleTypeShips(1).length}\n\tCA : total ${getSigleTypeShips(2).length}\n\tCL : total ${getSigleTypeShips(3).length}\n\tDD : total ${getSigleTypeShips(4).length}}";
}
