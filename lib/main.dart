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
  MediaQueryData _queryData;

  final _iconDefault = Icon(Icons.crop_free, color: Colors.grey[850]);
  final _iconFeature = [
    Icon(Icons.block, color: Colors.red),
    Icon(Icons.add, color: Colors.green)
  ]; //stop can
  final _iconShip = [
    Icon(Icons.format_clear, color: Colors.orange),
    Icon(Icons.send, color: Colors.blueGrey[900]),
    Icon(Icons.arrow_forward_ios, color: Colors.indigo),
    Icon(Icons.last_page, color: Colors.teal),
    Icon(Icons.keyboard_arrow_right, color: Colors.blueAccent)
  ]; //CV BB CA CL DD

  final _nameShip = ["CV", "BB", "CA", "CL", "DD"];
  final _lengthOfShip = [6, 4, 3, 2, 1];

  final dir4 = [
    [1, 0],
    [0, 1],
    [-1, 0],
    [0, -1]
  ];
  final dir8 = [
    [1, -1],
    [1, 0],
    [1, 1],
    [0, -1],
    [0, 1],
    [-1, -1],
    [-1, 0],
    [-1, 1]
  ];
  final dir8CV = [
    [2, 3],
    [-2, 3],
    [2, -3],
    [-2, -3],
    [3, 2],
    [3, -2],
    [-3, 2],
    [-3, -2]
  ];

  var _globalAdjustmentCoefficient = 24;
  var _showUpdateButton = false;
  var _radioShipOrdinal = 4;
  var _radioShipOrdinalLocked = false;
  var _someoneUsingFunction = false;
  var _bigShipSecondStep = false;
  var _stepOneX = 0;
  var _stepOneY = 0;

  var _numShip = [];
  var _numShipPlaced = [0, 0, 0, 0, 0];

  Map<int, Icon> iconMap = {};
  List<SinglePos> posDDs = [];
  List<SinglePos> posPaintShip = [];
  List<SinglePos> posPaintGreen = [];
  List<List<TwicePos>> posBig = [[], [], [], []];

  void handleRedioValueChanged(int value) => this.setState(() =>
      _radioShipOrdinal = _radioShipOrdinalLocked ? _radioShipOrdinal : value);

  @override
  void initState() {
    super.initState();
    _numShip.addAll(_lastShipForLayout);
    for (var x = 0; x < 16 * 8; x++) iconMap[x] = _iconDefault;
  }

  void reSet() {
    _globalAdjustmentCoefficient = 24;
    _showUpdateButton = false;
    _radioShipOrdinal = 4;
    _radioShipOrdinalLocked = false;
    _someoneUsingFunction = false;
    _bigShipSecondStep = false;
    _stepOneX = 0;
    _stepOneY = 0;

    _numShipPlaced = [0, 0, 0, 0, 0];

    posDDs = [];
    posPaintShip = [];
    posPaintGreen = [];
    posBig = [[], [], [], []];

    for (var x = 0; x < 16 * 8; x++) iconMap[x] = _iconDefault;

    setState(() {});
  }

  void markAroundEmptyRed(int x, int y) {
    for (final p in dir4) {
      var xx = (x + p[0]) < 0 ? 0 : ((x + p[0]) > 7 ? 7 : (x + p[0]));
      var yy = (y + p[1]) < 0 ? 0 : ((y + p[1]) > 15 ? 15 : (y + p[1]));
      if (iconMap[xx * 16 + yy] == _iconDefault)
        iconMap[xx * 16 + yy] = _iconFeature[0];
    }
  }

  bool smallShipPlace(int x, int y) {
    if (iconMap[x * 16 + y] != _iconDefault) return false;
    iconMap[x * 16 + y] = _iconShip[4];
    markAroundEmptyRed(x, y);
    return true;
  }

  bool findPossiblePath(int x, int y) {
    var numPossiblePath = 8;
    print("now at $x , $y Start find path");
    if (_radioShipOrdinal == 0) {
      for (var d in dir8CV) {
        if (x + d[0] > 8 || x + d[0] < -1 || y + d[1] > 16 || y + d[1] < -1)
          numPossiblePath--;
        else if (iconMap[(x + d[0] - (d[0] > 0 ? 1 : -1)) * 16 +
                (y + d[1] - (d[1] > 0 ? 1 : -1))] !=
            _iconDefault)
          numPossiblePath--;
        else {
          var aGridBeDetectedCannot = 0;
          for (int i = 0; i != d[0]; i += d[0] > 0 ? 1 : -1)
            for (int j = 0; j != d[1]; j += d[1] > 0 ? 1 : -1) {
              print(
                  "now cheak in dir($d)'s ${x + i} , ${y + j} is ${iconMap[(x + i) * 16 + y + j] == _iconFeature[0] ? "red" : " ?"}");
              if (iconMap[(x + i) * 16 + y + j] != _iconDefault &&
                  (i != 0 || j != 0)) {
                aGridBeDetectedCannot++;
                print("in dir($d) it's not default ${x + i} , ${y + j}");
              }
            }
          if (aGridBeDetectedCannot == 0) {
            iconMap[(x + d[0] - (d[0] > 0 ? 1 : -1)) * 16 +
                (y + d[1] - (d[1] > 0 ? 1 : -1))] = _iconFeature[1];
            posPaintGreen.add(SinglePos((x + d[0] - (d[0] > 0 ? 1 : -1)),
                (y + d[1] - (d[1] > 0 ? 1 : -1))));
          } else
            numPossiblePath--;
        }
      }
    } else {
      for (var d in dir8) {
        if (x + d[0] * (_lengthOfShip[_radioShipOrdinal] - 1) > 7 ||
            x + d[0] * (_lengthOfShip[_radioShipOrdinal] - 1) < 0 ||
            y + d[1] * (_lengthOfShip[_radioShipOrdinal] - 1) > 15 ||
            y + d[1] * (_lengthOfShip[_radioShipOrdinal] - 1) < 0)
          numPossiblePath--;
        else {
          var aGridBeDetectedCannot = 0;
          for (int i = 1; i < (_lengthOfShip[_radioShipOrdinal]); i++) {
            if (iconMap[(x + i * d[0]) * 16 + y + i * d[1]] != _iconDefault) {
              aGridBeDetectedCannot++;
            }
          }
          if (aGridBeDetectedCannot == 0) {
            iconMap[(x + d[0] * (_lengthOfShip[_radioShipOrdinal] - 1)) * 16 +
                    (y + d[1] * (_lengthOfShip[_radioShipOrdinal] - 1))] =
                _iconFeature[1];
            posPaintGreen.add(SinglePos(
                x + d[0] * (_lengthOfShip[_radioShipOrdinal] - 1),
                y + d[1] * (_lengthOfShip[_radioShipOrdinal] - 1)));
          } else
            numPossiblePath--;
        }
      }
    }
    print("finish find passible path is ${numPossiblePath}");
    return numPossiblePath > 0 ? true : false;
  }

  bool bigShipPlace(int x, int y) {
    if (iconMap[x * 16 + y] != _iconDefault) return false;
    if (findPossiblePath(x, y))
      return true;
    else
      return false;
  }

  void fillUpShipBody(int x, int y) {
    if (_radioShipOrdinal == 0) {
      var dx = _stepOneX - x;
      var dy = _stepOneY - y;
      for (int i = 0; i != dx + (dx > 0 ? 1 : -1); i += dx > 0 ? 1 : -1)
        for (int j = 0; j != dy + (dy > 0 ? 1 : -1); j += dy > 0 ? 1 : -1) {
          iconMap[(x + i) * 16 + y + j] = _iconShip[0];
          posPaintShip.add(SinglePos(x + i, y + j));
          print(
              "Now paint ${x + i} ${y + j} with ${_nameShip[_radioShipOrdinal]}");
        }
    } else {
      var dirX = (x - _stepOneX) ~/ (_lengthOfShip[_radioShipOrdinal] - 1);
      var diry = (y - _stepOneY) ~/ (_lengthOfShip[_radioShipOrdinal] - 1);
      var tx = _stepOneX;
      var ty = _stepOneY;
      for (int i = 0;
          i < _lengthOfShip[_radioShipOrdinal];
          tx += dirX, ty += diry, i++) {
        iconMap[tx * 16 + ty] = _iconShip[_radioShipOrdinal];
        posPaintShip.add(SinglePos(tx, ty));
      }
    }
    while (posPaintGreen.isNotEmpty) {
      SinglePos temp = posPaintGreen.removeLast();
      if (x == temp.x && y == temp.y) continue;
      iconMap[temp.x * 16 + temp.y] = _iconDefault;
    }
    while (posPaintShip.isNotEmpty) {
      SinglePos temp = posPaintShip.removeLast();
      markAroundEmptyRed(temp.x, temp.y);
    }
  }

  void checkAllShipHaveBeenPlaced() {
    for (int i = 0; i < _numShip.length; i++)
      if (_numShip[i] != _numShipPlaced[i]) return;
    _showUpdateButton = true;
  }

  void update() {
    Map<String, Map<String, String>> data = {"pos1": {}, "pos2": {}};
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
          print("update BigShip finish");
        }).catchError((error) {
          print(error);
        });
      }
    }
    data = {"pos1": {}};
    for (int j = 0; j < _numShip[4]; j++) {
      data["pos1"]["x"] = posDDs[j].x.toString();
      data["pos1"]["y"] = posDDs[j].y.toString();
      fireBaseDB
          .child("State/${_whoAmI}/${_nameShip[4]}/${j.toString()}")
          .update(data)
          .whenComplete(() {
        print("update DD finish");
      }).catchError((error) {
        print(error);
      });
    }
  }

  void writeShip(int x, int y) {
    print(
        "Start Write with step${_bigShipSecondStep ? 2 : 1} for ${_nameShip[_radioShipOrdinal]}");
    final currentRadioShipOrdinal = _radioShipOrdinal;
    if (_someoneUsingFunction) return;
    _someoneUsingFunction = true;
    if (_bigShipSecondStep) {
      if (iconMap[x * 16 + y] == _iconFeature[1]) {
        print("start fill up");
        fillUpShipBody(x, y);
        posBig[_radioShipOrdinal].add(TwicePos(_stepOneX, _stepOneY, x, y));
        _numShipPlaced[_radioShipOrdinal]++;
        _bigShipSecondStep = false;
        _radioShipOrdinalLocked = false;
      }
    } else {
      _radioShipOrdinalLocked = true;

      if (currentRadioShipOrdinal == 4) {
        if (smallShipPlace(x, y)) {
          posDDs.add(SinglePos(x, y));
          _numShipPlaced[4]++;
          _radioShipOrdinalLocked = false;
        }
      } else {
        if (bigShipPlace(x, y)) {
          iconMap[x * 16 + y] = _iconShip[_radioShipOrdinal];
          _stepOneX = x;
          _stepOneY = y;
          _bigShipSecondStep = true;
        }
      }
    }
    checkAllShipHaveBeenPlaced();
    setState(() {});
    _someoneUsingFunction = false;
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: !_showUpdateButton
                ? null
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      OutlineButton(
                        child: Text("reSet"),
                        onPressed: reSet,
                      ),
                      OutlineButton(
                        child: Text("upDate"),
                        onPressed: update,
                      )
                    ],
                  ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(8, (posX) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(16, (posY) {
                      return SizedBox(
                        width: _queryData.size.height /
                            _globalAdjustmentCoefficient,
                        height: _queryData.size.height /
                            _globalAdjustmentCoefficient,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          iconSize: _queryData.size.height /
                              _globalAdjustmentCoefficient,
                          icon: iconMap[posX * 16 + posY],
                          onPressed: () {
                            print(
                                "had placed ${_numShipPlaced[_radioShipOrdinal]} , total ${_numShip[_radioShipOrdinal]}");
                            if (_numShipPlaced[_radioShipOrdinal] <
                                _numShip[_radioShipOrdinal])
                              writeShip(posX, posY);
                          },
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(5, (shipOrdinal) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Radio(
                        value: shipOrdinal,
                        groupValue: _radioShipOrdinal,
                        onChanged: handleRedioValueChanged,
                      ),
                      Text(_nameShip[shipOrdinal])
                    ],
                  ),
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

    fireBaseDB.child("State/$_whoAmI").set(data).whenComplete(() {
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
