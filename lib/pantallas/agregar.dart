import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_team_odaa/pantallas/agregar2.dart'; // Asegúrate de que esta importación sea correcta

class NotaFormScreen extends StatelessWidget {
  final String userId;
  final String email;

  const NotaFormScreen({Key? key, required this.userId, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEA775),
        title: Text('Crear nota de ahorro'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: NotaForm(userId: userId, email: email),
    );
  }
}

class NotaForm extends StatefulWidget {
  final String userId;
  final String email;

  NotaForm({required this.userId, required this.email});

  @override
  _NotaFormState createState() => _NotaFormState();
}

class _NotaFormState extends State<NotaForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usersController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Future<void> _submitForm() async {
    String name = _nameController.text.trim();
    String users = _usersController.text.trim();
    String quantity = _quantityController.text.trim();

    if (name.isNotEmpty && users.isNotEmpty && quantity.isNotEmpty) {
      try {
        double usersDouble = double.parse(users);
        double quantityDouble = double.parse(quantity);

        if (usersDouble <= 0 || quantityDouble <= 0) {
          _showErrorDialog('Los valores deben ser mayores que cero.');
          return;
        }

        // Crear el documento de la nota
        DocumentReference noteRef =
            await FirebaseFirestore.instance.collection('notes').add({
          'userId': widget.userId,
          'email': widget.email,
          'name': name,
          'number_of_users': usersDouble,
          'quantity_per_year': quantityDouble,
          'createdAt': Timestamp.now(),
          'quantity_per_user': quantityDouble / usersDouble, // Calcula la cantidad por usuario
        });

        if (noteRef.id.isNotEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PersonaFormScreen(
                userId: widget.userId,
                email: widget.email,
                noteId: noteRef.id,
                noteName: name,
                numberOfUsers: usersDouble.toInt(),
                quantityPerYear: quantityDouble,
              ),
            ),
          );
        } else {
          _showErrorDialog('Error: La referencia del documento es vacía.');
        }
      } catch (e) {
        _showErrorDialog('Error al guardar los datos: $e');
      }
    } else {
      _showErrorDialog('Por favor complete todos los campos antes de continuar.');
    }
  }

  void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color.fromARGB(255, 255, 189, 189), // Color de fondo del diálogo
        title: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Ajustar el tamaño del Row al contenido
            children: [
              Text(
                'Error',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 0, 0), // Color del texto del título
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                ),
              ),
              SizedBox(width: 8), // Espacio entre el texto y el icono
             Icon(
             Icons.cancel, // Puedes usar Icons.close si prefieres una equis
             color: const Color.fromARGB(255, 255, 0, 0), // Color del icono
            size: 40.0, // Tamaño del icono
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black87,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Color del texto del botón
            ),
            child: Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Asegúrate de que el contenido se ajuste al teclado
      body: Container(
        width: double.infinity,
        height: double.infinity, // Asegura que el Container abarque toda la pantalla
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAA405B), Color(0xFF441A24)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600, // Establece un ancho máximo para el formulario
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0), // Separación vertical desde la pantalla
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '¡Bienvenido, ${widget.email}!',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.0),
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Márgenes horizontales
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nombre de la nota',
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.0),
                                TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Introduce el nombre de la nota',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0), // Borde redondeado
                                      borderSide: BorderSide(
                                        color: Colors.grey, // Color del borde
                                        width: 1.0, // Ancho del borde
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Borde redondeado
                                      borderSide: BorderSide(
                                        color: Colors.deepOrange, // Color del borde cuando está enfocado
                                        width: 1.0, // Ancho del borde
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Márgenes horizontales
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('No. usuarios',
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.0),
                                TextField(
                                  controller: _usersController,
                                  decoration: InputDecoration(
                                    hintText: 'Introduce el número de usuarios',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0), // Borde redondeado
                                      borderSide: BorderSide(
                                        color: Colors.grey, // Color del borde
                                        width: 1.0, // Ancho del borde
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Borde redondeado
                                      borderSide: BorderSide(
                                        color: Colors.deepOrange, // Color del borde cuando está enfocado
                                        width: 1.0, // Ancho del borde
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Márgenes horizontales
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cantidad al año',
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.0),
                                TextField(
                                  controller: _quantityController,
                                  decoration: InputDecoration(
                                    hintText: 'Introduce la cantidad al año',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0), // Borde redondeado
                                      borderSide: BorderSide(
                                        color: Colors.grey, // Color del borde
                                        width: 1.0, // Ancho del borde
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Borde redondeado
                                      borderSide: BorderSide(
                                        color: Colors.deepOrange, // Color del borde cuando está enfocado
                                        width: 1.0, // Ancho del borde
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.0),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text('Continuar'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepOrange,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
