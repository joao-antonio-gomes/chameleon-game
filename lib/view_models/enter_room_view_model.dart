import 'package:chameleon/models/room.dart';
import 'package:chameleon/services/room_service.dart';
import 'package:chameleon/views/components/snack_bar.dart';
import 'package:flutter/material.dart';

class EnterRoomViewModel extends ChangeNotifier {
  final RoomService _roomService = RoomService();
  final TextEditingController roomIdController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<Room?> enterRoom(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    setLoading(true);

    try {
      Room? room = await _roomService.enterRoom(roomIdController.text);
      return room;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        showSnackBar(
          context: context,
          message: error.toString(),
          isError: true,
        ),
      );
      return null;
    } finally {
      setLoading(false);
    }
  }

  String? validateRoomId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o código da sala';
    }
    return null;
  }
}
