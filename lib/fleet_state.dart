import 'package:flutter/material.dart';
import 'package:sea_battle_nutn/ship_state.dart';

class Fleet {
  final _shipPower = [6, 4, 3, 2, 1];

  List<List<Ship>> _fleet = [[],[],[],[],[]];

  int totalHoldingArea;

  List<int> howMuchShipFormed() =>
      List<int>.generate(5, (x) => _fleet[x].length);

  int howMuchAreaIsHeld() {
    var temp = 0;
    _fleet
        .asMap()
        .forEach((index, value) => temp += value.length * _shipPower[index]);
    return temp;
  }

  void addShip(Ship newShip)=>_fleet[newShip.shipType].add(newShip);
}
