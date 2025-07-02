import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if(password != confirmPassword) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le password non corrispondono')),
        );
      }
      return;
    }

    final result = await signUpWithEmailPassword(email, password).run();

    result.match(
      (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
      (response) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrazione riuscita!')),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: const Text('Registrati', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'mario.rossi@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Digita la tua password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Conferma Password',
              hintText: 'Conferma la tua password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: signUp,
            child: const Text('Registrati'),
          ),
      ],
      )
    );
  }
}