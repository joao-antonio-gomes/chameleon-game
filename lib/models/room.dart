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

  RoomStatus status = RoomStatus.available;

  Room({
    required this.id,
    required this.players,
    required this.creator,
    this.maxPlayers = 4,
    this.status = RoomStatus.available,
  });

  Room.complete({
    required this.id,
    required this.players,
    required this.creator,
    this.maxPlayers = 4,
    this.status = RoomStatus.available,
    this.currentTheme = '',
    this.currentChameleon = '',
    this.chameleonByTheme = const {},
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
    };
  }

  void setTheme(String theme) {
    currentTheme = theme;
  }

  void defineChameleon() {
    if (players.isEmpty) return;
    if (currentTheme == null) return;

    // Define randomly a player to be the chameleon
    int chameleonIndex = DateTime.now().microsecondsSinceEpoch % players.length;
    currentChameleon = players[chameleonIndex];

    chameleonByTheme![currentTheme!] = currentChameleon!;
  }

  void resetGame() {
    currentTheme = null;
    currentChameleon = null;
    chameleonByTheme = {};
  }
}
