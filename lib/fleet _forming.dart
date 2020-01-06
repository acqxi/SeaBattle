import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/fleet_state.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class FleetForming extends StatefulWidget {
  final _widgetFleet;
  FleetForming(Fleet this._widgetFleet, {Key key}) : super(key: key);

  @override
  _FleetFormingState createState() => _FleetFormingState();
}

class _FleetFormingState extends State<FleetForming> {
  var _numShip = [1, 1, 1, 1, 1]; //CV 6 BB 4 CA 3 CL 2 DD 1
  var _nameShip = ['CV', 'BB', 'CA', 'CL', 'DD'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(5, (index) {
            return Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.exposure_plus_1),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.exposure_neg_1),
                      onPressed: () {},
                    ),
                    Text(_numShip[index].toString()),
                    Text(_nameShip[index])
                  ],
                ));
          }),
        ),
      ),
      OutlineButton(
        child: Text("Finish"),
        onPressed: null,
      )
    ]);
  }
}
