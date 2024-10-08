import 'package:chameleon/screens/components/snack_bar.dart';
import 'package:flutter/material.dart';

import '../../services/room_service.dart';
import '../room_screen.dart';

showCreateRoomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const CreateRoomDialog();
    },
  );
}

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _playersController =
      TextEditingController(text: '4');

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
          const Text('Criar Sala'),
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
              controller: _playersController,
              decoration: const InputDecoration(
                labelText: 'Quantidade de jogadores',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a quantidade de jogadores';
                }
                final intPlayers = int.tryParse(value);
                if (intPlayers == null || intPlayers < 4) {
                  return 'A quantidade de jogadores deve ser no mínimo 4';
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
            createRoom(context);
          },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Criar'),
        ),
      ],
    );
  }

  void createRoom(BuildContext context) {
    if (_formKey.currentState!.validate() && mounted) {
      _roomService
          .createRoom(
        context: context,
        maxPlayers: int.parse(_playersController.text),
      )
          .then((value) {
        if (context.mounted) {
          Navigator.of(context).pop();

          Navigator.of(context).pushReplacement(
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
