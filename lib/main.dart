import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_team_odaa/pantallas/login.dart';
import 'package:flutter_team_odaa/pantallas/principal.dart';
import 'package:flutter_team_odaa/session/NavigatorObserver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Asegúrate de que Firebase está inicializado
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [InactivityObserver()],
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Muestra un indicador de carga mientras se espera la conexión
        }
        if (snapshot.hasData) {
          User? user = snapshot.data;
          String displayName = user?.displayName ?? user?.email ?? 'Usuario';
          String userId = user?.uid ?? ''; // Obtener el ID del usuario
          return Principal(
            email: displayName, // Pasar el nombre del usuario o correo electrónico
            userId: userId, // Pasar el ID del usuario
          );
        }
        return LoginScreen(); // Redirige a la pantalla de inicio de sesión si el usuario no está autenticado
      },
    );
  }
}