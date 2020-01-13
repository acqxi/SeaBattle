import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/battle_event.dart';
import 'package:sea_battle_nutn/basic_class.dart';
import 'package:sea_battle_nutn/territorial_sea.dart';

class Embattle extends StatefulWidget {
  final BattleField _battleField;

  Embattle(this._battleField);

  @override
  _EmbattleState createState() => _EmbattleState();
}

class _EmbattleState extends State<Embattle> {
  bool _showUpdateButton;
  bool _radioLocked;
  int _globalAdjustmentCoefficient;
  int _row;
  int _col;
  int _radioShipOrdinal;

  BattleField _battleFieldState;

  @override
  void initState() {
    _showUpdateButton = false;
    _row = 8;
    _col = 8;
    _globalAdjustmentCoefficient = 24;
    _radioShipOrdinal = 0;
    _radioLocked = false;

    _battleFieldState = widget._battleField;

    _battleFieldState.initial();

    super.initState();
  }

  void handleRedioValueChanged(int value) => this.setState(() {
        if (_radioLocked) return;
        if (value == 10) {
          for (int x in [0, 1, 2, 3, 4]) {
            if (_battleFieldState.fleet.getYetShips()[x] != 0) _radioShipOrdinal = x;
          }
          if (_battleFieldState.fleet.getYetShips()[_radioShipOrdinal] == 0)
            _showUpdateButton = true;
        } else if (_battleFieldState.fleet.getYetShips()[value] != 0)
          _radioShipOrdinal = value;
      });

  void finish() {
    _battleFieldState.update();
    eventBus.fire(StepChangerEvent(5));
  }

  @override
  Widget build(BuildContext context) {
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
                          child: Text("reSet"), onPressed: () {} //reSet,
                          ),
                      OutlineButton(
                        child: Text("upDate"),
                        onPressed: finish,
                      )
                    ],
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
                            child: SizedBox(
                                width: MediaQuery.of(context).size.height /
                                    _globalAdjustmentCoefficient,
                                height: MediaQuery.of(context).size.height /
                                    _globalAdjustmentCoefficient,
                                child: Icon(
                                  ToolRefer.iconDataList[_battleFieldState
                                      .getCell(posX, posY)
                                      .getOnThisInNumber()],
                                  color: ToolRefer.iconColorList[
                                      _battleFieldState
                                          .getCell(posX, posY)
                                          .getOnThisInNumber()],
                                  size: MediaQuery.of(context).size.height /
                                      _globalAdjustmentCoefficient,
                                )),
                            onTap: () {
                              _radioLocked = true;
                              _radioLocked = _battleFieldState.tap(
                                  posX, posY, _radioShipOrdinal);
                              handleRedioValueChanged(10);
                              this.setState(() {});
                            },
                            onLongPress:
                                /*_battleFieldState.longPress(
                              x, y, _radioShipOrdinal),*/
                                () {});
                      }),
                    ),
                  );
                }),
              ),
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
                      Text(ToolRefer.shipTypeNameList[shipOrdinal]),
                      Text(_battleFieldState.fleet.getYetShips()[shipOrdinal].toString())
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
