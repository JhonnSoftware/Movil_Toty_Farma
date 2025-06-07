import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pago_page.dart';

class UsuariosCarritoPage extends StatefulWidget {
  final String userId;

  const UsuariosCarritoPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UsuariosCarritoPage> createState() => _UsuariosCarritoPageState();
}

class _UsuariosCarritoPageState extends State<UsuariosCarritoPage> {
  late CollectionReference carritoRef;
  late CollectionReference productosRef;

  final Color azulOscuro = const Color(0xFF0A7ABF);
  final Color azulClaro = const Color(0xFF25A6D9);
  final Color verdeFuerte = const Color(0xFF6EBF49);
  final Color grisClaro = const Color(0xFFF2F2F2);

  @override
  void initState() {
    super.initState();
    carritoRef = FirebaseFirestore.instance.collection('carritos');
    productosRef = carritoRef.doc(widget.userId).collection('productos');
  }

  Future<void> eliminarProducto(DocumentSnapshot productoDoc) async {
    final productoData = productoDoc.data() as Map<String, dynamic>;
    double subtotal = (productoData['subtotal'] ?? 0).toDouble();
    int cantidad = (productoData['cantidad'] ?? 1).toInt();

    await carritoRef.doc(widget.userId).update({
      'totalItems': FieldValue.increment(-cantidad),
      'totalPrecio': FieldValue.increment(-subtotal),
    });

    await productosRef.doc(productoDoc.id).delete();
  }

  Future<void> actualizarCantidad(DocumentSnapshot productoDoc, int cambio) async {
    final productoData = productoDoc.data() as Map<String, dynamic>;
    int cantidadActual = (productoData['cantidad'] ?? 1).toInt();
    double precio = (productoData['precio_venta'] ?? 0).toDouble();

    int nuevaCantidad = cantidadActual + cambio;
    if (nuevaCantidad <= 0) {
      await eliminarProducto(productoDoc);
      return;
    }

    double nuevoSubtotal = precio * nuevaCantidad;
    double diferenciaSubtotal = precio * cambio;

    await productosRef.doc(productoDoc.id).update({
      'cantidad': nuevaCantidad,
      'subtotal': nuevoSubtotal,
    });

    await carritoRef.doc(widget.userId).update({
      'totalItems': FieldValue.increment(cambio),
      'totalPrecio': FieldValue.increment(diferenciaSubtotal),
    });
  }

  Future<void> continuarCompra(double totalPrecio) async {
    final productosSnapshot = await productosRef.get();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PagoPage(
          userId: widget.userId,
          total: totalPrecio,
          productosSnapshot: productosSnapshot,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClaro,
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: azulOscuro,
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
                          elevation: 3,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: azulOscuro,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Precio: S/ ${producto['precio_venta']}'),
                                Text('Subtotal: S/ ${producto['subtotal'].toStringAsFixed(2)}'),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () async {
                                        await actualizarCantidad(productoDoc, -1);
                                      },
                                    ),
                                    Text('Cantidad: ${producto['cantidad']}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () async {
                                        await actualizarCantidad(productoDoc, 1);
                                      },
                                    ),
                                  ],
                                ),
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
              if (totalItems > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: azulClaro,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total ($totalItems items)',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            'S/ ${totalPrecio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verdeFuerte,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () => continuarCompra(totalPrecio),
                        child: const Text('Continuar Compra'),
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
