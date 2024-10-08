import 'package:chameleon/models/room.dart';
import 'package:chameleon/screens/components/snack_bar.dart';
import 'package:chameleon/screens/home_screen.dart';
import 'package:chameleon/screens/router_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_user.dart';

class RoomScreen extends StatefulWidget {
  final String roomId; // Passar o roomId em vez do objeto Room

  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  List<String> _previousPlayerIds = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Carregando...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBar(context: context, message: 'Sala não encontrada');
          });
          return const HomeScreen();
        }

        // Converter o documento em um objeto Room
        Room room =
            Room.fromJson(snapshot.data!.data() as Map<String, dynamic>);
        List<String> currentPlayerIds = room.players;

        // Agendar a comparação após o frame atual
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkForPlayerChanges(currentPlayerIds);
        });

        // Verificar se o usuário está na sala
        if (!room.players.contains(FirebaseAuth.instance.currentUser!.uid)) {
          return const HomeScreen();
        }

        return _buildRoomScreen(context, room);
      },
    );
  }

  ScreenRouter _buildRoomScreen(BuildContext context, Room room) {
    return ScreenRouter(
      title: 'Sala de ${room.creator.displayName}',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
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
                  await _copyRoomCodeToClipboard(room, context);
                },
                child: const Text('Copiar código'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Jogadores na sala:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<AppUser>>(
                  future: _getPlayersInfo(room.players),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar jogadores');
                    }

                    List<AppUser> players = snapshot.data ?? [];

                    if (players.isEmpty) {
                      return const Text('Nenhum jogador na sala');
                    }

                    if (room.players.length < players.length) {
                      showSnackBar(
                          context: context, message: 'Jogador saiu da sala');
                    }

                    return ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        AppUser player = players[index];
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
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _exitRoom(room);
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

  Future<void> _exitRoom(Room room) async {
    await FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
      'players':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  Future<void> _copyRoomCodeToClipboard(Room room, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: room.id));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código copiado para a área de transferência'),
        ),
      );
    }
  }

  Future<List<AppUser>> _getPlayersInfo(List<String> playerIds) async {
    if (playerIds.isEmpty) return [];

    // Dividir a lista em lotes de no máximo 10 IDs
    final batches = <Future<QuerySnapshot>>[];
    const batchSize = 10;

    for (var i = 0; i < playerIds.length; i += batchSize) {
      final batchIds = playerIds.sublist(
        i,
        i + batchSize > playerIds.length ? playerIds.length : i + batchSize,
      );

      final query = FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      batches.add(query);
    }

    final results = await Future.wait(batches);

    final users = results.expand((snapshot) {
      return snapshot.docs.map((doc) {
        print(doc.data());
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      });
    }).toList();

    return users;
  }

  void _checkForPlayerChanges(List<String> currentPlayerIds) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (_previousPlayerIds.isNotEmpty) {
      // Jogadores que entraram na sala (excluindo o usuário atual)
      List<String> newPlayerIds = currentPlayerIds
          .where(
              (id) => !_previousPlayerIds.contains(id) && id != currentUserId)
          .toList();

      // Jogadores que saíram da sala (excluindo o usuário atual)
      List<String> leftPlayerIds = _previousPlayerIds
          .where((id) => !currentPlayerIds.contains(id) && id != currentUserId)
          .toList();

      if (newPlayerIds.isNotEmpty) {
        // Exibir notificação de novo jogador
        showSnackBar(
            context: context,
            message: 'Novo jogador entrou na sala',
            isError: false);
      }

      if (leftPlayerIds.isNotEmpty) {
        // Exibir notificação de jogador saiu
        showSnackBar(context: context, message: 'Jogador saiu da sala');
      }
    }

    // Atualizar a lista anterior de jogadores
    _previousPlayerIds = List.from(currentPlayerIds);
  }
}
