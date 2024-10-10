import 'dart:async';

import 'package:chameleon/models/room_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_user.dart';
import '../models/room.dart';
import '../services/room_service.dart';

class RoomViewModel extends ChangeNotifier {
  final String roomId;
  final RoomService _roomService = RoomService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Room? _room;

  Room? get room => _room;

  bool _isLoadingNewGame = false;

  bool get isLoadingNewGame => _isLoadingNewGame;

  List<String> _previousPlayerIds = [];
  Map<String, AppUser> _players = {};

  Map<String, AppUser> get players => _players;

  bool get isGameStarting => _room?.status == RoomStatus.starting;

  StreamSubscription<DocumentSnapshot>? _roomSubscription;

  RoomViewModel({required this.roomId}) {
    _listenToRoomChanges();
  }

  void _listenToRoomChanges() {
    _roomSubscription = _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _room = Room.fromJson(snapshot.data() as Map<String, dynamic>);
        _updatePlayers(_room!.players);
        notifyListeners();
      } else {
        _room = null;
        notifyListeners();
      }
    });
  }

  void _updatePlayers(List<String> currentPlayerIds) {
    _checkForPlayerChanges(currentPlayerIds);
    _updatePlayersInfo(currentPlayerIds);
  }

  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  Future<void> startGame() async {
    if (_isLoadingNewGame) return;
    _isLoadingNewGame = true;
    notifyListeners();

    try {
      await _roomService.setupGame(_room!);
      await _roomService.startGame(_room!);
    } catch (e) {
      rethrow;
    } finally {
      await _roomService.resetGame(_room!);
      _isLoadingNewGame = false;
      notifyListeners();
    }
  }

  Future<void> exitRoom() async {
    var uidExitingPlayer = FirebaseAuth.instance.currentUser!.uid;

    await _firestore.collection('rooms').doc(roomId).update({
      'players': FieldValue.arrayRemove([uidExitingPlayer])
    });

    if (_room!.players.isEmpty) {
      await _firestore.collection('rooms').doc(roomId).delete();
      return;
    }

    if (_room!.creator.uid == uidExitingPlayer) {
      var randomPlayerId = _room!.players.firstWhere(
        (playerId) => playerId != uidExitingPlayer,
        orElse: () => '',
      );
      var newCreator = await _getUserInfo(randomPlayerId);
      await _firestore.collection('rooms').doc(roomId).update({
        'creator': newCreator.toJson(),
      });
    }
  }

  void _checkForPlayerChanges(List<String> currentPlayerIds) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (_previousPlayerIds.isNotEmpty) {
      List<String> newPlayerIds = currentPlayerIds
          .where(
              (id) => !_previousPlayerIds.contains(id) && id != currentUserId)
          .toList();

      List<String> leftPlayerIds = _previousPlayerIds
          .where((id) => !currentPlayerIds.contains(id) && id != currentUserId)
          .toList();

      if (newPlayerIds.isNotEmpty) {
        for (String newPlayerId in newPlayerIds) {
          _getUserInfo(newPlayerId).then((newPlayer) {});
        }
      }

      if (leftPlayerIds.isNotEmpty) {
        for (String leftPlayerId in leftPlayerIds) {
          _getUserInfo(leftPlayerId).then((leftPlayer) {});
        }
      }
    }

    _previousPlayerIds = List.from(currentPlayerIds);
  }

  Future<void> _updatePlayersInfo(List<String> currentPlayerIds) async {
    List<String> newPlayerIds =
        currentPlayerIds.where((id) => !_players.containsKey(id)).toList();

    if (newPlayerIds.isNotEmpty) {
      List<AppUser> newPlayers = await _getPlayersInfo(newPlayerIds);
      for (AppUser player in newPlayers) {
        _players[player.uid] = player;
      }
      notifyListeners();
    }

    List<String> leftPlayerIds =
        _players.keys.where((id) => !currentPlayerIds.contains(id)).toList();
    if (leftPlayerIds.isNotEmpty) {
      for (String id in leftPlayerIds) {
        _players.remove(id);
      }
      notifyListeners();
    }
  }

  Future<List<AppUser>> _getPlayersInfo(List<String> playerIds) async {
    if (playerIds.isEmpty) return [];

    final batches = <Future<QuerySnapshot>>[];
    const batchSize = 10;

    for (var i = 0; i < playerIds.length; i += batchSize) {
      final batchIds = playerIds.sublist(
        i,
        i + batchSize > playerIds.length ? playerIds.length : i + batchSize,
      );

      final query = _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      batches.add(query);
    }

    final results = await Future.wait(batches);

    final users = results.expand((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      });
    }).toList();

    return users;
  }

  Future<AppUser> _getUserInfo(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    return AppUser.fromJson(userDoc.data() as Map<String, dynamic>);
  }

  Future<void> copyRoomCodeToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _room!.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência'),
      ),
    );
  }
}
