import 'package:chameleon/exception/business_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  signUp(
      {required String name,
      required String email,
      required String password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw BusinessException('A senha é muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw BusinessException('O e-mail já está em uso');
      }

      throw BusinessException('Erro ao cadastrar usuário');
    }
  }

  signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw BusinessException('Usuário não encontrado');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw BusinessException('Usuário ou senha inválidos');
      }

      throw BusinessException('Erro ao realizar login');
    }
  }

  signOut() async {
    await _auth.signOut();
  }
}
