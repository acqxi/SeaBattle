import 'package:event_bus/event_bus.dart';
EventBus eventBus = new EventBus();

class StepChangerEvent{
  int stepOrdinal;

  StepChangerEvent(this.stepOrdinal);
}

class TurnChangerEvent{
  String turnName;

  TurnChangerEvent(this.turnName);
}


class LoadFinishEvent{
  bool loadFinish;

  LoadFinishEvent(this.loadFinish);
}