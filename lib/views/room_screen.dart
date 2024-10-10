// lib/views/room/room_screen.dart

import 'package:chameleon/models/app_user.dart';
import 'package:chameleon/models/room_status.dart';
import 'package:chameleon/view_models/room_view_model.dart';
import 'package:chameleon/views/components/snack_bar.dart';
import 'package:chameleon/views/components/toggleable_text.dart';
import 'package:chameleon/views/home_screen.dart';
import 'package:chameleon/views/router_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomScreen extends StatelessWidget {
  final String roomId;

  const RoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomViewModel(roomId: roomId),
      child: Consumer<RoomViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.room == null) {
            // Sala não existe ou foi deletada
            return HomeScreen();
          }

          // Verificar se o usuário está na sala
          if (!viewModel.room!.players
              .contains(FirebaseAuth.instance.currentUser!.uid)) {
            return HomeScreen();
          }

          return _buildRoomScreen(context, viewModel);
        },
      ),
    );
  }

  Widget _buildRoomScreen(BuildContext context, RoomViewModel viewModel) {
    final room = viewModel.room!;
    final players = viewModel.players;

    return ScreenRouter(
      title: 'Sala de ${room.creator.displayName}',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  'Código da sala:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Text(
                room.id,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await viewModel.copyRoomCodeToClipboard(context);
                },
                child: const Text('Copiar código'),
              ),
              Visibility(
                visible: room.maxPlayers == room.players.length,
                child: const Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Sala cheia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Jogadores na sala:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: players.isEmpty
                    ? const Text('Nenhum jogador na sala')
                    : ListView.builder(
                        itemCount: players.values.length,
                        itemBuilder: (context, index) {
                          AppUser player = players.values.elementAt(index);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: player.photoURL != null
                                  ? NetworkImage(player.photoURL!)
                                  : null,
                              child: player.photoURL == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(player.displayName),
                          );
                        },
                      ),
              ),
              Visibility(
                visible: room.creator.uid ==
                        FirebaseAuth.instance.currentUser!.uid &&
                    room.players.length > 1,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await viewModel.startGame();
                    } catch (e) {
                      if (context.mounted) {
                        showSnackBar(
                          context: context,
                          message: 'Erro ao iniciar partida: $e',
                        );
                      }
                    }
                  },
                  child: viewModel.isLoadingNewGame
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(room.status != RoomStatus.playing
                          ? 'Iniciar partida'
                          : 'Nova partida'),
                ),
              ),
              const SizedBox(height: 40),
              Visibility(
                visible: viewModel.isGameStarting,
                child: const Text(
                  'Uma nova partida está iniciando',
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ),
              const SizedBox(height: 40),
              Visibility(
                visible: room.status == RoomStatus.playing &&
                    room.currentTheme != null,
                child: ToggleableText(
                  style: const TextStyle(fontSize: 18),
                  text: room.currentChameleon ==
                          FirebaseAuth.instance.currentUser!.uid
                      ? 'Você é o Camaleão'
                      : 'O tema é ${room.currentTheme}',
                  obscureInitially: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await viewModel.exitRoom();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                          );
                        },
                        child: const Text('Sair da sala'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
