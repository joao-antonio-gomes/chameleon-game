import 'package:chameleon/models/room.dart';
import 'package:chameleon/screens/router_screen.dart';
import 'package:chameleon/services/room_service.dart';
import 'package:flutter/material.dart';

import 'components/create_room_dialog.dart';
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

          return Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Text(
                        'Bem-vindo ao Chameleon!',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const Spacer(), // Espaço flexível entre o texto e os botões
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
                          print('TODO');
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
                                  RoomScreen(room: snapshot.data!),
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
          );
        },
      ),
    );
  }
}
