import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/main.dart';
import 'package:sea_battle_nutn/ship_state.dart';
import 'package:sea_battle_nutn/territorial_sea.dart';

class SeaWarfare extends StatefulWidget {
  TerritorialSea _terStateMe;

  SeaWarfare(this._terStateMe, {Key key}) : super(key: key);

  @override
  _SeaWarfareState createState() => _SeaWarfareState();
}

class _SeaWarfareState extends State<SeaWarfare> {
  MediaQueryData _queryData;

  final _iconListMe = [
    Icon(Icons.crop_free, color: Color.fromARGB(0, 0, 0, 0)),
    Icon(Icons.crop_free, color: Color.fromARGB(0, 0, 0, 0)),
    Icon(Icons.add, color: Colors.green),
    Icon(Icons.format_clear, color: Colors.orange),
    Icon(Icons.send, color: Colors.blueGrey[900]),
    Icon(Icons.arrow_forward_ios, color: Colors.indigo),
    Icon(Icons.last_page, color: Colors.teal),
    Icon(Icons.keyboard_arrow_right, color: Colors.blueAccent)
  ];
  final _iconListTa = [
    Icon(Icons.crop_free, color: Colors.grey[850]),
    Icon(Icons.crop_free, color: Colors.grey[850]),
    Icon(Icons.add, color: Colors.green),
    Icon(Icons.layers_clear, color: Colors.orange),
    Icon(Icons.more, color: Colors.blueGrey[900]),
    Icon(Icons.arrow_back_ios, color: Colors.indigo),
    Icon(Icons.first_page, color: Colors.teal),
    Icon(Icons.arrow_left, color: Colors.blueAccent)
  ];

  int _globalAdjustmentCoefficient = 40;
  //bool _showUpdateButton = false;
  int _radioShipOrdinal = 4;
  bool _radioShipOrdinalLocked = false;
  String _ta;
  String _turn;
  bool _gameStart = false;
  TerritorialSea _terStateTa = new TerritorialSea();

  int weaponButtonState = 0;

  @override
  void initState() {
    _ta = widget._terStateMe.getOwner() == "Sente" ? "Gote" : "Sente";
    shipsCanTorpedo = widget._terStateMe.shipCanTorpedo();
    print("im here");
    print(shipsCanTorpedo);
    fireBaseDB.child("PlayerState").onValue.listen((Event event) {
      if (event.snapshot.value != null) {
        Map map = event.snapshot.value;
        this.setState(() {
          _turn = map["Turn"];

          shipsCanTorpedo = widget._terStateMe.shipCanTorpedo();
        });
      }
    });
    _turn = (_turn == "notStart" ? "wait$_ta" : "sente");
    fireBaseDB
        .child("PlayerState")
        .update({"Turn": _turn})
        .whenComplete(() => print("send wait"))
        .catchError((e) => print(e));
    super.initState();
  }

  void handleRedioValueChanged(int value) => this.setState(() =>
      _radioShipOrdinal = _radioShipOrdinalLocked ? _radioShipOrdinal : value);

  String whatTurnItIs() {
    print("????");
    if (_gameStart == false && _turn == "sente") {
      fireBaseDB
          .child("Teb")
          .once()
          .then((DataSnapshot snapshot) {
            Map data = snapshot.value;
            print(data[_ta].length);
            _terStateTa.importTebData(data[_ta], _ta);
          })
          .whenComplete(() => this.setState(() {
                print("Got");
                _gameStart = true;
              }))
          .catchError((e) => print(e));
    }
    return "this is" + (_turn == _ta ? "n't" : "") + " yor turn";
  }

  int shipCode = 0;
  List<Ship> shipsCanTorpedo = [];
  Map<int, int> markAttack = {};
  List<Color> colorList = [Color.fromARGB(0, 0, 0, 0), Colors.red[900]];
  int dataY1,dataY2,dataK;

  void torpedoPathUpdate() {
    var rand = Random();
    dataK = rand.nextInt(3) - 1;
    markAttack = {};
    dataY1 = shipsCanTorpedo[shipCode].getPosition().position1.y + dataK;
    dataY2 = shipsCanTorpedo[shipCode].getPosition().position2.y + dataK;
    if (shipsCanTorpedo[shipCode].isDD())
      for (int i = 0; i < 16; i++) markAttack[i * 16 + dataY1] = 1;
    else
      for (int i = 0; i < 16; i++) {
        markAttack[i * 16 + dataY1] = 1;
        if ((dataY1 - dataY2).abs() > 1) markAttack[i * 16 + (dataY1 + dataY2) ~/ 2] = 1;
        markAttack[i * 16 + dataY2] = 1;
      }
    setState(() {});
  }

  void torpedoing(){

    var x1 = 99,x2 = 99,x3 = 99;
    Ship ship1,ship2,ship3;

    for (var ship in _terStateTa.getAllShipInFleet()) {
      for(var shipBody in ship.getBody())
      {
        if(shipBody.x == -1) continue;
        if(5-shipsCanTorpedo[shipCode].shipType>0 && shipBody.y == dataY1) {
          if( shipBody.x < x1){
            x1 = shipBody.x;
            ship1 = ship;
            print(ship);
          }
        }
      }
    }


    Map boom = {};
    boom["Y1"]=dataY1.toString();
    if(5-shipsCanTorpedo[shipCode].shipType>1) boom["Y2"] = dataY2.toString();
    if(5-shipsCanTorpedo[shipCode].shipType>2) boom["Y3"] = ((dataY2+dataY1)~/2).toString();

    fireBaseDB.child("Battle").push().set({"FL_${5-shipsCanTorpedo[shipCode].shipType}":boom}).whenComplete(() {
      print("finish Battle set");
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    return Container(
        constraints: BoxConstraints(
            minHeight:
                _queryData.size.height / _globalAdjustmentCoefficient * 26),
        alignment: Alignment.topCenter,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(whatTurnItIs()),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(16, (posX) {
                        return Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(16, (posY) {
                            return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: colorList[
                                        markAttack[posX * 16 + posY] ?? 0]),
                                child: SizedBox(
                                    width: _queryData.size.height /
                                        _globalAdjustmentCoefficient,
                                    height: _queryData.size.height /
                                        _globalAdjustmentCoefficient,
                                    child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        iconSize: _queryData.size.height /
                                            _globalAdjustmentCoefficient,
                                        icon: posX < 8
                                            ? _iconListMe[widget._terStateMe
                                                .getCellState(posX, posY)]
                                            : _iconListTa[_gameStart
                                                ? _terStateTa.getCellState(
                                                    15 - posX, 15 - posY)
                                                : 0],
                                        onPressed: () {})));
                          }),
                        ));
                      }))),
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
                        onPressed: () =>
                            this.setState(() => weaponButtonState = 2),
                      )
                    ],
                  ),
                  null
                ][weaponButtonState == 0 ? 0 : 1],
              ),
              Container(
                child: weaponButtonState != 1
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
                                      print("shipcode ${shipCode--} - 1");
                                      torpedoPathUpdate();
                                    }),
                          Text(
                            shipsCanTorpedo[shipCode].getShipTypeName() +
                                shipsCanTorpedo[shipCode].getName().toString(),
                            style: TextStyle(fontSize: 30),
                          ),
                          IconButton(
                              icon: Icon(Icons.add),
                              color: Colors.green[600],
                              disabledColor: Colors.grey[300],
                              onPressed: shipCode >= shipsCanTorpedo.length - 1
                                  ? null
                                  : () {
                                      print("shipcode ${shipCode++} + 1");
                                      torpedoPathUpdate();
                                    })
                        ],
                      ),
              ),
              Container(
                child: weaponButtonState != 2
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
                          if(weaponButtonState == 1)torpedoing();
                          //if(weaponButtonState == 2)shelling();
                          
                        },
                      )
                    ],
                  ),
                  null
                ][weaponButtonState != 0 ? 0 : 1],
              )
            ]));
  }
}
