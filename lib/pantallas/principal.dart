import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_team_odaa/pantallas/login.dart';

class principal extends StatefulWidget {
  final String email;

  const principal({Key? key, required this.email}) : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<principal> {
  late Timer _timer;
  static const int _inactiveTimeInSeconds = 180; // 3 minutos en segundos

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: _inactiveTimeInSeconds), (timer) {
      _logoutUser();
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  void _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // Eliminar todas las rutas en el historial
    );
  }

  @override
  void didUpdateWidget(covariant principal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFAA405B), Color(0xFF441A24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    'Bienvenido ${widget.email}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // Contenedor tipo carta y botones
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Contenedor tipo carta
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *
                      0.75, // Ajustar la altura de la tipo carta
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(120),
                      topRight: Radius.circular(120),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Título',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            'Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta Contenido de la carta ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Contenedor para los botones
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *
                      0.08, // Ajustar altura del contenedor de botones
                  color: const Color.fromARGB(
                      255, 0, 5, 8), // Fondo azul para los botones
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFAA405B), Color(0xFF441A24)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.home, color: Colors.white),
                            label: Text('Inicio',
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFAA405B), Color(0xFF441A24)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.add, color: Colors.white),
                            label: Text('Agregar',
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFAA405B), Color(0xFF441A24)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmar Salida'),
                                    content: Text(
                                        '¿Estás seguro de que deseas cerrar sesión?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Cancelar',
                                          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Aceptar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Cerrar el diálogo de confirmación
                                          _timer
                                              .cancel(); // Cancelar el temporizador antes de salir
                                          _logoutUser(); // Cerrar sesión manualmente
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.exit_to_app, color: Colors.white),
                            label: Text('Salir',
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
