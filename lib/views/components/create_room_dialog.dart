import 'package:chameleon/view_models/create_room_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

showCreateRoomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const CreateRoomDialog();
    },
  );
}

class CreateRoomDialog extends StatelessWidget {
  const CreateRoomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateRoomViewModel(),
      child: Consumer<CreateRoomViewModel>(
        builder: (context, viewModel, child) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Criar Sala'),
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
                    controller: viewModel.playersController,
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
                  if (viewModel.isLoading) return;

                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  viewModel.createRoom(context);
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
                    : const Text('Criar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
