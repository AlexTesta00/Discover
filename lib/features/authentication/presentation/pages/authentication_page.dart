import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/pages/register_page.dart';
import 'package:discover/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {

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

    final result = await signInWithEmailPassword(email, password).run();

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
            const SnackBar(content: Text('Login effettuato con successo')),
          );
        }
      },
    );
  }

  void loginWithGoogle() async {
    final webClientId = dotenv.env['WEB_CLIENT_ID'] ?? '';
    final iosClientId = dotenv.env['IOS_CLIENT_ID'] ?? '';
    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
      clientId: iosClientId,
    );
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login con Google annullato')),
      );
      return;
    }

    final googleAuth = await googleUser.authentication;  
    final accessToken = googleAuth.accessToken;  
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No Acess Token found.')),
          );
      return;
    }  
    
    if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No ID Token found.')),
      );
      return;
    }

    final result = await signInWithGoogle(idToken, accessToken).run();

    result.match(
      (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      },
      (response) async {
        if (!mounted) return;

        final session = response.session ?? Supabase.instance.client.auth.currentSession;

        if (session != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
            (_) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Google eseguito, ma nessuna sessione attiva.')),
          );
        }
      },
    );
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
          Row(
            children: [
              Expanded(child: Divider(thickness: 1)),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), 
              child: Text(' Oppure '),
              ),
              Expanded(child: Divider(thickness: 1)),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: loginWithGoogle,
            icon: Image.asset(
              'assets/icons/google_logo.png', // Assicurati di avere l'immagine nel percorso corretto
              height: 24,
              width: 24,
            ),
            label: const Text(
              'Continua con Google',
              style: TextStyle(color: Colors.black),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
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