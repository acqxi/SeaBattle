import 'dart:math';
import 'package:sea_battle_nutn/basic_class.dart';
import 'package:sea_battle_nutn/main.dart';

class Ship {
  final int shipType;
  final int _shipOwner;

  int _shipName;

  TwoPosition _sHTPos; //shipHeadAndTailPosition
  int _shipState;
  String damagedPart = "";
  List<ShipBody> _shipBodys = [];

  Ship(this._shipOwner, this.shipType,
      [this._shipName = 0,
      this._sHTPos = const TwoPosition(),
      this._shipState = 0]);

  TwoPosition getShipPosition() => _sHTPos;
  String getShipTypeName() => ToolRefer.shipTypeNameList[shipType];
  String getShipStateName() => ToolRefer.shipStateNameList[_shipState];
  int getShipPower() => ToolRefer.shipPower[shipType];
  int getShipName() => _shipName;
  int getShipState() => _shipState;
  String getDamagedPartString() {
    checkDamage();
    return damagedPart == "" ? "intact" : damagedPart;
  }

  bool isDD() => shipType == 4 ? true : false;
  bool isCV() => shipType == 0 ? true : false;
  bool isIntact() => _shipState == 1 ? true : false;
  bool isYet() => _shipState == 0 ? true : false;
  bool isWrecked() => _shipState == 3 ? true : false;

  void die(String s, String turn) {
    String str = ({"CV": "V", "DD": "D"}[getShipTypeName()] ?? "B") +
        (ToolRefer.ascii[_sHTPos.pos1.x + 8] ?? "Z") +
        (ToolRefer.ascii[_sHTPos.pos1.y] ?? "Z") +
        (ToolRefer.ascii[_sHTPos.pos2.x + 8] ?? "Z") +
        (ToolRefer.ascii[_sHTPos.pos2.y] ?? "Z");

    fireBaseDB
        .child("Battle/$turn")
        .update({"L": "$str"})
        .whenComplete(() => print("die $str"))
        .catchError((error) => print(error));
  }

  void setName(int name) => _shipName = name;
  TwoPosition setPosition(TwoPosition newPosition) => _sHTPos = newPosition;
  int changeShipState(int newShipState) => _shipState = newShipState;

  void checkDamage() {
    damagedPart = "";
    print("in checkDamage shipbodys num : ${getBody()}");
    if (_shipBodys.length == 0 && _shipState == 0) {
      _shipState = 0;
      print("set ${getShipTypeName()}${getShipName()} to 0");
    } else {
      if (_shipBodys.length == 0)
        print("error");
      else {
        print("start check");
        _shipBodys.forEach((shipBody) => damagedPart +=
            (shipBody.shipBodyState == 0) ? "" : "${shipBody.shipBododyPart}");
        _shipState = damagedPart == ""
            ? 1
            : (damagedPart == "0123".substring(0, ToolRefer.shipPower[shipType])
                ? 3
                : 2);
      }
    }
    if (_shipState == 3) {
      _shipBodys.forEach((shipBody) => shipBody.shipBodyState = 2);
    }
    print("checkDamage\n${this.damagedPart}\n${getShipStateName()}");
  }

  bool moveShip(String directionString, int displacement) {
    //noCheck
    var directionType = ToolRefer.directionString.indexOf(directionString);
    if (directionType == -1 || _shipState != 1) return false;
    var changedX1 = _sHTPos.pos1.x +
        ToolRefer.directionInt[directionType][0] * displacement;
    var changedY1 = _sHTPos.pos1.y +
        ToolRefer.directionInt[directionType][1] * displacement;
    var changedX2 = _sHTPos.pos2.x +
        ToolRefer.directionInt[directionType][0] * displacement;
    var changedY2 = _sHTPos.pos2.y +
        ToolRefer.directionInt[directionType][1] * displacement;
    if (toolReferFunc.isOutsiderOfHalfBoardInt(changedX1, changedY1) ||
        toolReferFunc.isOutsiderOfHalfBoardInt(changedX2, changedY2))
      return false;
    _sHTPos = new TwoPosition(SinglePosition(changedX1, changedY1),
        SinglePosition(changedX2, changedY2));
    return true;
  }

  List<SinglePosition> getPossibleTail() {
    var x = _sHTPos.pos1.x, y = _sHTPos.pos1.y;
    List<SinglePosition> result = [];
    print("now at $x , $y Start find PossibleTail");
    if (this.isCV()) {
      for (var d in ToolRefer.directionInt.sublist(4))
        if (!(toolReferFunc.isOutsiderOfHalfBoardInt(x + d[0], y + d[1])))
          result.add(SinglePosition(x + d[0], y + d[1]));
    } else
      for (var d in ToolRefer.directionInt)
        if (!(toolReferFunc.isOutsiderOfHalfBoardInt(
            x + d[0] * (ToolRefer.shipPower[shipType] - 1),
            y + d[1] * (ToolRefer.shipPower[shipType] - 1))))
          result.add(SinglePosition(
              x + d[0] * (ToolRefer.shipPower[shipType] - 1),
              y + d[1] * (ToolRefer.shipPower[shipType] - 1)));

    print("finish find passible path");
    return result;
  }

  ShipBody getBody({int part = 0}) =>
      _shipBodys.length == 0 ? null : _shipBodys[part];

  List<ShipBody> getBodys({bool reGet = false}) {
    if (_shipBodys.length == 0 || reGet) {
      if (isDD())
        _shipBodys
            .add(ShipBody(_shipOwner, shipType, _shipName, _sHTPos.pos1, 0));
      else if (isCV()) {
        [
          _sHTPos.pos1,
          SinglePosition(_sHTPos.pos2.x, _sHTPos.pos1.y),
          SinglePosition(_sHTPos.pos1.x, _sHTPos.pos2.y),
          _sHTPos.pos2
        ].asMap().forEach((index, pos) => _shipBodys
            .add(ShipBody(_shipOwner, shipType, _shipName, pos, index)));
      } else {
        var dx = _sHTPos.pos2.x - _sHTPos.pos1.x;
        var dy = _sHTPos.pos2.y - _sHTPos.pos1.y;
        var l = max(dx.abs(), dy.abs());
        for (int i = 0; i <= l; i++)
          _shipBodys.add(ShipBody(
              _shipOwner,
              shipType,
              _shipName,
              toolReferFunc.posAddOXY(
                  _sHTPos.pos1, i * (dx ~/ l), i * (dy ~/ l)),
              i));
      }
    }
    return _shipBodys;
  }

  List<SinglePosition> getPossibleBodysPos(int x, int y) {
    List<SinglePosition> possibleBodysPos = [];
    if (isCV()) {
      [
        _sHTPos.pos1,
        SinglePosition(x, _sHTPos.pos1.y),
        SinglePosition(_sHTPos.pos1.x, y),
        SinglePosition(x, y)
      ].forEach((pos) => possibleBodysPos.add(pos));
    } else {
      var dx = x - _sHTPos.pos1.x;
      var dy = y - _sHTPos.pos1.y;
      var l = max(dx.abs(), dy.abs());
      for (int i = 0; i <= l; i++)
        possibleBodysPos.add(SinglePosition(
            _sHTPos.pos1.x + i * (dx ~/ l), _sHTPos.pos1.y + i * (dy ~/ l)));
    }
    return possibleBodysPos;
  }

  @override
  String toString() =>
      "ship : ${getShipTypeName() + getShipName().toString()} is ${ToolRefer.shipStateNameList[_shipState]}\n\tshipPos : ${getShipPosition()}\n\tDamaged : ${getDamagedPartString()}\n";
}
