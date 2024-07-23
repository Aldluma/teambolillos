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
    for (int i = 0; i < widget.numberOfUsers; i++) {
      String name = _nameControllers[i].text.trim();
      if (name.isNotEmpty) {
        users.add({'name': name});
      }
    }

    if (users.length == widget.numberOfUsers) {
      try {
        DocumentReference noteRef = FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.noteId);

        double quantityPerUser;
        try {
          quantityPerUser = double.parse(_quantityController.text);
        } catch (e) {
          quantityPerUser = 0.0; // Manejo de error si la conversión falla
        }

        // Actualizar la nota con los usuarios, la cantidad por usuario y el ID del usuario que creó la nota
        await noteRef.update({
          'users': users,
          'quantity_per_user': quantityPerUser,
          'created_by': widget.userId, // Guardar el ID del usuario que creó la nota
        });

        // Guardar cada usuario en una subcolección 'personas' dentro de la nota
        for (var user in users) {
          await noteRef.collection('personas').add(user);
        }

        // Mostrar diálogo de éxito
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Éxito'),
              content: Text('Datos guardados exitosamente.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    Navigator.of(context).popUntil((route) => route.isFirst); // Regresa a la pantalla principal
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error al guardar los datos: $e');
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar los datos')),
        );
      }
    } else {
      print('Por favor complete todos los campos');
      // Mostrar mensaje de advertencia
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor complete todos los campos')),
      );
    }
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
        backgroundColor: Colors.orange,
        title: Text('Persona Form'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                '¡Bienvenido, ${widget.email}!',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.0),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ...List.generate(widget.numberOfUsers, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _nameControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Nombre del usuario ${index + 1}',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 16.0),
                    Text(
                      'Cantidad por usuario:\n${_quantityController.text}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Centra el texto
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepOrange,
                        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
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
    );
  }
}
