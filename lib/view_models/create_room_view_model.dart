import 'package:chameleon/views/components/snack_bar.dart';
import 'package:chameleon/views/room_screen.dart';
import 'package:flutter/material.dart';

import '../services/room_service.dart';

class CreateRoomViewModel extends ChangeNotifier {
  final RoomService _roomService = RoomService();
  final TextEditingController playersController =
      TextEditingController(text: '4');
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void createRoom(BuildContext context) {
    if (formKey.currentState!.validate()) {
      _roomService
          .createRoom(
        context: context,
        maxPlayers: int.parse(playersController.text),
      )
          .then((value) {
        if (context.mounted) {
          Navigator.of(context).pop();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomScreen(roomId: value!.id),
            ),
          );
        }
      }).catchError((e) {
        if (context.mounted) {
          showSnackBar(context: context, message: e.toString());
        }
      }).whenComplete(() {
        setLoading(false);
      });
    }
  }
}
