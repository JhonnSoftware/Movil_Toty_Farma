import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductosScreen(),
    );
  }
}

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Map<String, dynamic>> productos = [];

  @override
  void initState() {
    super.initState();
    obtenerProductos();
  }

  String convertirEnlaceDriveADirecto(String enlaceDrive) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlaceDrive);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      return enlaceDrive;
    }
  }

  Future<void> obtenerProductos() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('productos').get();
      setState(() {
        productos = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  Future<void> mostrarFormulario({Map<String, dynamic>? producto}) async {
    final nombreController = TextEditingController(text: producto?['nombre']);
    final precioController = TextEditingController(text: producto?['precio']?.toString());
    final imagenController = TextEditingController(text: producto?['imagen']);

    final isEditando = producto != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditando ? 'Editar Producto' : 'Agregar Producto'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imagenController,
                decoration: const InputDecoration(labelText: 'Enlace de Imagen (Drive)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreController.text.trim();
              final precio = double.tryParse(precioController.text.trim()) ?? 0.0;
              final imagen = imagenController.text.trim();

              if (nombre.isNotEmpty) {
                final data = {
                  'nombre': nombre,
                  'precio': precio,
                  'imagen': imagen,
                };

                if (isEditando) {
                  // Update
                  await FirebaseFirestore.instance
                      .collection('productos')
                      .doc(producto!['id'])
                      .update(data);
                } else {
                  // Create
                  await FirebaseFirestore.instance.collection('productos').add(data);
                }

                Navigator.pop(context);
                obtenerProductos();
              }
            },
            child: Text(isEditando ? 'Actualizar' : 'Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> eliminarProducto(String id) async {
    await FirebaseFirestore.instance.collection('productos').doc(id).delete();
    obtenerProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => mostrarFormulario(),
          )
        ],
      ),
      body: productos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                final urlImagenOriginal = producto['imagen'] as String? ?? '';
                final urlImagenDirecta = convertirEnlaceDriveADirecto(urlImagenOriginal);

                return ListTile(
                  leading: urlImagenOriginal.isNotEmpty
                      ? Image.network(
                          urlImagenDirecta,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(producto['nombre'] ?? 'Sin nombre'),
                  subtitle: Text('Precio: S/ ${producto['precio'] ?? '0.00'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => mostrarFormulario(producto: producto),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => eliminarProducto(producto['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
