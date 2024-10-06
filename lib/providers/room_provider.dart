import 'package:flutter/material.dart';

class RoomProvider with ChangeNotifier {
  bool _roomCreated = false;

  bool get roomCreated => _roomCreated;

  void setRoomCreated(bool value) {
    _roomCreated = value;
    notifyListeners(); // Notifica todos os widgets que escutam essa mudança
  }
}
