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
  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      DocumentSnapshot noteSnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .doc(noteId)
          .get();

      if (!noteSnapshot.exists) {
        _showSnackBar('La nota no existe');
        return;
      }

      Map<String, dynamic> noteData =
          noteSnapshot.data() as Map<String, dynamic>;

      double totalAmountPaid = noteData['totalAmountPaid'] ?? 0.0;
      double quantityPerYear = noteData['quantityPerYear'] ?? 0.0;

      if (totalAmountPaid < quantityPerYear) {
        _showSnackBar(
            'No se puede eliminar la nota hasta que se pague la cantidad total.');
        return;
      }

      await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
      _showSnackBar('Nota eliminada exitosamente');
    } catch (e) {
      print('Error al eliminar la nota: $e');
      _showSnackBar('Error al eliminar la nota');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildNotesContainer(),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesContainer() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.75,
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notes')
                  .where('created_by', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tienes ahorros.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var note = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    String noteName = note['name'] ?? 'Sin título';
                    String noteId = snapshot.data!.docs[index].id;

                    double totalAmountPaid = note['totalAmountPaid'] ?? 0.0;
                    double quantityPerYear = note['quantityPerYear'] ?? 0.0;

                    bool canDelete = totalAmountPaid >= quantityPerYear;

                    return ListTile(
                      title: Container(
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
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
                      trailing: _buildActionButtonsForNote(
                        noteId,
                        noteName,
                        canDelete,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsForNote(
      String noteId, String noteName, bool canDelete) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: canDelete
              ? () {
                  _showConfirmationDialog(
                    'Confirmar Eliminación',
                    '¿Estás seguro de que deseas eliminar esta nota?',
                    () => _deleteNote(noteId),
                  );
                }
              : null, // Deshabilitar el botón si no se puede eliminar
        ),
        IconButton(
          icon: Icon(Icons.info, color: Color.fromARGB(255, 13, 101, 173)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotaDetalleScreen(
                  noteName: noteName,
                  noteId: noteId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.08,
      color: const Color.fromARGB(255, 0, 5, 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGradientButton(
              icon: Icons.home,
              label: 'Inicio',
              onPressed: () {},
            ),
            _buildGradientButton(
              icon: Icons.add,
              label: 'Agregar',
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
            ),
            _buildGradientButton(
              icon: Icons.exit_to_app,
              label: 'Salir',
              onPressed: () {
                _showConfirmationDialog(
                  'Confirmar Salida',
                  '¿Estás seguro de que deseas cerrar sesión?',
                  () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) =>
                          false, // Eliminar todas las rutas en el historial
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAA405B), Color(0xFF441A24)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white)),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        ),
      ),
    );
  }
/*
void _showConfirmationDialog(String title, String content, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Esquinas redondeadas
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFAA405B), Color(0xFF441A24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white, // Color del texto del título
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                content,
                style: TextStyle(
                  color: Colors.white70, // Color del texto del contenido
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white, // Color del texto del botón Cancelar
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Aceptar',
                      style: TextStyle(
                        color: Colors.redAccent, // Color del texto del botón Aceptar
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
*/

  void _showConfirmationDialog(
      String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 240, 194, 194), // Fondo del diálogo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Esquinas redondeadas
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black, // Color del texto del título
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.black87, // Color del texto del contenido
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0), // Color del texto del botón Cancelar
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.red, // Color del texto del botón Aceptar
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}
