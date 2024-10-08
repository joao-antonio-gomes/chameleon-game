import 'package:chameleon/screens/components/snack_bar.dart';
import 'package:chameleon/screens/room_screen.dart';
import 'package:flutter/material.dart';

import '../../services/room_service.dart';

showEnterRoomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const EnterRoomDialog();
    },
  );
}

class EnterRoomDialog extends StatefulWidget {
  const EnterRoomDialog({super.key});

  @override
  State<EnterRoomDialog> createState() => _EnterRoomDialogState();
}

class _EnterRoomDialogState extends State<EnterRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roomId = TextEditingController();

  final RoomService _roomService = RoomService();

  bool isLoading = false;

  setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Entrar na sala'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (isLoading) return;

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _roomId,
              decoration: const InputDecoration(
                labelText: 'Digite o código da sala',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o código da sala';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (isLoading) return;

            Navigator.of(context).pop(); // Fecha o diálogo
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            enterRoom(context);
          },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Entrar'),
        ),
      ],
    );
  }

  void enterRoom(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);

    _roomService.enterRoom(_roomId.text).then((room) {
      if (context.mounted) Navigator.of(context).pop(); // Fecha o diálogo
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RoomScreen(roomId: room!.id),
        ),
      );
    }).catchError((error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          showSnackBar(
            context: context,
            message: error.toString(),
            isError: true,
          ),
        );
      }
      setLoading(false);
    }).whenComplete(() {
      setLoading(false);
    });
  }
}
