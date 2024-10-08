import 'package:chameleon/exception/business_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  signUp(
      {required String name,
      required String email,
      required String password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      await user!.updateDisplayName(name);

      // Salva os dados do usuário na coleção 'users' do Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': name,
        'photoURL': user.photoURL,
        // Outros dados que desejar
      });
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
