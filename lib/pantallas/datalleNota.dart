import 'package:flutter/material.dart';

class NotaDetalleScreen extends StatelessWidget {
  final String noteName;
  final String noteDetails; // Puedes agregar más detalles si los tienes

  const NotaDetalleScreen({
    Key? key,
    required this.noteName,
    required this.noteDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Nota'),
        backgroundColor: Color(0xFFAA405B), // Usa el mismo color para consistencia
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              noteName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              noteDetails,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
