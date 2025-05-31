import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuariosCarritoPage extends StatefulWidget {
  final String userId;
  const UsuariosCarritoPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UsuariosCarritoPage> createState() => _UsuariosCarritoPageState();
}

class _UsuariosCarritoPageState extends State<UsuariosCarritoPage> {
  late CollectionReference carritoRef;
  late CollectionReference productosRef;

  @override
  void initState() {
    super.initState();
    carritoRef = FirebaseFirestore.instance.collection('carritos');
    productosRef = carritoRef.doc(widget.userId).collection('productos');
  }

  Future<void> eliminarProducto(DocumentSnapshot productoDoc) async {
    final productoData = productoDoc.data() as Map<String, dynamic>;

    double subtotal = (productoData['subtotal'] ?? 0).toDouble();
    int cantidad = (productoData['cantidad'] ?? 1);

    await carritoRef.doc(widget.userId).update({
      'totalItems': FieldValue.increment(-cantidad),
      'totalPrecio': FieldValue.increment(-subtotal),
    });

    await productosRef.doc(productoDoc.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: carritoRef.doc(widget.userId).snapshots(),
        builder: (context, carritoSnapshot) {
          if (carritoSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!carritoSnapshot.hasData || !carritoSnapshot.data!.exists) {
            return const Center(child: Text('No tienes productos en el carrito'));
          }

          var carritoData = carritoSnapshot.data!.data() as Map<String, dynamic>;
          int totalItems = carritoData['totalItems'] ?? 0;
          double totalPrecio = (carritoData['totalPrecio'] ?? 0).toDouble();

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: productosRef.snapshots(),
                  builder: (context, productosSnapshot) {
                    if (productosSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!productosSnapshot.hasData || productosSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No hay productos en el carrito'));
                    }

                    var productosDocs = productosSnapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: productosDocs.length,
                      itemBuilder: (context, index) {
                        var productoDoc = productosDocs[index];
                        var producto = productoDoc.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                producto['imagen'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              producto['descripcion'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cantidad: ${producto['cantidad']}'),
                                Text('Precio: S/ ${producto['precio_venta']}'),
                                Text('Subtotal: S/ ${producto['subtotal']}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await eliminarProducto(productoDoc);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($totalItems items)',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'S/ ${totalPrecio.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
