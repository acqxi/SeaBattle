class ToolRefer {
  static const shipTypeNameList = ["CV", "BB", "CA", "CL", "DD"];
  static const shipStateNameList = ["yet", "intact", "deform", "wrecked"];
  static const shipBodyStateNameList = ["intact", "wrecked"];
  static const shipPower = [4, 4, 3, 2, 1];
  static const ownerNameList = ["Start", "Sente", "Gote", "Onlooker"];
  static const directionInt = [
    [1, 0],
    [0, 1],
    [-1, 0],
    [0, -1],
    [1, 1],
    [1, -1],
    [-1, 1],
    [-1, -1]
  ];
  static const directionInt2String = [
    "[1, 0]",
    "[0, 1]",
    "[-1, 0]",
    "[0, -1]",
    "[1, 1]",
    "[1, -1]",
    "[-1, 1]",
    "[-1, -1]"
  ];
  static const directionString = [
    "down",
    "up",
    "left",
    "right",
    "rightAndDown",
    "leftAndDown",
    "rightAndUp",
    "leftAndUp"
  ];
  static const Map<String, int> boardCellTypeMapS2I = {
    "default": 0,
    "stop": 1,
    "can": 2,
    "CV": 3,
    "BB": 4,
    "CA": 5,
    "CL": 6,
    "DD": 7
  };
  bool isOutsiderOfHalfBoardInt(int x, int y) =>
      (x < 0 || y < 0 || x > 7 || y > 7) ? true : false;
  SinglePosition posAddOXY(SinglePosition ori, int addx, int addy) =>
      SinglePosition(ori.x + addx, ori.y + addy);
  const ToolRefer();
}

const toolReferFunc = ToolRefer();

class SinglePosition {
  final int x;
  final int y;
  const SinglePosition([this.x = 0, this.y = 0]);

  @override
  String toString() => "( $x , $y )";
}

class TwoPosition {
  final SinglePosition pos1;
  final SinglePosition pos2;
  const TwoPosition(
      [this.pos1 = const SinglePosition(), this.pos2 = const SinglePosition()]);

  @override
  String toString() => "{ pos1 : $pos1 , Pos2 : $pos2 }";
}

class ShipBody {
  final SinglePosition shipBodPosition;
  final int shipBododyPart;
  final int shipType;
  final int shipName;
  final int shipOwner;
  int shipBodyState;
  ShipBody(this.shipOwner, this.shipType, this.shipName, this.shipBodPosition,
      this.shipBododyPart,
      {this.shipBodyState = 0});
  beingAttack() => shipBodyState++;

  @override
  String toString() =>
      "\n{ ship : ${ToolRefer.shipTypeNameList[shipType]}$shipName.Part : $shipBododyPart,\n\tstate : ${ToolRefer.shipBodyStateNameList[shipBodyState]},\n\tpos : $shipBodPosition }";
}

class BoardCell {
  final SinglePosition boardCellPosition;
  String onThisBoardCellItem;
  ShipBody onThisBoardCellShipBody;
  BoardCell(this.boardCellPosition,
      {this.onThisBoardCellItem = "default", this.onThisBoardCellShipBody});

  @override
  String toString() =>
      "{ pos : $boardCellPosition , $onThisBoardCellItem , \n${onThisBoardCellShipBody ?? "notShip"}}";
}
