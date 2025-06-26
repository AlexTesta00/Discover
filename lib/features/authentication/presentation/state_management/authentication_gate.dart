import 'package:discover/features/authentication/presentation/pages/authentication_page.dart';
import 'package:discover/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationGate extends StatelessWidget {
  const AuthenticationGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if(session != null){
          return const DashboardPage();
        } else {
          return const AuthenticationPage();
        }
      },
    );
  }
}