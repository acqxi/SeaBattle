import 'dart:math';

class SinglePosition {
  final int x;
  final int y;
  const SinglePosition([this.x = 0, this.y = 0]);

  @override
  String toString() {
    // TODO: implement toString
    return "( " + x.toString() + ", " + y.toString() +" )"; 
  }
}

class TwoPosition {
  final SinglePosition position1;
  final SinglePosition position2;
  const TwoPosition(
      [this.position1 = const SinglePosition(),
      this.position2 = const SinglePosition()]);

  @override
  String toString() {
    // TODO: implement toString
    return "{ pos1 : " + position1.toString() + ", Pos2 : "+position2.toString()+"}";
  }
}

class Ship {
  final int shipType;

  final _shipPower = [6, 4, 3, 2, 1];
  final _shipTypeNameList = ["CV", "BB", "CA", "CL", "DD"];
  final _shipstateNameList = ["yet", "intact", "deform", "wrecked"];
  final _directionString = [
    "down",
    "up",
    "left",
    "right",
    "rightAndDown",
    "leftAndDown",
    "rightAndUp",
    "leftAndUp"
  ];
  final _directionInt = [
    [01, 00],
    [00, 01],
    [-1, 00],
    [00, -1],
    [01, 01],
    [01, -1],
    [-1, 01],
    [-1, -1]
  ];
  final _directionInt2String = [
    "[1, 0]",
    "[0, 1]",
    "[-1, 0]",
    "[0, -1]",
    "[1, 1]",
    "[1, -1]",
    "[-1, 1]",
    "[-1, -1]"
  ];
  final _directionCV = [
    [2, 3],
    [-2, 3],
    [2, -3],
    [-2, -3],
    [3, 2],
    [3, -2],
    [-3, 2],
    [-3, -2]
  ];

  int _name;

  TwoPosition _position;
  int _shipState;
  List<int> _damagedPart;
  List<SinglePosition> shipBody = [];

  //List<List<SinglePosition>> _torpedoPossiblePath;

  Ship(this.shipType,
      [this._position = const TwoPosition(),
      this._shipState = 0,
      this._damagedPart = const [0, 0, 0, 0, 0],
      this._name]);

  TwoPosition getPosition() => _position;
  String getShipTypeName() => _shipTypeNameList[shipType];
  String getShipStateName() => _shipstateNameList[_shipState];
  int getShipPower() => _shipPower[shipType];
  List<int> getShipPowerList() => _shipPower;
  String getDamagedPart2String() => _damagedPart.join();
  int getName() => _name;

  void setName(int n) => _name = n;

  bool isDD() => shipType == 4 ? true : false;
  bool isCV() => shipType == 0 ? true : false;
  bool isIntact() => _shipState == 1 ? true : false;
  bool isYet() => _shipState == 0 ? true : false;
  bool isWrecked() => _shipState == 3 ? true : false;

  TwoPosition setPosition(TwoPosition newPosition) => _position = newPosition;
  int changeShipState(int newShipState) => _shipState = newShipState;

  bool moveShip(String directionString, int displacement) {
    //noCheck
    var directionType = _directionString.indexOf(directionString);
    if (directionType == -1 || _shipState != 1) return false;
    var changedX1 =
        _position.position1.x + _directionInt[directionType][0] * displacement;
    var changedY1 =
        _position.position1.y + _directionInt[directionType][1] * displacement;
    var changedX2 =
        _position.position2.x + _directionInt[directionType][0] * displacement;
    var changedY2 =
        _position.position2.y + _directionInt[directionType][1] * displacement;
    if (changedX1 < 0 ||
        changedX2 < 0 ||
        changedY1 < 0 ||
        changedY2 < 0 ||
        changedX1 > 7 ||
        changedX2 > 7 ||
        changedY1 > 15 ||
        changedY2 > 15) return false;
    _position = new TwoPosition(SinglePosition(changedX1, changedY1),
        SinglePosition(changedX2, changedY2));
    return true;
  }

  void ubderFire(int part) => _damagedPart[part] = 1;

  List<SinglePosition> getPossibleTail() {
    var x = _position.position1.x, y = _position.position1.y;
    List<SinglePosition> result = [];
    print("now at $x , $y Start find path");
    if (this.isCV()) {
      for (var d in _directionCV)
        if (!(x + d[0] > 8 || x + d[0] < -1 || y + d[1] > 16 || y + d[1] < -1))
          result.add(SinglePosition(
              x + d[0] - (d[0] > 0 ? 1 : -1), y + d[1] - (d[1] > 0 ? 1 : -1)));
    } else
      for (var d in _directionInt)
        if (!(x + d[0] * (_shipPower[shipType] - 1) < 0 ||
            x + d[0] * (_shipPower[shipType] - 1) > 7 ||
            y + d[1] * (_shipPower[shipType] - 1) < 0 ||
            y + d[1] * (_shipPower[shipType] - 1) > 15))
          result.add(SinglePosition(x + d[0] * (_shipPower[shipType] - 1),
              y + d[1] * (_shipPower[shipType] - 1)));

    print("finish find passible path");
    return result;
  }

  List<SinglePosition> getBody() {
    if (shipBody.length == 0) {
      if (shipType == 4)
        shipBody
            .add(SinglePosition(_position.position1.x, _position.position1.y));
      else if (shipType == 0) {
        var dx = _position.position2.x - _position.position1.x;
        var dy = _position.position2.y - _position.position1.y;
        for (int i = 0; i != dx + (dx > 0 ? 1 : -1); i += dx > 0 ? 1 : -1)
          for (int j = 0; j != dy + (dy > 0 ? 1 : -1); j += dy > 0 ? 1 : -1) {
            shipBody.add(SinglePosition(
                _position.position1.x + i, _position.position1.y + j));
            //print(                "Now add ${_position.position1.x + i} ${_position.position1.y + j} to Ship");
          }
      } else {
        var dx = _position.position2.x - _position.position1.x;
        var dy = _position.position2.y - _position.position1.y;
        var l = max(dx.abs(), dy.abs());
        String getDirection = [dx ~/ l, dy ~/ l].toString();
        var dir = _directionInt2String.indexOf(getDirection);

        for (int i = 0; i <= l; i++) {
          shipBody.add(SinglePosition(
              _position.position1.x + _directionInt[dir][0] * i,
              _position.position1.y + _directionInt[dir][1] * i));
          //print(              "Now add ${_position.position1.x + _directionInt[dir][0] * i} ${_position.position1.y + _directionInt[dir][1] * i} to Ship");
        }
      }
    }
    return shipBody;
  }

  @override
  String toString() {
    return "shipType : "+this.getShipTypeName()+"\n shipPos : "+this.getPosition().toString()+"\n Damaged : "+this.getDamagedPart2String();
  }
}
