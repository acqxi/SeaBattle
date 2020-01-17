import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/main.dart';

class ToolRefer {
  static const shipTypeNameList = ["CV", "BB", "CA", "CL", "DD"];
  static const shipStateNameList = ["yet", "intact", "deform", "wrecked"];
  static const shipBodyStateNameList = ["intact","deform", "wrecked"];
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
    "DD": 7,
    "deform":8,
    "wreck":9
  };
  static const List<String> boardCellTypeListI2S = [
    "default",
    "stop",
    "can",
    "CV",
    "BB",
    "CA",
    "CL",
    "DD",
    "deform",
    "wreck",
  ];
  static const iconDataList = [
    Icons.crop_free,
    Icons.block,
    Icons.add,
    Icons.format_clear,
    Icons.send,
    Icons.arrow_forward_ios,
    Icons.last_page,
    Icons.keyboard_arrow_right,
    Icons.clear,
    Icons.more_vert
  ]; //default stop can CV BB CA CL DD
  static const iconColorList = [
    Colors.grey,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.blueGrey,
    Colors.indigo,
    Colors.teal,
    Colors.blueAccent,
    Colors.red,
    Colors.red
  ]; //default stop can CV BB CA CL DD
  static const iconDataListMe = [
    Icons.arrow_right,
    Icons.arrow_right,
    Icons.add,
    Icons.format_clear,
    Icons.send,
    Icons.arrow_forward_ios,
    Icons.last_page,
    Icons.keyboard_arrow_right,
    Icons.clear,
    Icons.more_vert
  ]; //default stop can CV BB CA CL DD
  static const iconColorListMe = [
    Colors.grey,
    Colors.grey,
    Colors.green,
    Colors.orange,
    Colors.blueGrey,
    Colors.indigo,
    Colors.teal,
    Colors.blueAccent,
    Colors.red,
    Colors.red
  ]; //default stop can CV BB CA CL DD
  static const iconDataListTa = [
    Icons.crop_free,
    Icons.crop_free,
    Icons.add,
    Icons.layers_clear,
    Icons.more,
    Icons.arrow_back_ios,
    Icons.first_page,
    Icons.arrow_left,
    Icons.clear,
    Icons.more_vert
  ];
  static const iconColorListTa = [
    Colors.grey,
    Colors.grey,
    Colors.green,
    Colors.orange,
    Colors.blueGrey,
    Colors.indigo,
    Colors.teal,
    Colors.blueAccent,
    Colors.red,
    Colors.red
  ];
  static const ascii = {
    0: 'A',
    1: 'B',
    2: 'C',
    3: 'D',
    4: 'E',
    5: 'F',
    6: 'G',
    7: 'H',
    8: 'I',
    9: 'J',
    10: 'K',
    11: 'L',
    12: 'M',
    13: 'N',
    14: 'O',
    15: 'P',
    16: 'Q'
  };
  static const asciiConvert = {
     'A':0,
     'B':1,
     'C':2,
     'D':3,
     'E':4,
     'F':5,
     'G':6,
     'H':7,
     'I':8,
     'J':9,
     'K':10,
     'L':11,
     'M':12,
     'N':13,
     'O':14,
     'P':15,
     'Q':16
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

class LockCheck{
  List<bool> lockFinish;
  LockCheck([this.lockFinish = const [true,true,true,true]]);

  bool isAllTrue(){
    for(bool b in lockFinish){
      if(!b) return false;
    }return true;
  }
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

  beingAttack([String s,String turn,LockCheck lock,int lockNumber = -1]) { 
    shipBodyState=1;
    fireBaseDB.child("Battle/$turn").update({"$s": "${ToolRefer.ascii[8+shipBodPosition.x]+ToolRefer.ascii[shipBodPosition.y]}"}).whenComplete(() {
        print("attack ${ToolRefer.ascii[8+shipBodPosition.x]+ToolRefer.ascii[shipBodPosition.y]} ${ToolRefer.shipTypeNameList[shipType]}$shipName @ ${toolReferFunc.posAddOXY(shipBodPosition, 8, 0)}");
        if(lockNumber != -1) lock.lockFinish[lockNumber] = true;
      }).catchError((error) {
        print(error);
      });      
      print("beingAttack function end");
  }

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

  bool isDefault() => onThisBoardCellItem == "default";
  bool isGreen() => onThisBoardCellItem == "can";

  int getOnThisInNumber() => ToolRefer.boardCellTypeMapS2I[onThisBoardCellItem];
  @override
  String toString() =>
      "{ pos : $boardCellPosition , $onThisBoardCellItem , \n${onThisBoardCellShipBody ?? "notShip"}}";
}
