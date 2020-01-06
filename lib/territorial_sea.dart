import 'package:sea_battle_nutn/fleet_state.dart';
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

  Ship _buildingShip;
  bool _notHaveBuildingShip = true;

  List<SinglePosition> _greenPath = [];

  List<List<BoardCell>> _terSeaMap;

  int getCellState(int x, int y) => _terSeaMap[x][y]._whatOnThis;

  List<int> getYetShipNumberinFleet() => _fleet.getYetShips();

  void updateFleet() => _fleet.updateWholeFleetData();

  void resetPlaceTer(){
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
  }
}

class BoardCell {
  final SinglePosition _position;
  int _whatOnThis;

  BoardCell(this._position, [this._whatOnThis = 0]);
  void changeState(int s) => _whatOnThis = s;
  bool isDefault() => _whatOnThis == 0 ? true : false;
  bool isGreen() => _whatOnThis == 2 ? true : false;
}
