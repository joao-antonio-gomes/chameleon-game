import 'package:chameleon/models/app_user.dart';
import 'package:chameleon/models/room_status.dart';

class Room {
  String id;
  AppUser creator;
  List<String> players;
  int maxPlayers;
  String? currentTheme;
  String? currentChameleon;
  Map<String, String>? chameleonByTheme = {};
  String? threadId = '';

  RoomStatus status = RoomStatus.waiting;

  Room({
    required this.id,
    required this.players,
    required this.creator,
    this.maxPlayers = 4,
    this.status = RoomStatus.waiting,
  });

  Room.complete({
    required this.id,
    required this.players,
    required this.creator,
    this.maxPlayers = 4,
    this.status = RoomStatus.waiting,
    this.currentTheme = '',
    this.currentChameleon = '',
    this.chameleonByTheme = const {},
    this.threadId = '',
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room.complete(
      id: json['id'],
      creator: AppUser.fromJson(json['creator']),
      players: List<String>.from(json['players']),
      maxPlayers: json['maxPlayers'],
      status: RoomStatus.values[json['status']],
      currentTheme: json['currentTheme'],
      currentChameleon: json['currentChameleon'],
      chameleonByTheme: json['chameleonByTheme'] != null
          ? Map<String, String>.from(json['chameleonByTheme'])
          : {},
      threadId: json['threadId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'players': players,
      'maxPlayers': maxPlayers,
      'status': status.index,
      'creator': creator.toJson(),
      'currentTheme': currentTheme,
      'currentChameleon': currentChameleon,
      'chameleonByTheme': chameleonByTheme,
      'threadId': threadId,
    };
  }

  void setTheme(String theme) {
    currentTheme = theme;

    if (currentChameleon != null) {
      chameleonByTheme!
          .addEntries([MapEntry(currentTheme!, currentChameleon!)]);
    }
  }

  void setupGame() {
    currentTheme = null;
    currentChameleon = null;

    status = RoomStatus.starting;
  }

  void startGame() {
    int chameleonIndex = DateTime.now().microsecondsSinceEpoch % players.length;
    currentChameleon = players[chameleonIndex];

    status = RoomStatus.playing;
  }

  void resetGame() {
    currentTheme = null;
    currentChameleon = null;

    status = RoomStatus.waiting;
  }
}
