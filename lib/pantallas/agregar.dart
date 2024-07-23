import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_team_odaa/pantallas/agregar2.dart';
 // Asegúrate de que esta importación sea correcta

class NotaFormScreen extends StatelessWidget {
  final String userId;
  final String email;

  const NotaFormScreen({Key? key, required this.userId, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Crear Nota'),
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

      // Crear el documento de la nota
      DocumentReference noteRef = await FirebaseFirestore.instance.collection('notes').add({
        'userId': widget.userId,
        'email': widget.email,
        'name': name,
        'number_of_users': usersDouble,
        'quantity_per_year': quantityDouble,
        'createdAt': Timestamp.now(),
        'quantity_per_user': quantityDouble / usersDouble, // Calcula la cantidad por usuario
      });

      // Asegurarse de que noteRef tenga un ID válido
      if (noteRef.id.isNotEmpty) {
        // Pasar los datos a la siguiente pantalla
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
        print('Error: La referencia del documento es vacía.');
        // Mostrar mensaje de error
      }
    } catch (e) {
      print('Error al guardar los datos: $e');
      // Mostrar mensaje de error
    }
  } else {
    // Mostrar alerta si algún campo está vacío
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Campos Vacíos'),
          content: Text('Por favor complete todos los campos antes de continuar.'),
          actions: <Widget>[
            TextButton(
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
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.deepPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la nota',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _usersController,
                      decoration: InputDecoration(
                        labelText: 'No. usuarios',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad al año',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Continuar'),
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
