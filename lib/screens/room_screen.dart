import 'package:chameleon/models/room.dart';
import 'package:chameleon/screens/router_screen.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';

class RoomScreen extends StatefulWidget {
  final Room room;

  const RoomScreen({super.key, required this.room});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return ScreenRouter(
      title: 'Sala de ${widget.room.creator!.displayName}',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sala: ${widget.room}'),
          ],
        ),
      ),
    );
  }
}
