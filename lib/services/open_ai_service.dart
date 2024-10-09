import 'package:chameleon/exception/business_exception.dart';
import 'package:chameleon/models/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OpenAIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> startGame(Room room) async {
    _functions.useFunctionsEmulator('10.0.2.2', 5001);
    HttpsCallable callable = _functions.httpsCallable('getTheme');

    HttpsCallableResult result;
    try {
      result =
          await callable.call({'roomId': room.id, 'thread': room.threadId});
    } catch (e) {
      throw BusinessException('Não foi possível obter um tema.');
    }

    final theme = result.data['theme'];

    if (theme == null || theme.isEmpty) {
      throw BusinessException('Não foi possível obter um tema.');
    }

    // Atualizar o Firestore com o novo tema
    await _store.collection('rooms').doc(room.id).update(room.toJson());

    return result.data;
  }
}
