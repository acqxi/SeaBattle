import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/battle_event.dart';
import 'package:sea_battle_nutn/fleet_state.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class FleetForming extends StatefulWidget {
  final int _player;
  final Fleet _widgetFleet;
  FleetForming(this._widgetFleet, this._player, {Key key}) : super(key: key);

  @override
  _FleetFormingState createState() => _FleetFormingState();
}

class _FleetFormingState extends State<FleetForming> {
  final _shipTypeNameList = ["CV", "BB", "CA", "CL", "DD"];
  final _allowableAreaOfShipHoldList = [0, 32, 34, 64];

  @override
  void initState() {
    for (var x in [0, 1, 2, 3, 4]) widget._widgetFleet.addShip(new Ship(x));
    super.initState();
  }

  bool isCannotPlus(index) {
    if ((widget._widgetFleet.howMuchAreaIsHeld() >
        (_allowableAreaOfShipHoldList[widget._player] -
            Ship(index).getShipPower()))) return true;
    if ((index == 4 && widget._widgetFleet.howMuchShipFormed()[index] > 4))
      return true;
    return false;
  }

  bool isCannotFinish() {
    if (widget._player == 3) return false;
    if (widget._widgetFleet.howMuchAreaIsHeld() ==
        _allowableAreaOfShipHoldList[widget._player]) return false;
    return true;
  }

  @override
  void dispose() { 
    eventBus.fire(FleetChangeEvent(widget._widgetFleet));
    eventBus.fire(StepChangerEvent(4));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(5, (index) {
                return Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(minWidth: 40),
                            margin: EdgeInsets.only(right: 12),
                            alignment: Alignment.center,
                            child: Text(
                              _shipTypeNameList[index],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove),
                            color: Colors.green[600],
                            disabledColor: Colors.grey[300],
                            onPressed: widget._widgetFleet
                                        .howMuchShipFormed()[index] <
                                    2
                                ? null
                                : () => this.setState(
                                    () => widget._widgetFleet.popShip(index)),
                          ),
                          Text(
                            widget._widgetFleet
                                .howMuchShipFormed()[index]
                                .toString(),
                            style: TextStyle(fontSize: 30),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.green[600],
                            disabledColor: Colors.grey[300],
                            onPressed: isCannotPlus(index)
                                ? null
                                : () => this.setState(() {
                                      widget._widgetFleet
                                          .addShip(new Ship(index));
                                    }),
                          )
                        ]));
              }))),
      OutlineButton(
        child: Text("Finish"),
        onPressed:
            isCannotFinish() ? null : dispose,
      )
    ]);
  }
}
