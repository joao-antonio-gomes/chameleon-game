// screens/home_screen.dart

import 'package:chameleon/views/room_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/home_view_model.dart';
import 'components/create_room_dialog.dart';
import 'components/enter_room_dialog.dart';
import 'router_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  // Remove RoomService from here, it's now in the ViewModel

  @override
  Widget build(BuildContext context) {
    return ScreenRouter(
      title: 'Início',
      body: ChangeNotifierProvider(
        create: (_) => HomeViewModel(),
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            bool inRoom = viewModel.inRoom;

            return Padding(
              padding: const EdgeInsets.all(25),
              child: Center(
                child: Column(
                  children: [
                    const Column(
                      children: [
                        Text(
                          'Bem-vindo ao Camaleão!',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Text(
                        'O camaleão é um jogo de adivinhação de temas.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Text(
                        'Um dos jogadores não saberá qual é o tema, os outros jogadores falarão características abstratas do tema, o camaleão também deverá falar de modo a tentar se camuflar.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const Text(
                      'No fim, os jogadores tentarão adivinhar quem é o camaleão e o camaleão tentará adivinhar qual o tema.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!inRoom)
                          ElevatedButton(
                            onPressed: () {
                              showCreateRoomDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 40)),
                            child: const Text('Criar sala'),
                          ),
                        const SizedBox(height: 10),
                        if (!inRoom)
                          ElevatedButton(
                            onPressed: () {
                              showEnterRoomDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 40)),
                            child: const Text('Entrar em uma sala'),
                          ),
                        if (inRoom)
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the active room
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RoomScreen(
                                      roomId: viewModel.currentRoom!.id),
                                ),
                              );
                            },
                            child: const Text('Ir para a Sala Ativa'),
                          ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
