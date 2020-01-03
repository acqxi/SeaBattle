import 'dart:ffi';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'dart:async';

final DatabaseReference fireBaseDB = FirebaseDatabase.instance.reference();

void main() => runApp(MyApp());

var _isChooseShipDisable = true;
var _isChooseShipButtonDisable = false;
var _isHalfBoardDisable = true;
var _lastShipForLayout = [];
var _whoAmI = "Start";

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Material App Bar'),
          ),
          body: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //StreamSubscription<Event> fireBaseDBSubScription;

  var _startButtonMainAxisAlignmentState = MainAxisAlignment.center;
  var _isStartButtonDisable = false;

  @override
  void initState() {
    fireBaseDB.child("PlayerState").once().then((DataSnapshot snapshot) {
      var user = snapshot.value;
      print(user);
      if (user == null) {
        Map<String, String> data = {"player1": "nobody", "player2": "nobody"};

        fireBaseDB.child("PlayerState").set(data).whenComplete(() {
          print("finish set");
        }).catchError((error) {
          print(error);
        });
      }
    }).catchError((error) {
      print(error);
    });
    super.initState();
  }

  void startCBattle() {
    print("ONPRESS");
    fireBaseDB
        .child("PlayerState")
        .once()
        .then((DataSnapshot snapshot) {
          var data = snapshot.value;
          print(data["player1"]);
          if (data["player1"] == "nobody") {
            _whoAmI = "player1";
            Map<String, String> data = {"player1": "someone"};

            fireBaseDB.child("PlayerState").update(data).whenComplete(() {
              print("update finish");
            }).catchError((error) {
              print(error);
            });
          } else if (data["player2"] == "nobody") {
            _whoAmI = "player2";
            Map<String, String> data = {"player2": "someone"};

            fireBaseDB.child("PlayerState").update(data).whenComplete(() {
              print("update finish");
            }).catchError((error) {
              print(error);
            });
          } else {
            _whoAmI = "twoPeoplePlaying";
            print("error");
          }
        })
        .catchError((e) => print(e))
        .whenComplete(() {
          this.setState(() {
            _startButtonMainAxisAlignmentState = MainAxisAlignment.start;
          });
          _isStartButtonDisable = true;
          _isChooseShipDisable = false;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: _startButtonMainAxisAlignmentState,
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                child: Text(_whoAmI),
                onPressed: _isStartButtonDisable ? null : startCBattle,
              )
            ],
          ),
        ),
        ChooseShip(),
      ],
    );
  }
}

class HalfBoard extends StatefulWidget {
  HalfBoard({Key key}) : super(key: key);

  @override
  _HalfBoardState createState() => _HalfBoardState();
}

class SinglePos {
  final x;
  final y;
  const SinglePos(this.x, this.y);
}

class TwicePos {
  final x1;
  final y1;
  final x2;
  final y2;
  const TwicePos(this.x1, this.y1, this.x2, this.y2);
}

class _HalfBoardState extends State<HalfBoard> {
  Map<int, Color> iconColorsMap = {};
  Map<int, IconData> iconsMap = {};

  List<SinglePos> posDDs = [];
  List<SinglePos> posPainted = [];
  List<List<TwicePos>> posBig = [[], [], [], []];

  var _numShip = [];
  var _numShipPlaced = [0, 0, 0, 0, 0];
  bool _bigShipStepOne = true;
  var _stepOneX = 0;
  var _stepOneY = 0;
  var _stepOneShipType = 0;
  var _nameShip = ["CV", 'BB', "CA", "CL"];

  @override
  void initState() {
    super.initState();
    _numShip.addAll(_lastShipForLayout);

    for (var x = 0; x < 16 * 8; x++) {
      iconColorsMap[x] = Colors.black;
      iconsMap[x] = Icons.crop_free;
    }
  }

  MediaQueryData _queryData;
  var radioSN = 4;

  void handleRedioValueChanged(int value) {
    this.setState(() {
      radioSN = value;
    });
  }

  bool paintGrid(int x, int y, Color colorP, IconData iconP) {
    if (iconColorsMap[x * 16 + y] != Colors.black &&
        iconColorsMap[x * 16 + y] != Colors.green) return false;
    if (x < 0 || x > 7 || y < 0 || y > 15) return false;
    iconColorsMap[x * 16 + y] = colorP;
    iconsMap[x * 16 + y] = iconP;
    return true;
  }

  void cantPlace(int x, int y) => paintGrid(x, y, Colors.red, Icons.block);
  bool cheakPath(int x, int y, int l, int dx, int dy) {
    for (int i = 1; i <= l; i++) {
      if (iconColorsMap[(x += dx) * 16 + (y += dy)] != Colors.black)
        return false;
    }
    return true;
  }

  bool canPlace(int x, int y, int l) {
    l -= 1;
    var power = false;
    var dir = [
      [1, -1],
      [1, 0],
      [1, 1],
      [0, -1],
      [0, 1],
      [-1, -1],
      [-1, 0],
      [-1, 1]
    ];
    for (int i = 0; i < 8; i++) {
      print("${x + l * dir[i][0]}, ${y + l * dir[i][1]}");
      if (paintGrid(
          x + l * dir[i][0], y + l * dir[i][1], Colors.green, Icons.add)) {
        if (cheakPath(x, y, l, dir[i][0], dir[i][1])) {
          print("<<<${x + l * dir[i][0]}, ${y + l * dir[i][1]}");
          paintGrid(x + l * dir[i][0], y + l * dir[i][1], Colors.black,
              Icons.crop_free);
        } else {
          print(">>>${x + l * dir[i][0]}, ${y + l * dir[i][1]}");
          SinglePos temp = new SinglePos(x + l * dir[i][0], y + l * dir[i][1]);
          posPainted.add(temp);
          power = true;
        }
      }
    }
    return power;
  }

  void writeSmallShip(int x, int y) {
    if (iconColorsMap[x * 16 + y] != Colors.black) return;
    iconColorsMap[x * 16 + y] = Colors.blueAccent;
    iconsMap[x * 16 + y] = Icons.keyboard_arrow_right;

    cantPlace(max(x - 1, 0), y);
    cantPlace(min(x + 1, 8), y);
    cantPlace(x, max(y - 1, 0));
    cantPlace(x, min(y + 1, 16));

    SinglePos posDD = new SinglePos(x, y);
    posDDs.add(posDD);
    _numShipPlaced[4]++;
    cheakFinishLayout();
    setState(() {});
  }

  void writeBigShip(int x, int y) {
    final lengthShip = [6, 4, 3, 2, 1];

    print("mission got");
    if (_bigShipStepOne) {
      if (iconColorsMap[x * 16 + y] != Colors.black) return;

      if (canPlace(x, y, lengthShip[radioSN])) {
        iconColorsMap[x * 16 + y] = Colors.orange;
        iconsMap[x * 16 + y] = Icons.keyboard_arrow_right;
      } else
        return;
      _stepOneX = x;
      _stepOneY = y;
      _stepOneShipType = radioSN;
      _bigShipStepOne = false;
      print("step1 finish");
    } else {
      if (iconColorsMap[x * 16 + y] != Colors.green) return;
      var dirX = (x - _stepOneX) ~/ (lengthShip[radioSN] - 1);
      var diry = (y - _stepOneY) ~/ (lengthShip[radioSN] - 1);
      print("start paint $dirX $diry");

      while (posPainted.isNotEmpty) {
        SinglePos temp = posPainted.removeLast();
        paintGrid(temp.x, temp.y, Colors.black, Icons.crop_free);
      }
      var tx = _stepOneX;
      var ty = _stepOneY;
      for (int i = 0; i < lengthShip[radioSN]; tx += dirX, ty += diry, i++) {
        //print("paint $_stepOneX $_stepOneY");
        iconColorsMap[tx * 16 + ty] = Colors.orange;
        iconsMap[tx * 16 + ty] = Icons.keyboard_arrow_right;
        cantPlace(max(tx - 1, 0), ty);
        cantPlace(min(tx + 1, 8), ty);
        cantPlace(tx, max(ty - 1, 0));
        cantPlace(tx, min(ty + 1, 16));
      }

      TwicePos posBi = new TwicePos(x, y, _stepOneX, _stepOneY);

      _bigShipStepOne = true;
      _numShipPlaced[radioSN]++;
      posBig[_stepOneShipType].add(posBi);
    }
    cheakFinishLayout();
    setState(() {});
  }

  void cheakFinishLayout() {
    for (int i = 0; i < _numShip.length; i++) {
      if (_numShip[i] != _numShipPlaced[i]) return;
    }
    layoutFinish();
  }

  void layoutFinish() {
    Map<String, Map<String, String>> data = {"pos1":{},"pos2":{}};
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < _numShip[i]; j++) {
        data["pos1"]["x"] = posBig[i][j].x1.toString();
        data["pos1"]["y"] = posBig[i][j].y1.toString();
        data["pos2"]["x"] = posBig[i][j].x2.toString();
        data["pos2"]["y"] = posBig[i][j].y2.toString();
        fireBaseDB
            .child("State/${_whoAmI}/${_nameShip[i]}/${j.toString()}")
            .update(data)
            .whenComplete(() {
          print("update finish");
        }).catchError((error) {
          print(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(8, (posX) {
                return Container(
                    //constraints: BoxConstraints(                              maxWidth: _queryData.size.height / 24),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(16, (posY) {
                          return Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                              //height: _queryData.size.height / 24,
                              child: SizedBox(
                                width: _queryData.size.height / 24,
                                height: _queryData.size.height / 24,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  iconSize: _queryData.size.height / 24,
                                  onPressed: () {
                                    print(_numShipPlaced[radioSN] * 10 +
                                        _numShip[radioSN]);
                                    if (_numShipPlaced[radioSN] <
                                        _numShip[radioSN]) {
                                      if (radioSN == 4) {
                                        writeSmallShip(posX, posY);
                                      } else
                                        writeBigShip(posX, posY);
                                    }
                                  },
                                  icon: Icon(
                                    iconsMap[posX * 16 + posY],
                                    color: iconColorsMap[posX * 16 + posY],
                                  ),
                                ),
                              ));
                        })));
              }),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(5, (shipName) {
                return Radio(
                  value: shipName,
                  groupValue: radioSN,
                  onChanged: handleRedioValueChanged,
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}

class ChooseShip extends StatefulWidget {
  ChooseShip({Key key}) : super(key: key);

  @override
  _ChooseShipState createState() => _ChooseShipState();
}

class _ChooseShipState extends State<ChooseShip> {
  var _numShip = [1, 1, 1, 1, 1]; //CV 6 BB 4 CA 3 CL 2 DD 1
  var _nameShip = ['CV', 'BB', 'CA', 'CL', 'DD'];

  _ChooseShipState();

  int totalGridOfShips() =>
      _numShip[0] * 6 +
      _numShip[1] * 4 +
      _numShip[2] * 3 +
      _numShip[3] * 2 +
      _numShip[4] * 1;
  bool isFit() => totalGridOfShips() == 32 && !_isChooseShipButtonDisable;

  void sendDataAndStartLayout() {
    final Map<String, Map<String, Map<String, String>>> data = {};
    final Map<String, String> bigShipState = {
      "liveState": "notOnBattle",
      "pos1": "0",
      "pos2": "0"
    };
    final Map<String, String> smallShipState = {
      "liveState": "notOnBattle",
      "pos1": "0"
    };
    for (var x = 0; x < _numShip.length; x++) {
      final Map<String, Map<String, String>> temp = {};
      for (var y = 0; y < _numShip[x]; y++) {
        temp[y.toString()] = x == 4 ? smallShipState : bigShipState;
      }
      data["${_nameShip[x]}"] = temp;
    }

    fireBaseDB.child("State/${_whoAmI}").set(data).whenComplete(() {
      print("finish set");
    }).catchError((error) {
      print(error);
    });
    _isChooseShipButtonDisable = true;
    this.setState(() {});
    _isHalfBoardDisable = false;
    _lastShipForLayout.addAll(_numShip);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: _isChooseShipDisable
            ? null
            : Column(children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(5, (index) {
                      return Container(
                          padding: EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _isChooseShipButtonDisable
                                  ? Container()
                                  : IconButton(
                                      icon: Icon(Icons.exposure_plus_1),
                                      onPressed: () {
                                        if ((index != 4 || _numShip[index] < 5))
                                          _numShip[index]++;
                                        if (totalGridOfShips() > 32)
                                          _numShip[index]--;
                                        this.setState(() {});
                                      },
                                    ),
                              _isChooseShipButtonDisable
                                  ? Container()
                                  : IconButton(
                                      icon: Icon(Icons.exposure_neg_1),
                                      onPressed: () {
                                        this.setState(() => _numShip[index] =
                                            max(_numShip[index] - 1, 1));
                                      },
                                    ),
                              Text(_numShip[index].toString()),
                              Text(_nameShip[index])
                            ],
                          ));
                    }),
                  ),
                ),
                _isChooseShipButtonDisable
                    ? Container()
                    : OutlineButton(
                        child: Text("Finish"),
                        onPressed: !isFit() ? null : sendDataAndStartLayout,
                      ),
                Container(
                  child: _isHalfBoardDisable ? null : HalfBoard(),
                )
              ]));
  }
}
