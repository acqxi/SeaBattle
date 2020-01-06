import 'package:event_bus/event_bus.dart';

EventBus eventBus = new EventBus();

class ShipNumberUpdateEvent{
  List<int> shipNumberList;

  ShipNumberUpdateEvent(this.shipNumberList);
}

class StepChangerEvent{
  int stepOrdinal;

  StepChangerEvent(this.stepOrdinal);
}

class TurnChangerEvent{
  String turnName;

  TurnChangerEvent(this.turnName);
}