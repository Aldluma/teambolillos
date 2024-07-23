import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  static Future<bool> isEmailRegistered(String email) async {
    try {
      if (email.isEmpty) {
        throw ArgumentError('El correo electrónico no puede estar vacío');
      }

      print('Verificando el correo electrónico: $email');
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      print('Métodos de inicio de sesión disponibles: $methods');
      return methods.isNotEmpty;
    } catch (e) {
      print('Error al verificar el correo electrónico: $e');
      return false;
    }
  }

  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ArgumentError('El correo electrónico y la contraseña no pueden estar vacíos');
      }

      print('Intentando iniciar sesión con: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Inicio de sesión exitoso');
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      rethrow; // Propaga la excepción para manejarla en el lugar donde se llama
    }
  }

  static Future<void> registerUser(
      String email, String password, String name, String lastName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'nombre': name,
          'apellido': lastName,
          'email': email,
        });
        print('Usuario registrado y datos guardados en Firestore');
      }
    } on FirebaseAuthException catch (e) {
      print('Error al registrar usuario: $e');
      rethrow; // Propaga la excepción para manejarla en el lugar donde se llama
    } catch (e) {
      print('Error al registrar usuario: $e');
      throw e; // Lanza el error para manejarlo en la interfaz de usuario
    }
  }

  static Future<void> guardarUser(
      String name, String lastName, String email, String password) async {
    try {
      await _firestore.collection("usuarios").add({
        "name": name,
        "apellido": lastName,
        "email": email,
        "password": password,
      });
      print('Datos guardados en Firestore');
    } catch (e) {
      print('Error al guardar datos: $e');
      throw e; // Lanza el error para manejarlo en la interfaz de usuario
    }
  }
}
