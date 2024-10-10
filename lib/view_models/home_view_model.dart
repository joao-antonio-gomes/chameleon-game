import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/room_service.dart';

class HomeViewModel extends ChangeNotifier {
  final RoomService _roomService = RoomService();
  Room? _currentRoom;
  bool _isLoading = true;

  Room? get currentRoom => _currentRoom;
  bool get inRoom => _currentRoom != null;
  bool get isLoading => _isLoading;

  HomeViewModel() {
    checkIfUserInRoom();
  }

  Future<void> checkIfUserInRoom() async {
    _currentRoom = await _roomService.checkIfUserInRoom();
    _isLoading = false;
    notifyListeners();
  }
}
