import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PersonaFormScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String noteId;
  final String noteName;
  final int numberOfUsers;
  final double quantityPerYear;

  const PersonaFormScreen({
    Key? key,
    required this.userId,
    required this.email,
    required this.noteId,
    required this.noteName,
    required this.numberOfUsers,
    required this.quantityPerYear,
  }) : super(key: key);

  @override
  _PersonaFormScreenState createState() => _PersonaFormScreenState();
}

class _PersonaFormScreenState extends State<PersonaFormScreen> {
  late List<TextEditingController> _nameControllers;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameControllers = List.generate(
      widget.numberOfUsers,
      (_) => TextEditingController(),
    );

    double quantity = widget.quantityPerYear / widget.numberOfUsers / 24;
    _quantityController.text = quantity.toStringAsFixed(2); // Valor calculado
  }

  Future<void> _submitForm() async {
    List<Map<String, dynamic>> users = [];

    double quantityPerUser;
    try {
      quantityPerUser = double.parse(_quantityController.text);
    } catch (e) {
      quantityPerUser = 0.0; // Manejo de error si la conversión falla
    }

    for (int i = 0; i < widget.numberOfUsers; i++) {
      String name = _nameControllers[i].text.trim();
      if (name.isNotEmpty) {
        users.add({
          'name': name,
          'quantity_per_user': quantityPerUser,
          'abonado': 0.0,
          'prestado': 0.0,
        });
      }
    }

    if (users.length == widget.numberOfUsers) {
      try {
        DocumentReference noteRef =
            FirebaseFirestore.instance.collection('notes').doc(widget.noteId);

        await noteRef.update({
          'users': users,
          'quantity_per_user': quantityPerUser,
          'created_by': widget.userId,
        });

        for (var user in users) {
          await noteRef.collection('personas').add(user);
        }

        _showSuccessDialog();
      } catch (e) {
        print('Error al guardar los datos: $e');
        _showErrorDialog(
            'Error', 'Error al guardar los datos. Inténtalo de nuevo.');
      }
    } else {
      print('Por favor complete todos los campos');
      _showErrorDialog(
          'Campos incompletos', 'Por favor complete todos los campos.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepOrange[100], // Color de fondo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
          ),
          title: Row(
            mainAxisSize:
                MainAxisSize.min, // Ajustar el tamaño del Row al contenido
            children: [
              Icon(
                Icons.error, // Cambia el icono según tus necesidades
                color: Color.fromARGB(255, 204, 0, 0), // Color del icono
                size: 30.0, // Tamaño del icono
              ),
              SizedBox(width: 8), // Espacio entre el icono y el texto
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 204, 0, 0), // Color del título
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black, // Color del mensaje
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Color del texto del botón
                backgroundColor: Colors.deepOrange, // Color de fondo del botón
              ),
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green,
              ),
              SizedBox(width: 8), // Espacio entre el texto y el icono
              Text(
                '¡Éxito!',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Los datos se han guardado exitosamente.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepOrange, // Color del texto del botón
              ),
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).popUntil((route) =>
                    route.isFirst); // Regresa a la pantalla principal
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el estado se elimina
    _quantityController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEA775),
        title: Text('Integrantes del ahorro'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAA405B), Color(0xFF441A24)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ...List.generate(widget.numberOfUsers, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre del usuario ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                TextField(
                                  controller: _nameControllers[index],
                                  decoration: InputDecoration(
                                    hintText:
                                        'Ingrese el nombre del ahorrador ${index + 1}',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        SizedBox(height: 16.0),
                        Center(
                          child: Text(
                            'Cantidad por usuario:\n${_quantityController.text}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: Text('Guardar'),
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
    );
  }
}
