import 'package:firebase_database/firebase_database.dart';
import 'package:sea_battle_nutn/fleet_state.dart';
import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class TerritorialSea {
  Fleet _fleet;
  final Map<String, int> _shipType7IconOd = {
    "default": 0,
    "stop": 1,
    "can": 2,
    "CV": 3,
    "BB": 4,
    "CA": 5,
    "CL": 6,
    "DD": 7
  };
  final _ownerName = ["Start", "Sente", "Gote", "Onlooker"];

  Ship _buildingShip;
  bool _notHaveBuildingShip = true;

  List<SinglePosition> _greenPath = [];

  List<List<BoardCell>> _terSeaMap;

  int getCellState(int x, int y) => _terSeaMap[x][y]._whatOnThis;

  List<int> getYetShipNumberinFleet() => _fleet.getYetShips();

  String getOwner() => _fleet.getOwner();

  void updateFleet() {
    _fleet.updateWholeFleetData();
    updateTeb();
  }

  void importTebData(String str,String ta) {
    print("start $ta Teb import");
    List tebData = str.split('');
    print(tebData);
    _terSeaMap = List<List<BoardCell>>.generate(8, (posX) {
      return List<BoardCell>.generate(16, (posY) {
        //print("$posX $posY : ${ tebData[posX * 16 + posY]}");
        return BoardCell(SinglePosition(posX, posY), int.parse(tebData[posX * 16 + posY]));
      });
    });
    print("Teb Safe");
    _fleet = new Fleet();
    _fleet.setOwner(_ownerName.indexOf(ta));
    fireBaseDB
        .child("State")
        .once()
        .then((DataSnapshot snapshot) {
          Map fleetData = snapshot.value;
          _fleet.importFleetData(fleetData[ta]);
        })
        .whenComplete(()=>print("Teb Fleet Imported"))
        .catchError((e) => print(e));    
  }

  List<Ship> shipCanTorpedo()=>_fleet.torpedoShip();

  List<Ship> getAllShipInFleet(){
    List<Ship> ships = [];
    for(var x in [0,1,2,3,4])
      ships.addAll(_fleet.getSigleTypeShips(x));
    return ships;
  }

  void updateTeb() {
    String str = "";
    for (var i in _terSeaMap) for (var j in i) str += (j._whatOnThis).toString();
    fireBaseDB.child("Teb").update({_fleet.getOwner(): str}).whenComplete(() {
      print("finish Teb set");
    }).catchError((error) {
      print(error);
    });
  }

  void resetPlaceTer() {
    _fleet.resetPlace();
    _terSeaMap = List<List<BoardCell>>.generate(8, (posX) {
      return List<BoardCell>.generate(16, (posY) {
        return BoardCell(SinglePosition(posX, posY));
      });
    });
    _notHaveBuildingShip = true;
  }

  void buildTerritorialSeaMap(Fleet fl) {
    _fleet = fl;
    _terSeaMap = List<List<BoardCell>>.generate(8, (posX) {
      return List<BoardCell>.generate(16, (posY) {
        return BoardCell(SinglePosition(posX, posY));
      });
    });
    _notHaveBuildingShip = true;
  }

  bool isFleetOkey() => _fleet.isWholeFleetIntact() ? true : false;

  void _markAroundEmptyRed(int x, int y) {
    for (final p in [
      [1, 0],
      [0, 1],
      [-1, 0],
      [0, -1]
    ]) {
      var xx = (x + p[0]) < 0 ? 0 : ((x + p[0]) > 7 ? 7 : (x + p[0]));
      var yy = (y + p[1]) < 0 ? 0 : ((y + p[1]) > 15 ? 15 : (y + p[1]));
      //print("$xx $yy ${_terSeaMap[xx][yy]._whatOnThis}");
      if (_terSeaMap[xx][yy].isDefault() || _terSeaMap[xx][yy].isGreen())
        _terSeaMap[xx][yy].changeState(_shipType7IconOd["stop"]);
    }
  }

  bool _findPossiblePath(int x, int y, Ship ship) {
    List<SinglePosition> possiblePath =
        Ship(ship.shipType, TwoPosition(SinglePosition(x, y)))
            .getPossibleTail();
    possiblePath.forEach((element) {
      var isAPath = true,
          possibleBody =
              Ship(ship.shipType, TwoPosition(SinglePosition(x, y), element))
                  .getBody();
      possibleBody.forEach((bodyElement) => isAPath =
          _terSeaMap[bodyElement.x][bodyElement.y].isDefault()
              ? isAPath
              : false);
      if (isAPath) {
        _greenPath.add(element);
        _terSeaMap[element.x][element.y].changeState(_shipType7IconOd["can"]);
      }
    });
    print("path : ${_greenPath.length}");
    return _greenPath.length == 0 ? false : true;
  }

  int positioningShip(int x, int y, Ship ship) {
    print("to _ter");
    if (_notHaveBuildingShip) {
      if (ship.isDD() && _terSeaMap[x][y].isDefault()) {
        _terSeaMap[x][y].changeState(_shipType7IconOd[ship.getShipTypeName()]);
        ship.setPosition(TwoPosition(SinglePosition(x, y)));
        ship.changeShipState(1);
        _fleet.setSpecificTypeShipWhichIsYet(ship);
        _markAroundEmptyRed(x, y);
        return 0;
      } else if (ship.shipType < 5 &&
          ship.shipType >= 0 &&
          _terSeaMap[x][y].isDefault()) {
        if (_findPossiblePath(x, y, ship)) {
          print("found path");
          _terSeaMap[x][y]
              .changeState(_shipType7IconOd[ship.getShipTypeName()]);
          ship.setPosition(TwoPosition(SinglePosition(x, y)));
          _buildingShip = ship;
          _notHaveBuildingShip = false;
          return 1;
        } else
          return 0;
      } else
        return 0;
    } else {
      if (_terSeaMap[x][y].isGreen()) {
        print("start fill up");
        ship.setPosition(TwoPosition(
            _buildingShip.getPosition().position1, SinglePosition(x, y)));
        ship.getBody().forEach((element) {
          _terSeaMap[element.x][element.y]
              .changeState(_shipType7IconOd[ship.getShipTypeName()]);
          _markAroundEmptyRed(element.x, element.y);
        });
        while (_greenPath.length != 0) {
          var pos = _greenPath.removeLast();
          if (_terSeaMap[pos.x][pos.y].isGreen())
            _terSeaMap[pos.x][pos.y].changeState(0);
        }
        ship.changeShipState(1);
        print(ship.getShipStateName());
        _fleet.setSpecificTypeShipWhichIsYet(ship);
        _notHaveBuildingShip = true;
        return 0;
      }
    }
    print("error");
    return -2;
  }
}

class BoardCell {
  final SinglePosition _position;
  int _whatOnThis;
  SinglePosition getPos ()=> _position;
  BoardCell(this._position, [this._whatOnThis = 0]);
  void changeState(int s) => _whatOnThis = s;
  bool isDefault() => _whatOnThis == 0 ? true : false;
  bool isGreen() => _whatOnThis == 2 ? true : false;
}
