import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/battle_event.dart';
import 'package:sea_battle_nutn/basic_class.dart';
import 'package:sea_battle_nutn/fleet_state.dart';
import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';
import 'package:sea_battle_nutn/territorial_sea.dart';

class SeaWarfare extends StatefulWidget {
  final BattleField _battleField;

  SeaWarfare(this._battleField);

  @override
  _SeaWarfareState createState() => _SeaWarfareState();
}

class _SeaWarfareState extends State<SeaWarfare> {
  int _globalAdjustmentCoefficient;
  int _row;
  int _col;
  String _turn;

  int _turns;

  bool _loaded;
  bool _myTurn = false;
  bool began;

  bool _shouldReloaded;

  int weaponButtonState;

  BattleField _battleFieldState;
  BattleField _battleFieldStateTa;

  List<List<BoardCell>> field;

  Map<String, int> markAttack = {};

  int lastSTa = 0;
  int lastSMe = 0;

  int thisTurnAttck = 0;

  @override
  void initState() {
    _shouldReloaded = true;
    began = true;
    _turns = 0;
    _loaded = false;
    _row = 8;
    _col = 8;
    _globalAdjustmentCoefficient = 30;
    weaponButtonState = 0;
    _myTurn = false;

    _battleFieldState = widget._battleField;
    _battleFieldStateTa = new BattleField(
        col: 8,
        row: 8,
        fleet: new Fleet(_battleFieldState.fleet.getOwner() == 1 ? 2 : 1));

    eventBus.on<LoadFinishEvent>().listen((LoadFinishEvent data) =>
        this.setState(() => _loaded = data.loadFinish));

    fireBaseDB.child("LastShipNumber").onValue.listen((Event event) {
      lastSMe = event.snapshot.value[_battleFieldState.fleet.getOwnerName()];
      lastSTa = event.snapshot.value[_battleFieldStateTa.fleet.getOwnerName()];
    });

    fireBaseDB
        .child("LastShipNumber")
        .set({
          "${_battleFieldState.fleet.getOwnerName()}":
              _battleFieldState.fleet.howMuchAreaIsHeld()
        })
        .whenComplete(() => print("set shipnumber"))
        .catchError((e) => print(e));

    fireBaseDB.child("PlayerState").onValue.listen((Event event) {
      if (event.snapshot.value != null) {
        Map map = event.snapshot.value;
        this.setState(() {
          _turn = map["Turn"];
          if (_turn == "notStart" || _turn == null || _turn == "wait")
            _myTurn = false;
          else {
            _turns = int.parse(_turn);
            _myTurn = _battleFieldState.fleet.getOwner() == (2 - _turns % 2);
          }
          if (_battleFieldState.fleet.getOwner() == 3) _myTurn = true;
          print("turn => $_turn,turns =>$_turns");
          _shouldReloaded = true;
          markAttack = {};
          weaponButtonState = 0;
          if (_myTurn) {
            shipCode = 0;
            dataX1 = 0;
            dataX2 = 0;
            dataY1 = 0;
            dataY2 = 0;
            canLaunch = true;
            thisTurnAttck = 0;
          }
        });
      }
    });

    fireBaseDB.child("PlayerState").once().then((DataSnapshot snapShot) {
      Map data = snapShot.value;
      _turn = data["Turn"];
      print("init : turn => $_turn");
    }).whenComplete(() {
      _turn = (_turn == "notStart" || _turn == null) ? "wait" : "1";
      fireBaseDB
          .child("PlayerState")
          .update({"Turn": _turn})
          .whenComplete(() => print("send $_turn"))
          .catchError((e) => print(e));
    }).catchError((e) => print(e));

    super.initState();
  }

  void reloadMap() {
    _battleFieldState.reloadCP();
    _battleFieldStateTa.reloadCP();
  }

  var iconColorList = [
    Colors.white,
    Colors.redAccent[100],
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.blueGrey,
    Colors.indigoAccent,
    Colors.tealAccent,
    Colors.blueAccent
  ]; //default stop ca

  int lastShipNumber = 0;

  String whatTurnItIs() {
    //markAttack[SinglePosition(15, 0).toString()] = 1;
    print("check local turn");
    if(_turn == "20"){
      eventBus.fire(StepChangerEvent(6));
    }
    if (_turn == "1" && began) {
      _battleFieldStateTa.download();
      began = false;
    } else if (_myTurn &&
        _battleFieldState.fleet.getOwner() != 3 &&
        _shouldReloaded) {
      fireBaseDB
          .child("Battle")
          .child("${_turns - 1}")
          .once()
          .then((DataSnapshot snapShot) {
        Map data = snapShot.value;
        print("last turn happened : $data");
        for (int i = 6; i < 14; i++) {
          var char = ToolRefer.ascii[i];
          List<String> wrecked = data[char].toString().split('');
          if (i < 10) {
            _battleFieldState
                .cellPad[15 - ToolRefer.asciiConvert[wrecked[0]]]
                    [7 - ToolRefer.asciiConvert[wrecked[1]]]
                .onThisBoardCellShipBody
                .shipBodyState++;
            _battleFieldState.fleet
                .getShip(
                    _battleFieldState
                        .cellPad[15 - ToolRefer.asciiConvert[wrecked[0]]]
                            [7 - ToolRefer.asciiConvert[wrecked[1]]]
                        .onThisBoardCellShipBody
                        .shipType,
                    _battleFieldState
                        .cellPad[15 - ToolRefer.asciiConvert[wrecked[0]]]
                            [7 - ToolRefer.asciiConvert[wrecked[1]]]
                        .onThisBoardCellShipBody
                        .shipName)
                .checkDamage();
          } else
            _battleFieldState.fleet
                .getShip(
                    _battleFieldState
                        .cellPad[15 - ToolRefer.asciiConvert[wrecked[1]]]
                            [7 - ToolRefer.asciiConvert[wrecked[2]]]
                        .onThisBoardCellShipBody
                        .shipType,
                    _battleFieldState
                        .cellPad[15 - ToolRefer.asciiConvert[wrecked[1]]]
                            [7 - ToolRefer.asciiConvert[wrecked[2]]]
                        .onThisBoardCellShipBody
                        .shipName)
                .changeShipState(3);
        }
        print("deform imported");
      }).whenComplete(() {
        print("reLoad");
        reloadMap();
      }).catchError((e) => print("error : $e"));
      _shouldReloaded = false;
    }
    shipsCanTorpedo = _battleFieldState.fleet.torpedoShip();
    return "this is" + (!_myTurn ? "n't" : "") + " yor turn";
  }

  int shipCode = 0;
  List<Ship> shipsCanTorpedo;
  int dataY1, dataY2, dataK, dataX1, dataX2;
  void torpedoPathUpdate() {
    markAttack = {};
    dataY1 = shipsCanTorpedo[shipCode].getShipPosition().pos1.y;
    dataY2 = shipsCanTorpedo[shipCode].getShipPosition().pos2.y;
    dataX1 = shipsCanTorpedo[shipCode].getShipPosition().pos1.x;
    dataX2 = shipsCanTorpedo[shipCode].getShipPosition().pos2.x;
    if (shipsCanTorpedo[shipCode].isDD())
      for (int i = 0; i < 16; i++)
        markAttack[SinglePosition(i, dataY1).toString()] = 1;
    else
      for (int i = 0; i < 16; i++) {
        markAttack[SinglePosition(i, dataY1).toString()] = 1;
        markAttack[SinglePosition(i, dataY2).toString()] = 1;
      }
    setState(() {});
  }

  void torpedoing() {
    int take1x, take2x;
    if (!shipsCanTorpedo[shipCode].isDD()) {
      for (int i = 0; i < 8; i++) {
        var shipBody =
            _battleFieldStateTa.cellPad[i][dataY2].onThisBoardCellShipBody;
        if (shipBody != null) {
          if (shipBody.shipBodyState == 0) {
            shipBody.beingAttack('H', _turn);
            var ship = _battleFieldStateTa.fleet
                .getShip(shipBody.shipType, shipBody.shipName);
            ship.checkDamage();
            if (ship.getShipState() == 3) {
              ship.die("H", _turn);
            }
            reloadMap();
            take2x = 8 + shipBody.shipBodPosition.x;
            thisTurnAttck++;
            break;
          }
        }
      }
      String str = ToolRefer.ascii[dataY2] +
          ToolRefer.ascii[dataX2] +
          ToolRefer.ascii[take2x ?? 16];
      fireBaseDB.child("Battle/$_turn").update({"B": "$str"}).whenComplete(() {
        print("launch $str Torpedo");
      }).catchError((error) {
        print(error);
      });
    }
    for (int i = 0; i < 8; i++) {
      var shipBody =
          _battleFieldStateTa.cellPad[i][dataY1].onThisBoardCellShipBody;
      print(shipBody);
      if (shipBody != null) {
        if (shipBody.shipBodyState == 0) {
          shipBody.beingAttack('G', _turn);
          var ship = _battleFieldStateTa.fleet
              .getShip(shipBody.shipType, shipBody.shipName);
          ship.checkDamage();
          if (ship.getShipState() == 3) {
            ship.die("G", _turn);
          }
          reloadMap();
          take1x = 8 + shipBody.shipBodPosition.x;
          thisTurnAttck++;
          break;
        }
      }
    }
    String str = ToolRefer.ascii[dataY1] +
        ToolRefer.ascii[dataX1] +
        ToolRefer.ascii[take1x ?? 16];
    fireBaseDB.child("Battle/$_turn").update({"A": "$str"}).whenComplete(() {
      print("launch $str Torpedo");

      changeTurn();
    }).catchError((error) {
      print(error);
    });
  }

  void changeTurn() => fireBaseDB
      .child("PlayerState")
      .update({"Turn": (_turns + 1).toString()})
      .whenComplete(() => fireBaseDB
          .child("LastShipNumber")
          .update({
            _battleFieldStateTa.fleet.getOwnerName():
                (lastSTa - thisTurnAttck).toString()
          })
          .whenComplete(() => print("L C"))
          .catchError((e) => print(e)))
      .catchError((e) => print(e));

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(whatTurnItIs()),
          Container(
            child: !_loaded
                ? null
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(-pi / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(_col, (posX) {
                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: List<Widget>.generate(_row, (posY) {
                              return GestureDetector(
                                  child: Container(
                                    color: iconColorList[markAttack[
                                            SinglePosition(8 + posX, posY)
                                                .toString()] ??
                                        0],
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.height /
                                                _globalAdjustmentCoefficient,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                _globalAdjustmentCoefficient,
                                        child: Icon(
                                          ToolRefer.iconDataListTa[
                                              _battleFieldStateTa
                                                  .getCell(posX, posY)
                                                  .getOnThisInNumber()],
                                          color: ToolRefer.iconColorListTa[
                                              _battleFieldStateTa
                                                  .getCell(posX, posY)
                                                  .getOnThisInNumber()],
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              _globalAdjustmentCoefficient,
                                        )),
                                  ),
                                  onTap: () {},
                                  onLongPress: () {});
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
          ),
          Container(
            child: new Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(-pi / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(_col, (posX) {
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(_row, (posY) {
                        return GestureDetector(
                            child: Container(
                              color: iconColorList[markAttack[
                                      SinglePosition(posX, posY).toString()] ??
                                  0],
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.height /
                                      _globalAdjustmentCoefficient,
                                  height: MediaQuery.of(context).size.height /
                                      _globalAdjustmentCoefficient,
                                  child: Icon(
                                    ToolRefer.iconDataListMe[_battleFieldState
                                        .getCell(posX, posY)
                                        .getOnThisInNumber()],
                                    color: ToolRefer.iconColorListMe[
                                        _battleFieldState
                                            .getCell(posX, posY)
                                            .getOnThisInNumber()],
                                    size: MediaQuery.of(context).size.height /
                                        _globalAdjustmentCoefficient,
                                  )),
                            ),
                            onTap: () {},
                            onLongPress: () {});
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
          Container(
            child: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  OutlineButton(
                    child: Text("Torpedoing"),
                    onPressed: () {
                      weaponButtonState = 1;
                      torpedoPathUpdate();
                    },
                  ),
                  OutlineButton(
                    child: Text("Shelling"),
                    onPressed: () => this.setState(() => weaponButtonState = 2),
                  )
                ],
              ),
              null
            ][(weaponButtonState == 0 && _myTurn) ? 0 : 1],
          ),
          Container(
            child: (weaponButtonState != 1 || !_myTurn)
                ? null
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(minWidth: 40),
                        margin: EdgeInsets.only(right: 12),
                        alignment: Alignment.center,
                        child: Text(
                          "lineChoice",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.remove),
                          color: Colors.green[600],
                          disabledColor: Colors.grey[300],
                          onPressed: shipCode < 1
                              ? null
                              : () {
                                  markAttack = {};
                                  print("shipcode ${shipCode--} - 1");
                                  torpedoPathUpdate();
                                }),
                      Text(
                        shipsCanTorpedo[shipCode].getShipTypeName() +
                            shipsCanTorpedo[shipCode].getShipName().toString(),
                        style: TextStyle(fontSize: 30),
                      ),
                      IconButton(
                          icon: Icon(Icons.add),
                          color: Colors.green[600],
                          disabledColor: Colors.grey[300],
                          onPressed: shipCode >= shipsCanTorpedo.length - 1
                              ? null
                              : () {
                                  markAttack = {};
                                  print("shipcode ${shipCode++} + 1");
                                  torpedoPathUpdate();
                                })
                    ],
                  ),
          ),
          Container(
            child: (weaponButtonState != 2 || !_myTurn)
                ? null
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(minWidth: 40),
                        margin: EdgeInsets.only(right: 12),
                        alignment: Alignment.center,
                        child: Text(
                          "lineChoice",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.remove),
                          color: Colors.green[600],
                          disabledColor: Colors.grey[300],
                          onPressed: () {}),
                      Text(
                        "Line1",
                        style: TextStyle(fontSize: 30),
                      ),
                      IconButton(
                          icon: Icon(Icons.add),
                          color: Colors.green[600],
                          disabledColor: Colors.grey[300],
                          onPressed: () {})
                    ],
                  ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(top: 10),
            child: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  OutlineButton(
                    child: Text("back"),
                    onPressed: () => this.setState(() {
                      weaponButtonState = 0;
                      markAttack = {};
                      shipCode = 0;
                    }),
                  ),
                  RaisedButton(
                    child: Text("Launch"),
                    onPressed: () {
                      if (!canLaunch) return;
                      canLaunch = false;
                      if (weaponButtonState == 1) torpedoing();
                      //if(weaponButtonState == 2)shelling();
                      weaponButtonState = 5;
                    },
                  )
                ],
              ),
              null
            ][(weaponButtonState != 0 && weaponButtonState != 5 && _myTurn)
                ? 0
                : 1],
          )
        ],
      ),
    );
  }

  bool canLaunch = true;
}
