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
  List<String> proveedores = [];
  List<String> categorias = [];

  @override
  void initState() {
    super.initState();
    obtenerProductos();
    obtenerProveedores();
    obtenerCategorias();
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
        productos = snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
      });
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  Future<void> obtenerProveedores() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('proveedores').get();
      setState(() {
        proveedores = snapshot.docs.map((doc) => doc['nombre'].toString()).toList();
      });
    } catch (e) {
      print('Error al obtener proveedores: $e');
    }
  }

  Future<void> obtenerCategorias() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categorias').get();
      setState(() {
        categorias = snapshot.docs.map((doc) => doc['nombre'].toString()).toList();
      });
    } catch (e) {
      print('Error al obtener categorías: $e');
    }
  }

  Future<void> mostrarFormulario({Map<String, dynamic>? producto}) async {
    final codigoController = TextEditingController(text: producto?['codigo']?.toString());
    final descripcionController = TextEditingController(text: producto?['descripcion']);
    final estado = producto?['estado'] ?? true;
    final fechaController = TextEditingController(
        text: producto?['fecha_vencimiento'] != null
            ? (producto!['fecha_vencimiento'] as Timestamp).toDate().toString().split(' ')[0]
            : '');
    final imagenController = TextEditingController(text: producto?['imagen']);
    final laboratorioController = TextEditingController(text: producto?['laboratorio']);
    final precioCompraController =
        TextEditingController(text: producto?['precio_compra']?.toString());
    final precioVentaController =
        TextEditingController(text: producto?['precio_venta']?.toString());
    final presentacionController = TextEditingController(text: producto?['presentacion']);
    final stockMinimoController =
        TextEditingController(text: producto?['stock_minimo']?.toString());

    String proveedorSeleccionado = producto?['proveedor'] ?? (proveedores.isNotEmpty ? proveedores.first : '');
    String categoriaSeleccionada = producto?['categoria'] ?? (categorias.isNotEmpty ? categorias.first : '');
    bool estadoProducto = estado;
    final isEditando = producto != null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEditando ? 'Editar Producto' : 'Agregar Producto'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: codigoController, decoration: InputDecoration(labelText: 'Código'), keyboardType: TextInputType.number),
                  TextField(controller: descripcionController, decoration: InputDecoration(labelText: 'Descripción')),
                  SwitchListTile(
                    title: Text('¿Activo?'),
                    value: estadoProducto,
                    onChanged: (value) {
                      setStateDialog(() {
                        estadoProducto = value;
                      });
                    },
                  ),
                  TextField(controller: fechaController, decoration: InputDecoration(labelText: 'Fecha de Vencimiento (YYYY-MM-DD)')),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Categoría'),
                    value: categoriaSeleccionada.isNotEmpty ? categoriaSeleccionada : null,
                    items: categorias.map((categoria) {
                      return DropdownMenuItem(value: categoria, child: Text(categoria));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        categoriaSeleccionada = value ?? '';
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Proveedor'),
                    value: proveedorSeleccionado.isNotEmpty ? proveedorSeleccionado : null,
                    items: proveedores.map((proveedor) {
                      return DropdownMenuItem(value: proveedor, child: Text(proveedor));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        proveedorSeleccionado = value ?? '';
                      });
                    },
                  ),
                  TextField(controller: imagenController, decoration: InputDecoration(labelText: 'Enlace de Imagen (Drive)')),
                  TextField(controller: laboratorioController, decoration: InputDecoration(labelText: 'Laboratorio')),
                  TextField(controller: precioCompraController, decoration: InputDecoration(labelText: 'Precio Compra'), keyboardType: TextInputType.number),
                  TextField(controller: precioVentaController, decoration: InputDecoration(labelText: 'Precio Venta'), keyboardType: TextInputType.number),
                  TextField(controller: presentacionController, decoration: InputDecoration(labelText: 'Presentación')),
                  TextField(controller: stockMinimoController, decoration: InputDecoration(labelText: 'Stock Mínimo'), keyboardType: TextInputType.number),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final data = {
                      'codigo': int.tryParse(codigoController.text.trim()) ?? 0,
                      'descripcion': descripcionController.text.trim(),
                      'estado': estadoProducto,
                      'fecha_vencimiento': Timestamp.fromDate(DateTime.parse(fechaController.text.trim())),
                      'categoria': categoriaSeleccionada,
                      'proveedor': proveedorSeleccionado,
                      'imagen': imagenController.text.trim(),
                      'laboratorio': laboratorioController.text.trim(),
                      'precio_compra': double.tryParse(precioCompraController.text.trim()) ?? 0.0,
                      'precio_venta': double.tryParse(precioVentaController.text.trim()) ?? 0.0,
                      'presentacion': presentacionController.text.trim(),
                      'stock_minimo': int.tryParse(stockMinimoController.text.trim()) ?? 0,
                    };

                    if (isEditando) {
                      await FirebaseFirestore.instance.collection('productos').doc(producto!['id']).update(data);
                    } else {
                      await FirebaseFirestore.instance.collection('productos').add(data);
                    }

                    Navigator.pop(context);
                    obtenerProductos();
                  } catch (e) {
                    print('Error al guardar producto: $e');
                  }
                },
                child: Text(isEditando ? 'Actualizar' : 'Agregar'),
              ),
            ],
          );
        },
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
          IconButton(icon: const Icon(Icons.add), onPressed: () => mostrarFormulario())
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
                  title: Text(producto['descripcion'] ?? 'Sin nombre'),
                  subtitle: Text('S/ ${producto['precio_venta'] ?? 0.0} - Stock mínimo: ${producto['stock_minimo'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => mostrarFormulario(producto: producto)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => eliminarProducto(producto['id'])),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
