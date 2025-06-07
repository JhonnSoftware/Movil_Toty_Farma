import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorialPedidosPage extends StatelessWidget {
  final String userId;

  const HistorialPedidosPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('userId', isEqualTo: userId)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('❌ Error en el stream: ${snapshot.error}');
            return const Center(child: Text('Error al cargar pedidos'));
          }

          final pedidos = snapshot.data?.docs ?? [];

          if (pedidos.isEmpty) {
            return const Center(child: Text('No hay pedidos registrados.'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              try {
                final pedido = pedidos[index];
                final data = pedido.data() as Map<String, dynamic>;

                final timestamp = data['fecha'] as Timestamp?;
                final fecha = timestamp?.toDate();
                final productos = data['productos'] as List<dynamic>? ?? [];
                final total = data['total'] ?? 0;

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fecha != null
                              ? 'Fecha: ${DateFormat('dd/MM/yyyy – hh:mm a').format(fecha)}'
                              : 'Fecha no disponible',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Productos:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...productos.map((producto) {
                          final descripcion = producto['descripcion'] ?? 'Sin descripción';
                          final cantidad = producto['cantidad'] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• $descripcion x$cantidad'),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        Text('Total: S/ ${total.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              } catch (e, stacktrace) {
                print('❌ Error al construir pedido #$index: $e');
                print(stacktrace);
                return const ListTile(
                  leading: Icon(Icons.error, color: Colors.red),
                  title: Text('Error al mostrar este pedido'),
                );
              }
            },
          );
        },
      ),
    );
  }
}
