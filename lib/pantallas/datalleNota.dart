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
  double totalAmountPaid = 0; // Variable para almacenar el monto total pagado

  @override
  void initState() {
    super.initState();
    _fetchTotalAmountPaid();
  }

  void _fetchTotalAmountPaid() async {
    try {
      DocumentSnapshot noteDoc = await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.noteId)
          .get();

      if (noteDoc.exists) {
        var data = noteDoc.data() as Map<String, dynamic>?;

        setState(() {
          totalAmountPaid = data?['totalAmountPaid']?.toDouble() ?? 0.0;
        });
      } else {
        setState(() {
          totalAmountPaid = 0.0;
        });
      }
    } catch (e) {
      print('Error al obtener el monto total pagado: $e');
      setState(() {
        totalAmountPaid = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la nota de ahorro'),
        backgroundColor: Color(0xFFFEA775),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // colors: [Colors.blueAccent, Colors.purpleAccent],
            colors: [
              Color(0xFFAA405B),
              Color(0xFF441A24)
            ], // Colores del degradado
            begin: Alignment.centerLeft, // Inicia en el lado izquierdo
            end: Alignment.centerRight, // Termina en el lado derecho
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
  crossAxisAlignment: CrossAxisAlignment.start, // Alinear el texto a la izquierda
  children: [
    Text(
      widget.noteName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8), // Espacio entre el nombre y el total pagado
    Text(
      'Total Pagado: \$${totalAmountPaid.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 129, 236, 132),
      ),
    ),
    SizedBox(height: 4), // Espacio entre el total pagado y la línea
    Container(
      height: 2, // Altura de la línea
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 0, 0, 0),
            width: 2,
            style: BorderStyle.solid, // Puedes ajustar el estilo si es necesario
          ),
        ),
      ),
      child: Row(
        children: List.generate(
          (MediaQuery.of(context).size.width / 10).floor(),
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              height: 2,
              color: const Color.fromARGB(255, 129, 236, 132),
            ),
          ),
        ),
      ),
    ),
  ],
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
                        double abonado = persona['abonado'] ?? 0;
                        double prestado = persona['prestado'] ?? 0;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepOrange[100],
                              //gradient: LinearGradient(
                              // colors: [Colors.blue, Colors.purple], // Colores para el degradado
                              //begin: Alignment.centerLeft, // Comienza desde la izquierda
                              //  end: Alignment.centerRight, // Termina a la derecha
                              // ),
                              borderRadius: BorderRadius.circular(
                                  4), // Ajusta el radio si es necesario
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Cantidad a abonar cada 15 días: \$${quantityPerUser.toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    'Cantidad abonada: \$${abonado.toStringAsFixed(2)}',
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Cantidad prestada: \$${prestado.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _openAbonarModal(context, personaId,
                                              quantityPerUser, abonado);
                                        },
                                        child: Text('Agregar'),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            abonado > 0 && prestado <= abonado
                                                ? () {
                                                    _openPrestarModal(
                                                        context,
                                                        personaId,
                                                        quantityPerUser,
                                                        abonado,
                                                        prestado);
                                                  }
                                                : null,
                                        child: Text('Prestar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: prestado > 0
                                            ? () {
                                                _openPagarModal(
                                                    context,
                                                    personaId,
                                                    prestado,
                                                    abonado);
                                              }
                                            : null,
                                        child: Text('Pagar'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  void _openAbonarModal(BuildContext context, String personaId,
      double quantityPerUser, double abonadoActual) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Cambia el color de fondo aquí
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Cambia el borde del cuadro de diálogo
          ),
          title: Text(
            'Abonar',
            style: TextStyle(
              color: Colors.black, // Cambia el color del texto del título
              fontSize: 20, // Cambia el tamaño del texto del título
              fontWeight:
                  FontWeight.bold, // Cambia el grosor del texto del título
            ),
          ),
          content: Text(
            'Cantidad a abonar: \$${quantityPerUser.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.black87, // Cambia el color del texto del contenido
              fontSize: 18, // Cambia el tamaño del texto del contenido
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 192, 189, 189), // Fondo del botón "Cancelar"
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Bordes redondeados del botón
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.black, // Cambia el color del texto del botón
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 125, 188, 240), // Fondo del botón "Continuar"
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Bordes redondeados del botón
                ),
              ),
              child: Text(
                'Continuar',
                style: TextStyle(
                  color: const Color.fromARGB(
                      255, 0, 0, 0), // Cambia el color del texto del botón
                ),
              ),
              onPressed: () async {
                double nuevoAbonado = abonadoActual + quantityPerUser;
                await FirebaseFirestore.instance
                    .collection('notes')
                    .doc(widget.noteId)
                    .collection('personas')
                    .doc(personaId)
                    .update({'abonado': nuevoAbonado});

                // Actualizar el totalAmountPaid
                setState(() {
                  totalAmountPaid += quantityPerUser;
                });

                await FirebaseFirestore.instance
                    .collection('notes')
                    .doc(widget.noteId)
                    .update({'totalAmountPaid': totalAmountPaid});

                Navigator.of(context).pop(); // Cierra el modal
              },
            ),
          ],
        );
      },
    );
  }

  void _openPrestarModal(BuildContext context, String personaId,
      double quantityPerUser, double abonadoActual, double prestadoActual) {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
              255, 235, 175, 175), // Cambia el color de fondo aquí
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Bordes redondeados del cuadro de diálogo
          ),
          title: Text(
            'Prestar',
            style: TextStyle(
              color: Colors.black, // Cambia el color del texto del título
              fontSize: 25, // Cambia el tamaño del texto del título
              fontWeight:
                  FontWeight.bold, // Cambia el grosor del texto del título
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cantidad a prestar:',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87, // Cambia el color del texto
                ),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ingrese la cantidad a prestar',
                  hintStyle: TextStyle(
                    color:
                        Colors.grey, // Cambia el color del texto de sugerencia
                  ),
                  filled: true,
                  fillColor: Colors.grey[200], // Fondo del campo de texto
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide.none, // Elimina el borde del campo de texto
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Cantidad abonada actual: \$${abonadoActual.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black, // Cambia el color del texto
                ),
              ),
              Text(
                'Cantidad prestada actual: \$${prestadoActual.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[
                      600], // Cambia el color del texto de la cantidad prestada
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200], // Fondo del botón "Cancelar"
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Bordes redondeados del botón
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.black, // Cambia el color del texto del botón
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Fondo del botón "Continuar"
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Bordes redondeados del botón
                ),
              ),
              child: Text(
                'Continuar',
                style: TextStyle(
                  color: const Color.fromARGB(
                      255, 0, 0, 0), // Cambia el color del texto del botón
                ),
              ),
              onPressed: () async {
                double cantidadPrestada =
                    double.tryParse(_amountController.text) ?? 0;
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

                  // Actualizar el totalAmountPaid
                  setState(() {
                    totalAmountPaid -=
                        cantidadPrestada; // Restar en lugar de sumar
                  });

                  await FirebaseFirestore.instance
                      .collection('notes')
                      .doc(widget.noteId)
                      .update({'totalAmountPaid': totalAmountPaid});

                  Navigator.of(context).pop(); // Cierra el modal
                } else {
                  // Mostrar mensaje de error si la cantidad es inválida
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor:
                            Colors.white, // Fondo del diálogo de error
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: Text(
                          'Error',
                          style: TextStyle(
                            color: Colors
                                .red, // Cambia el color del texto del título de error
                          ),
                        ),
                        content: Text(
                          'La cantidad a prestar debe ser menor o igual a la cantidad abonada y mayor a cero.',
                          style: TextStyle(
                            color: Colors
                                .black87, // Cambia el color del texto del contenido de error
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.grey[200], // Fondo del botón "Aceptar"
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Bordes redondeados del botón
                              ),
                            ),
                            child: Text(
                              'Aceptar',
                              style: TextStyle(
                                color: Colors
                                    .black, // Cambia el color del texto del botón
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Cierra el diálogo de error
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

  void _openPagarModal(BuildContext context, String personaId,
      double prestadoActual, double abonadoActual) {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
              255, 235, 175, 175), // Cambia el color de fondo aquí
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Bordes redondeados del cuadro de diálogo
          ),
          title: Text(
            'Pagar',
            style: TextStyle(
              color: Colors.black, // Cambia el color del texto del título
              fontSize: 25, // Cambia el tamaño del texto del título
              fontWeight:
                  FontWeight.bold, // Cambia el grosor del texto del título
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cantidad a pagar:',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87, // Cambia el color del texto
                ),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ingrese la cantidad a pagar',
                  hintStyle: TextStyle(
                    color:
                        Colors.grey, // Cambia el color del texto de sugerencia
                  ),
                  filled: true,
                  fillColor: Colors.grey[200], // Fondo del campo de texto
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide.none, // Elimina el borde del campo de texto
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Cantidad prestada actual: \$${prestadoActual.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black, // Cambia el color del texto
                ),
              ),
              Text(
                'Cantidad abonada actual: \$${abonadoActual.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 9, 177, 15), // Cambia el color del texto de la cantidad abonada
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200], // Fondo del botón "Cancelar"
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Bordes redondeados del botón
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.black, // Cambia el color del texto del botón
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Fondo del botón "Continuar"
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Bordes redondeados del botón
                ),
              ),
              child: Text(
                'Continuar',
                style: TextStyle(
                  color: const Color.fromARGB(
                      255, 0, 0, 0), // Cambia el color del texto del botón
                ),
              ),
              onPressed: () async {
                double cantidadPagada =
                    double.tryParse(_amountController.text) ?? 0;
                if (cantidadPagada > 0 && cantidadPagada <= prestadoActual) {
                  double nuevoAbonado = abonadoActual + cantidadPagada;
                  double nuevoPrestado = prestadoActual - cantidadPagada;
                  await FirebaseFirestore.instance
                      .collection('notes')
                      .doc(widget.noteId)
                      .collection('personas')
                      .doc(personaId)
                      .update({
                    'abonado': nuevoAbonado,
                    'prestado': nuevoPrestado,
                  });

                  // Actualizar el totalAmountPaid
                  setState(() {
                    totalAmountPaid += cantidadPagada;
                  });

                  await FirebaseFirestore.instance
                      .collection('notes')
                      .doc(widget.noteId)
                      .update({'totalAmountPaid': totalAmountPaid});

                  Navigator.of(context).pop(); // Cierra el modal
                } else {
                  // Mostrar mensaje de error si la cantidad es inválida
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor:
                            Colors.white, // Fondo del diálogo de error
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: Text(
                          'Error',
                          style: TextStyle(
                            color: Colors
                                .red, // Cambia el color del texto del título de error
                          ),
                        ),
                        content: Text(
                          'La cantidad a pagar debe ser menor o igual a la cantidad prestada y mayor a cero.',
                          style: TextStyle(
                            color: Colors
                                .black87, // Cambia el color del texto del contenido de error
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.grey[200], // Fondo del botón "Aceptar"
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Bordes redondeados del botón
                              ),
                            ),
                            child: Text(
                              'Aceptar',
                              style: TextStyle(
                                color: Colors
                                    .black, // Cambia el color del texto del botón
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Cierra el diálogo de error
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
