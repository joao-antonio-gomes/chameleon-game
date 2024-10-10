import 'package:chameleon/models/room.dart';
import 'package:chameleon/screens/router_screen.dart';
import 'package:chameleon/services/room_service.dart';
import 'package:flutter/material.dart';

import 'components/create_room_dialog.dart';
import 'components/enter_room_dialog.dart';
import 'room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RoomService _roomService = RoomService();

  @override
  Widget build(BuildContext context) {
    return ScreenRouter(
      title: 'Início',
      body: FutureBuilder<Room?>(
        future: _roomService.checkIfUserInRoom(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          bool inRoom = snapshot.data != null;

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
                            // Navegar para a sala ativa
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RoomScreen(roomId: snapshot.data!.id),
                              ),
                            );
                          },
                          child: const Text('Ir para a Sala Ativa'),
                        ),
                    ],
                  ),
                  const Spacer(), // Espaço flexível após os botões
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
