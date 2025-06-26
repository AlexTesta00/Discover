import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {

  final authService = AuthenticationService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email e password non possono essere vuoti')),
      );
      return;
    }

    try{
      await authService.signInWithEmailPassword(email, password);
    }catch (error) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.black),),
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
          ElevatedButton(
            onPressed: login,
            child: const Text('Login'),
          ),
          const SizedBox(height: 20),
          //Go to register page
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ),
            ),
            child: 
            const Center(
              child:
              Text('Non hai un account? Registrati', 
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
          ),
        ),
      ],
      )
    );
  }
}