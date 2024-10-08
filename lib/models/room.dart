import 'package:chameleon/models/app_user.dart';
import 'package:chameleon/models/room_status.dart';

class Room {
  String id;
  AppUser creator;
  List<String> players;
  int maxPlayers;

  RoomStatus status = RoomStatus.available;

  Room({
    required this.id,
    required this.players,
    required this.creator,
    this.maxPlayers = 4,
    this.status = RoomStatus.available,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      creator: AppUser.fromJson(json['creator']),
      players: List<String>.from(json['players']),
      maxPlayers: json['maxPlayers'],
      status: RoomStatus.values[json['status']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'players': players,
      'maxPlayers': maxPlayers,
      'status': status.index,
      'creator': creator.toJson(),
    };
  }
}
