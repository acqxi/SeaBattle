import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/fleet_state.dart';
import 'package:sea_battle_nutn/ship_state.dart';
import 'package:sea_battle_nutn/territorial_sea.dart';

class Embattle extends StatefulWidget {
  final Fleet _wFleet;

  Embattle(this._wFleet, {Key key}) : super(key: key);

  @override
  _EmbattleState createState() => _EmbattleState();
}

class _EmbattleState extends State<Embattle> {
  MediaQueryData _queryData;

  final _iconList = [
    Icon(Icons.crop_free, color: Colors.grey[850]),
    Icon(Icons.block, color: Colors.red),
    Icon(Icons.add, color: Colors.green),
    Icon(Icons.format_clear, color: Colors.orange),
    Icon(Icons.send, color: Colors.blueGrey[900]),
    Icon(Icons.arrow_forward_ios, color: Colors.indigo),
    Icon(Icons.last_page, color: Colors.teal),
    Icon(Icons.keyboard_arrow_right, color: Colors.blueAccent)
  ]; //default stop can CV BB CA CL DD

  final _nameShip = ["CV", " BB", " CA ", "CL", "DD"];

  var _globalAdjustmentCoefficient = 24;
  var _showUpdateButton = false;
  var _radioShipOrdinal = 4;
  var _radioShipOrdinalLocked = false;
  var _someoneUsingFunction = false;

  int _shipStep = 0;
  TerritorialSea _terState = new TerritorialSea();

  void handleRedioValueChanged(int value) => this.setState(() =>
      _radioShipOrdinal = _radioShipOrdinalLocked ? _radioShipOrdinal : value);

  @override
  void initState() {
    _terState.buildTerritorialSeaMap(widget._wFleet);
    super.initState();
  }

  void reSet() {
    _globalAdjustmentCoefficient = 24;
    _showUpdateButton = false;
    _radioShipOrdinal = 4;
    _radioShipOrdinalLocked = false;
    _someoneUsingFunction = false;

    _terState.resetPlaceTer();
    _terState.updateFleet();

    setState(() {});
  }

  void writeShip(int x, int y) {
    if (_someoneUsingFunction) return;
    _someoneUsingFunction = true;
    _radioShipOrdinalLocked = true;
    Ship tempShip = Ship(_radioShipOrdinal);
    print("Start Write with step$_shipStep for ${tempShip.shipType}");

    _shipStep = _terState.positioningShip(x, y, tempShip);
    if (_shipStep == 0) {
      _radioShipOrdinalLocked = false;
    }
    _showUpdateButton = _terState.isFleetOkey();
    print("SetState : $_shipStep");
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
                        onPressed: _terState.updateFleet,
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
                          icon: _iconList[_terState.getCellState(posX, posY)],
                          onPressed: () {
                            print(
                                "YetShipNumberinFleet : ${_terState.getYetShipNumberinFleet()[_radioShipOrdinal]}");
                            if (_terState.getYetShipNumberinFleet()[
                                    _radioShipOrdinal] >
                                0) writeShip(posX, posY);
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
                      Text(_nameShip[shipOrdinal]),
                      Text(_terState.getYetShipNumberinFleet()[shipOrdinal].toString())
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
