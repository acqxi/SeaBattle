import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:sea_battle_nutn/SeaWarfare.dart';
import 'package:sea_battle_nutn/battle_event.dart';
//import 'package:sea_battle_nutn/embattle.dart';
import 'package:sea_battle_nutn/fleet%20_forming.dart';
import 'package:sea_battle_nutn/fleet_state.dart';
//import 'package:sea_battle_nutn/territorial_sea.dart';

final DatabaseReference fireBaseDB = FirebaseDatabase.instance.reference();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CBattle",
      home: Scaffold(
        appBar: StatefulAppBar(),
        body: HomePage(),
      ),
    );
  }
}

class StatefulAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  _StatefulAppBarState createState() => _StatefulAppBarState();
}

class _StatefulAppBarState extends State<StatefulAppBar> {
  var _stepOrdinal = 0;
  var _stepNameList = [
    "CBattle",
    "Sente FleetForming",
    "Gote FleetForming",
    "Onlooker FleetForming",
    "Embattle",
    "SeaWarfare"
  ];
  var _playerName = "";

  @override
  void initState() {
    super.initState();
    eventBus
        .on<StepChangerEvent>()
        .listen((StepChangerEvent data) => this.setState(() {
              _stepOrdinal = data.stepOrdinal;
              if (data.stepOrdinal < 4)
                _playerName =
                    ["Start", "Sente", "Gote", "Onlooker"][data.stepOrdinal];
            }));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(_playerName + _stepNameList[_stepOrdinal]));
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //StreamSubscription<Event> fireBaseDBSubScription;

  var _stepOrdinal = 0;
  var _player = 0;
  var _fleet;
  //var _terri = TerritorialSea();

  final _playerName = ["Start", "Sente", "Gote", "Onlooker"];

  @override
  void initState() {
    fireBaseDB.child("PlayerState").once().then((DataSnapshot snapshot) {
      var user = snapshot.value;
      user ??
          fireBaseDB
              .child("PlayerState")
              .set({"Sente": "unuse", "Gote": "unuse", "Turn": "notStart"})
              .whenComplete(() => print("finish set init player state"))
              .catchError((error) => print(error));
    }).catchError((error) => print(error));
    super.initState();

    eventBus.on<StepChangerEvent>().listen((StepChangerEvent data) =>
        this.setState(() => _stepOrdinal = data.stepOrdinal));
  }

  void startCBattle() {
    print("ONPRESS");
    fireBaseDB
        .child("PlayerState")
        .once()
        .then((DataSnapshot snapshot) {
          var data = snapshot.value;
          print(data["${_playerName[1]}"]);
          if (data["${_playerName[1]}"] == "unuse")
            _player = 1;
          else if (data["${_playerName[2]}"] == "unuse")
            _player = 2;
          else
            _player = 3;

          _fleet = Fleet(_player);
          print(_fleet.getOwnerName());

          fireBaseDB
              .child("PlayerState")
              .update({"${_playerName[_player]}": "using"})
              .whenComplete(() => print("update finish"))
              .catchError((error) => print(error));
        })
        .catchError((e) => print(e))
        .whenComplete(() => eventBus.fire(StepChangerEvent(_player)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                child: Text(_playerName[_player]),
                onPressed: _stepOrdinal != 0 ? null : startCBattle,
              )
            ],
          ),
        ),
        [
          Container(),
          FleetForming(_fleet, _stepOrdinal),
          //Embattle(_fleet),
          //SeaWarfare(_terri)
        ][_stepOrdinal < 1 ? 0 : (_stepOrdinal < 4 ? 1 : (_stepOrdinal - 2))],
      ],
    );
  }
}
