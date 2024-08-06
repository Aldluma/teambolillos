import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_team_odaa/pantallas/agregar.dart';
import 'package:flutter_team_odaa/pantallas/datalleNota.dart';
import 'package:flutter_team_odaa/pantallas/login.dart';

class Principal extends StatefulWidget {
  final String email;
  final String userId;

  const Principal({Key? key, required this.email, required this.userId})
      : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
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
  void didUpdateWidget(covariant Principal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nota eliminada exitosamente')),
      );
    } catch (e) {
      print('Error al eliminar la nota: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la nota')),
      );
    }
  }

  void _onUserInteraction(PointerEvent details) {
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: _onUserInteraction,
        child: Stack(
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
                    padding: EdgeInsets.all(10),
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
                          'AHORROS',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 0),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('notes')
                                .where('created_by', isEqualTo: widget.userId)
                                // .orderBy('createdAt', descending: false) // Ordenar por fecha de creación en orden ascendente
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData) {
                                print("No hay datos en el stream");
                                return Center(child: Text('No tienes notas.'));
                              }
                              if (snapshot.data!.docs.isEmpty) {
                                print("No hay notas");
                                return Center(child: Text('No tienes notas.'));
                              }
                              print(
                                  "Notas recibidas: ${snapshot.data!.docs.length}");
                              for (var doc in snapshot.data!.docs) {
                                print("Nota: ${doc.id}, Datos: ${doc.data()}");
                              }
                              var notes = snapshot.data!.docs;
                              return ListView.builder(
                                itemCount: notes.length,
                                itemBuilder: (context, index) {
                                  var note = notes[index].data()
                                      as Map<String, dynamic>;
                                  String noteName =
                                      note['name'] ?? 'Sin título';
                                  String noteId =
                                      notes[index].id; // Obtén el ID de la nota

                                  return ListTile(
                                    title: Container(
                                      padding: EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        noteName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Confirmar Eliminación'),
                                                      content: Text(
                                                          '¿Estás seguro de que deseas eliminar esta nota?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text(
                                                              'Cancelar',
                                                              style: TextStyle(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      0,
                                                                      0,
                                                                      0))),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text('Aceptar',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Cerrar el diálogo de confirmación
                                                            _deleteNote(
                                                                noteId); // Eliminar la nota
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(), // Espacio entre íconos
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.info,
                                                  color: Color.fromARGB(
                                                      255, 13, 101, 173)),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NotaDetalleScreen(
                                                      noteName: noteName,
                                                      
                                                      noteId:
                                                          noteId, // Pasar el ID de la nota
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contenedor para los botones
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.08,
                    color: const Color.fromARGB(255, 0, 5, 8),
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
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotaFormScreen(
                                      userId: widget.userId,
                                      email: widget.email,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text('Agregar',
                                  style: TextStyle(color: Colors.white)),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
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
                                          child: Text('Cancelar',
                                              style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0))),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Aceptar',
                                              style:
                                                  TextStyle(color: Colors.red)),
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
                              icon:
                                  Icon(Icons.exit_to_app, color: Colors.white),
                              label: Text('Salir',
                                  style: TextStyle(color: Colors.white)),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
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
      ),
    );
  }
}
