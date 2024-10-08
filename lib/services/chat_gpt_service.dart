import 'dart:math';

import 'package:chameleon/models/room.dart';

class ChatGptService {
  Future<String> generateThemes(Room room) {
    return Future.delayed(const Duration(seconds: 2), () {
      var list = ['Banana', 'Pineaple', 'Apple', 'Watermelon', 'Orange'];
      return list[Random().nextInt(list.length)];
    });
  }
}
