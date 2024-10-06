import 'package:chameleon/models/app_user.dart';
import 'package:chameleon/screens/components/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/room.dart';

class RoomService {
  Future<Room?> createRoom(
      {required BuildContext context, required int maxPlayers}) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Room? room;

    if (currentUser != null) {
      AppUser user = AppUser(
        uid: currentUser.uid,
        displayName: currentUser.displayName ?? 'Anônimo',
        email: currentUser.email ?? '',
        photoURL: currentUser.photoURL ?? '',
      );

      room = Room(
        roomId: const Uuid().v4(),
        creatorId: currentUser.uid,
        creator: user,
        players: [currentUser.uid],
        maxPlayers: maxPlayers,
      );

      await _firestore.collection('rooms').doc(room.roomId).set(room.toJson());

      showSnackBar(
          context: context,
          message: 'Sala criada com sucesso!',
          isError: false);
    } else {
      showSnackBar(context: context, message: 'Usuário não autenticado!');
      return null;
    }

    return room;
  }

  Future<Room?> checkIfUserInRoom() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('players', arrayContains: currentUser.uid)
          .where('status', isEqualTo: 0) // Status de sala ativa
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
}
