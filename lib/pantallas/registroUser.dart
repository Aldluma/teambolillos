import 'package:flutter/material.dart';
import 'package:flutter_team_odaa/BD/firebase_service.dart';
import 'package:flutter_team_odaa/pantallas/login.dart';

class registroUser extends StatefulWidget {
  @override
  _RegistroUserState createState() => _RegistroUserState();
}

class _RegistroUserState extends State<registroUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _showConfirmationDialog() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      bool isRegistered = await FirebaseService.isEmailRegistered(email);

      if (isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El correo electrónico ya está registrado.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _showRegisterConfirmationDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de usuario',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAA405B), Color(0xFF441A24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('Nombre', Icons.person, _nameController, false),
                SizedBox(height: 10),
                _buildTextField('Primer apellido', Icons.person, _lastNameController, false),
                SizedBox(height: 10),
                _buildTextField('Correo electrónico', Icons.email, _emailController, false, isEmail: true),
                SizedBox(height: 10),
                _buildTextField('Contraseña', Icons.lock, _passwordController, true, isPassword: true),
                SizedBox(height: 10),
                _buildTextField('Confirmar contraseña', Icons.lock, _confirmPasswordController, true, isPassword: true),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF56194F), Color(0xFFD46059)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      child: Text(
                        'Continuar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, IconData icon, TextEditingController controller, bool obscureText, {bool isEmail = false, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            errorStyle: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese su $labelText';
            }
            if (isEmail) {
              final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegExp.hasMatch(value)) {
                return 'Correo inválido: ejemplo@ejemplo.com';
              }
            }
            if (isPassword) {
              if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              if (!value.contains(RegExp(r'\d'))) {
                return 'La contraseña debe contener al menos un número';
              }
              if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                return 'Debe contener un carácter especial';
              }
            }
            if (labelText == 'Confirmar contraseña' && value != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _showRegisterConfirmationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Registro', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas continuar con el registro?', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _registerUser();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerUser() async {
    String name = _nameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      await FirebaseService.registerUser(email, password, name, lastName);
      print('Usuario registrado y datos guardados en Firestore');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error al registrar usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El correo electrónico ya está registrado. \nIntente nuevamente \n'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
