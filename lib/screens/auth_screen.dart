import 'package:chameleon/exception/business_exception.dart';
import 'package:chameleon/screens/components/snack_bar.dart';
import 'package:chameleon/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'utils/my_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _wantToRegister = false;
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _toggleRegister() {
    setState(() {
      _wantToRegister = !_wantToRegister;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MyColors.topGradient,
                  MyColors.bottomGradient,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        "assets/images/logo_1.png",
                        height: 200,
                      ),
                      const Text(
                        "Camaleão",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.black),
                        decoration: getAuthenticationInputDecoration("E-mail"),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return "E-mail é obrigatório";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.black),
                        decoration: getAuthenticationInputDecoration("Senha"),
                        obscureText: true,
                      ),
                      Visibility(
                        visible: _wantToRegister,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              style: const TextStyle(color: Colors.black),
                              decoration: getAuthenticationInputDecoration(
                                  "Confirme a senha"),
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.black),
                              decoration:
                                  getAuthenticationInputDecoration("Nome"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: submit,
                        child: Text(_wantToRegister ? "Cadastrar" : "Entrar"),
                      ),
                      const Divider(
                        color: Colors.white,
                        height: 32,
                      ),
                      TextButton(
                        onPressed: _toggleRegister,
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.white),
                        child: Text(_wantToRegister
                            ? "Já tem uma conta? Entre"
                            : "Ainda não tem uma conta? Cadastre-se"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  submit() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;

    if (_formKey.currentState!.validate()) {
      if (_wantToRegister) {
        await signUp(name, email, password);
      } else {
        await signIn(email, password);
      }

      return;
    }

    // TODO: melhorar validações
    print("Formulário inválido");
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signIn(email: email, password: password);

      Navigator.of(context).pushReplacementNamed("/home");
    } on BusinessException catch (e) {
      showSnackBar(context: context, message: e.message);
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      await _authService.signUp(name: name, email: email, password: password);

      Navigator.of(context).pushReplacementNamed("/home");
    } on BusinessException catch (e) {
      showSnackBar(context: context, message: e.message);
    }
  }

  InputDecoration getAuthenticationInputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}
