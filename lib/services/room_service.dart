import 'package:chameleon/exception/business_exception.dart';
import 'package:chameleon/models/app_user.dart';
import 'package:chameleon/views/components/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/chameleon_open_ai.dart';
import '../models/room.dart';
import '../models/room_status.dart';
import 'open_ai_service.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _fireauth = FirebaseAuth.instance;

  Future<Room?> createRoom(
      {required BuildContext context, required int maxPlayers}) async {
    User? currentUser = _fireauth.currentUser;

    Room? room;

    if (currentUser != null) {
      AppUser creatorAppUser = AppUser.fromFirebaseUser(currentUser);

      room = Room(
        id: const Uuid().v4(),
        creator: creatorAppUser,
        players: [creatorAppUser.uid],
        maxPlayers: maxPlayers,
      );

      await _firestore.collection('rooms').doc(room.id).set(room.toJson());

      if (context.mounted) {
        showSnackBar(
            context: context,
            message: 'Sala criada com sucesso!',
            isError: false);
      }
    } else {
      showSnackBar(context: context, message: 'Usuário não autenticado!');
      return null;
    }

    return room;
  }

  Future<Room?> checkIfUserInRoom() async {
    User? currentUser = _fireauth.currentUser;

    if (currentUser != null) {
      final notAllowedRoomStatus = [
        RoomStatus.closed.index,
        RoomStatus.full.index
      ];

      QuerySnapshot snapshot = await _firestore
          .collection('rooms')
          .where('players', arrayContains: currentUser.uid)
          .where('status',
              whereNotIn: notAllowedRoomStatus) // Status de sala ativa
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Room.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        return null; // Sem sala ativa
      }
    }

    // Se o usuário não estiver logado ou se algo falhar, retorna null
    return null;
  }

  Future<Room?> enterRoom(String text) async {
    User? currentUser = _fireauth.currentUser;

    if (currentUser != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('rooms').doc(text).get();

      if (snapshot.exists) {
        Room room = Room.fromJson(snapshot.data() as Map<String, dynamic>);
        if (room.players.length < room.maxPlayers) {
          room.players.add(currentUser.uid);

          await _firestore
              .collection('rooms')
              .doc(room.id)
              .update(room.toJson());

          return room;
        } else {
          throw BusinessException('Não é possível entrar, a sala está cheia');
        }
      } else {
        throw BusinessException('Sala não encontrada');
      }
    }

    return null;
  }

  startGame(Room room) async {
    room.startGame();

    await OpenAIService().startGame(room).then((value) {
      final chameleonOpenAi = ChameleonOpenAi.fromJson(value);
      room.setTheme(chameleonOpenAi.theme);
      room.threadId = chameleonOpenAi.thread;
      _firestore.collection('rooms').doc(room.id).update(room.toJson());
    });
  }
}
