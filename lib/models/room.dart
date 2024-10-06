import 'package:chameleon/models/app_user.dart';
import 'package:chameleon/models/room_status.dart';

class Room {
  String roomId;
  String creatorId;
  AppUser creator;
  List<String> players;
  int maxPlayers;

  RoomStatus status = RoomStatus.available;

  Room({
    required this.roomId,
    required this.creatorId,
    required this.players,
    required this.creator,
    this.maxPlayers = 4,
    this.status = RoomStatus.available,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'],
      creatorId: json['creatorId'],
      creator: AppUser.fromJson(json['creator']),
      players: List<String>.from(json['players']),
      maxPlayers: json['maxPlayers'],
      status: RoomStatus.values[json['status']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'creatorId': creatorId,
      'players': players,
      'maxPlayers': maxPlayers,
      'status': status.index,
    };
  }
}
