import 'package:chameleon/models/room.dart';
import 'package:chameleon/view_models/enter_room_view_model.dart';
import 'package:chameleon/views/room_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showEnterRoomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const EnterRoomDialog();
    },
  );
}

class EnterRoomDialog extends StatelessWidget {
  const EnterRoomDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnterRoomViewModel(),
      child: Consumer<EnterRoomViewModel>(
        builder: (context, viewModel, child) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Entrar na sala'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (viewModel.isLoading) return;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            content: Form(
              key: viewModel.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: viewModel.roomIdController,
                    decoration: const InputDecoration(
                      labelText: 'Digite o código da sala',
                    ),
                    keyboardType: TextInputType.number,
                    validator: viewModel.validateRoomId,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (viewModel.isLoading) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Room? room = await viewModel.enterRoom(context);
                  if (room != null && context.mounted) {
                    Navigator.of(context).pop(); // Fecha o diálogo
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RoomScreen(roomId: room.id),
                      ),
                    );
                  }
                },
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Entrar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
