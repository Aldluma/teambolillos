import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotaDetalleScreen extends StatefulWidget {
  final String noteId;
  final String noteName;

  const NotaDetalleScreen({
    Key? key,
    required this.noteId,
    required this.noteName,
  }) : super(key: key);

  @override
  _NotaDetalleScreenState createState() => _NotaDetalleScreenState();
}

class _NotaDetalleScreenState extends State<NotaDetalleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Nota'),
        backgroundColor: Color(0xFFAA405B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.noteName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notes')
                    .doc(widget.noteId)
                    .collection('personas')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No hay personas.'));
                  }
                  var personas = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: personas.length,
                    itemBuilder: (context, index) {
                      var persona = personas[index];
                      String personaId = persona.id;
                      String name = persona['name'];
                      double quantityPerUser = persona['quantity_per_user'];
                      double abonado = persona['abonado'];
                      double prestado = persona['prestado'] ?? 0; // Obtener la cantidad prestada, si existe

                      return ListTile(
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad a abonar cada 15 días: \$${quantityPerUser.toStringAsFixed(2)}'),
                            Text('Cantidad abonada: \$${abonado.toStringAsFixed(2)}'),
                            SizedBox(height: 8),
                            Text(
                              'Cantidad prestada: \$${prestado.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _openAbonarModal(context, personaId, quantityPerUser, abonado);
                              },
                              child: Text('Agregar'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: abonado >= quantityPerUser
                                  ? () {
                                      _openPrestarModal(context, personaId, quantityPerUser, abonado, prestado);
                                    }
                                  : null,
                              child: Text('Prestar'),
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
    );
  }

  void _openAbonarModal(BuildContext context, String personaId, double quantityPerUser, double abonadoActual) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Abonar'),
          content: Text('Cantidad a abonar: \$${quantityPerUser.toStringAsFixed(2)}'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
            ),
            TextButton(
              child: Text('Continuar'),
              onPressed: () async {
                double nuevoAbonado = abonadoActual + quantityPerUser;
                await FirebaseFirestore.instance
                    .collection('notes')
                    .doc(widget.noteId)
                    .collection('personas')
                    .doc(personaId)
                    .update({'abonado': nuevoAbonado});
                Navigator.of(context).pop(); // Cierra el modal
              },
            ),
          ],
        );
      },
    );
  }

  void _openPrestarModal(BuildContext context, String personaId, double quantityPerUser, double abonadoActual, double prestadoActual) {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Prestar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cantidad a prestar:'),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ingrese la cantidad a prestar',
                ),
                onChanged: (value) {
                  // Validar la entrada en tiempo real si es necesario
                },
              ),
              SizedBox(height: 16),
              Text(
                'Cantidad abonada actual: \$${abonadoActual.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Cantidad prestada actual: \$${prestadoActual.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
            ),
            TextButton(
              child: Text('Continuar'),
              onPressed: () async {
                double cantidadPrestada = double.tryParse(_amountController.text) ?? 0;
                if (cantidadPrestada > 0 && cantidadPrestada <= abonadoActual) {
                  double nuevoAbonado = abonadoActual - cantidadPrestada;
                  double nuevoPrestado = prestadoActual + cantidadPrestada;
                  await FirebaseFirestore.instance
                      .collection('notes')
                      .doc(widget.noteId)
                      .collection('personas')
                      .doc(personaId)
                      .update({
                        'abonado': nuevoAbonado,
                        'prestado': nuevoPrestado,
                      });
                  Navigator.of(context).pop(); // Cierra el modal
                } else {
                  // Mostrar mensaje de error si la cantidad es inválida
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('La cantidad a prestar debe ser menor o igual a la cantidad abonada.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Aceptar'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Cierra el diálogo de error
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
