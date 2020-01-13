import 'package:firebase_database/firebase_database.dart';
import 'package:sea_battle_nutn/basic_class.dart';
import 'package:sea_battle_nutn/battle_event.dart';
import 'package:sea_battle_nutn/fleet_state.dart';
import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class BattleField {
  final Fleet fleet;
  final int row;
  final int col;

  Ship _placingShip;

  bool _isTapping = false;
  bool _placing = false;
  //bool _isLongPress = false;

  List<SinglePosition> _greenList = [];

  List<List<BoardCell>> cellPad;
  BattleField({this.col = 0, this.row = 0, this.fleet});

  void initial() => cellPad = List<List<BoardCell>>.generate(
      col,
      (x) => List<BoardCell>.generate(
          row, (y) => BoardCell(SinglePosition(x, y))));

  void download() {
    //var dataStr = "";
    initial();
    /*fireBaseDB.child("Teb").once().then((DataSnapshot snapshot) {
      Map data = snapshot.value;
      print(data[fleet.getOwnerName()].length);
      dataStr = data[fleet.getOwnerName()];

      print(dataStr);
    }).whenComplete(() {
      print("Got");
      cellPad = List<List<BoardCell>>.generate(
          col,
          (x) => List<BoardCell>.generate(
              row,
              (y) => BoardCell(SinglePosition(x, y),
                  onThisBoardCellItem: ToolRefer.boardCellTypeListI2S[
                      int.parse(dataStr.split('')[x * 8 + y])])));
      print("downloaded Teb");
      eventBus.fire(LoadFinishEvent(true));
    }).catchError((e) => print(e));*/
    fireBaseDB
        .child("State/${fleet.getOwnerName()}")
        .once()
        .then((DataSnapshot snapshot) {
          print("start aysis ${fleet.getOwnerName()}");
          Map data = snapshot.value;
          data.forEach((indexString, typeShipsString) {
            Map typeShipMap = typeShipsString;
            //print(typeShipMap["num"].toString() + "typeShipMap[num]");
            for (int i = 0; i < int.parse(typeShipMap["num"]); i++) {
              Ship newShip = Ship(
                  fleet.getOwner(),
                  ToolRefer.shipTypeNameList.indexOf(indexString),
                  i,
                  TwoPosition(
                      SinglePosition(
                          7 - int.parse(typeShipMap[i.toString()]["Pos1"]["X"]),
                          7 -
                              int.parse(
                                  typeShipMap[i.toString()]["Pos1"]["Y"])),
                      SinglePosition(
                          7 - int.parse(typeShipMap[i.toString()]["Pos2"]["X"]),
                          7 -
                              int.parse(
                                  typeShipMap[i.toString()]["Pos2"]["Y"]))),
                  1);
              var newShipBodys = newShip.getBodys();
              for (var u in newShipBodys) {
                cellPad[u.shipBodPosition.x][u.shipBodPosition.y]
                    .onThisBoardCellShipBody = u;
                cellPad[u.shipBodPosition.x][u.shipBodPosition.y]
                    .onThisBoardCellItem = newShip.getShipTypeName();
              }
              fleet.addShip(newShip);
              print(newShip.getBody());
            }

            print("Fleet Import perfectly Okey");
          });
        })
        .whenComplete(() => eventBus.fire(LoadFinishEvent(true)))
        .catchError((e) => print(e));
  }

  void reloadCP() {
    for (int x = 0; x < col; x++)
      for (int y = 0; y < row; y++)
        if (cellPad[x][y].onThisBoardCellShipBody !=
            null) if (cellPad[x][y].onThisBoardCellShipBody.shipBodyState != 0)
          cellPad[x][y].onThisBoardCellItem = [
            "deform",
            "wreck"
          ][cellPad[x][y].onThisBoardCellShipBody.shipBodyState - 1];
  }

  bool tap(int x, int y, int shipType) {
    // Lock?
    if (_isTapping) return true;
    if (!(cellPad[x][y].isDefault() || cellPad[x][y].isGreen())) return false;
    _isTapping = true;
    if (_placing) {
      print("step2");
      if (!cellPad[x][y].isGreen()) {
        _isTapping = false;
        return true;
      }
      List<SinglePosition> shipOcu = [];
      _placingShip.setPosition(TwoPosition(
          _placingShip.getShipPosition().pos1, SinglePosition(x, y)));
      fleet.setSpecificTypeShipWhichIsYet(_placingShip);
      _placingShip.getBodys().forEach((sBody) {
        cellPad[sBody.shipBodPosition.x][sBody.shipBodPosition.y]
            .onThisBoardCellItem = ToolRefer.shipTypeNameList[shipType];
        cellPad[sBody.shipBodPosition.x][sBody.shipBodPosition.y]
            .onThisBoardCellShipBody = sBody;
        shipOcu.add(sBody.shipBodPosition);
      });
      while (_greenList.length != 0) {
        var dPos = _greenList.removeLast();
        if (cellPad[dPos.x][dPos.y].isGreen())
          cellPad[dPos.x][dPos.y].onThisBoardCellItem = "default";
      }
      while (shipOcu.length != 0) {
        var dPos = shipOcu.removeLast();
        _markAroundEmptyRed(dPos.x, dPos.y);
      }
      print("placed");
      _placing = false;
    } else if (shipType == 4) {
      cellPad[x][y].onThisBoardCellItem = "DD";
      Ship dd = Ship(
          fleet.getOwner(), shipType, 0, TwoPosition(SinglePosition(x, y)), 1);
      fleet.setSpecificTypeShipWhichIsYet(dd);
      cellPad[x][y].onThisBoardCellShipBody = dd.getBody(part: 0);
      _markAroundEmptyRed(x, y);
      print("placed DD");
    } else {
      bool canPlace = false;
      _placingShip = Ship(
          fleet.getOwner(), shipType, 0, TwoPosition(SinglePosition(x, y)), 1);
      _placingShip.getPossibleTail().forEach((data) {
        bool isPath = true;
        _placingShip.getPossibleBodysPos(data.x, data.y).forEach((pos) {
          if (!cellPad[pos.x][pos.y].isDefault()) isPath = false;
        });
        if (isPath) {
          canPlace = true;
          _greenList.add(data);
          cellPad[data.x][data.y].onThisBoardCellItem = "can";
        }
      });
      _isTapping = false;
      print("placed $canPlace");
      _placing = canPlace;
      return canPlace;
    }

    _isTapping = false;
    return false;
  }

  void _markAroundEmptyRed(int x, int y) {
    for (final p in ToolRefer.directionInt.sublist(0, 4)) {
      var xx = (x + p[0]) < 0 ? 0 : ((x + p[0]) > 7 ? 7 : (x + p[0]));
      var yy = (y + p[1]) < 0 ? 0 : ((y + p[1]) > 7 ? 7 : (y + p[1]));
      //print("$xx $yy ${_terSeaMap[xx][yy]._whatOnThis}");
      if (cellPad[xx][yy].isDefault() || cellPad[xx][yy].isGreen())
        cellPad[xx][yy].onThisBoardCellItem = "stop";
    }
  }

  void update() {
    fleet.updateWholeFleetData();
    fireBaseDB
        .child("Teb")
        .update({fleet.getOwnerName(): this.toString()})
        .whenComplete(() => print("Teb On"))
        .catchError((e) => print(e));
  }

  BoardCell getCell(x, y) => cellPad[x][y];

  @override
  String toString() {
    String str = "";
    for (var x in cellPad)
      for (var y in x)
        str += ToolRefer.boardCellTypeMapS2I[y.onThisBoardCellItem].toString();

    return str;
  }
}
