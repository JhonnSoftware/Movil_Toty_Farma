import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <- para inputFormatters
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
  List<Map<String, dynamic>> productosFiltrados = [];
  List<String> proveedores = [];
  List<String> categorias = [];
  final TextEditingController busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerProductos();
    obtenerProveedores();
    obtenerCategorias();
  }

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
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
        productosFiltrados = List.from(productos); // Inicialmente sin filtro
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

  void filtrarProductos(String query) {
    final q = query.toLowerCase();
    setState(() {
      productosFiltrados = productos.where((producto) {
        final descripcion = (producto['descripcion'] ?? '').toString().toLowerCase();
        return descripcion.contains(q);
      }).toList();
    });
  }

  Future<void> mostrarFormulario({Map<String, dynamic>? producto}) async {
    final codigoController = TextEditingController(text: producto?['codigo']?.toString());
    final descripcionController = TextEditingController(text: producto?['descripcion']);
    String categoriaSeleccionada = producto?['categoria'] ?? (categorias.isNotEmpty ? categorias.first : '');
    String proveedorSeleccionado = producto?['proveedor'] ?? (proveedores.isNotEmpty ? proveedores.first : '');
    final laboratorioController = TextEditingController(text: producto?['laboratorio']);
    final presentacionController = TextEditingController(text: producto?['presentacion']);
    final fechaController = TextEditingController(
        text: producto?['fecha_vencimiento'] != null
            ? (producto!['fecha_vencimiento'] as Timestamp).toDate().toString().split(' ')[0]
            : '');
    final precioCompraController = TextEditingController(text: producto?['precio_compra']?.toString());
    final precioVentaController = TextEditingController(text: producto?['precio_venta']?.toString());
    final imagenController = TextEditingController(text: producto?['imagen']);
    final stockController = TextEditingController(text: producto?['stock']?.toString() ?? '0');
    final stockMinimoController = TextEditingController(text: producto?['stock_minimo']?.toString() ?? '0');
    bool estadoProducto = producto?['estado'] ?? true;
    final isEditando = producto != null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEditando ? 'Editar Producto' : 'Agregar Producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Solo permite números enteros (0-9)
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(labelText: 'Código'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      value: categoriaSeleccionada.isNotEmpty ? categoriaSeleccionada : null,
                      isExpanded: true,
                      items: categorias
                          .map((categoria) => DropdownMenuItem(value: categoria, child: Text(categoria)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() => categoriaSeleccionada = value);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Proveedor'),
                      value: proveedorSeleccionado.isNotEmpty ? proveedorSeleccionado : null,
                      isExpanded: true,
                      items: proveedores
                          .map((proveedor) => DropdownMenuItem(value: proveedor, child: Text(proveedor)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() => proveedorSeleccionado = value);
                        }
                      },
                    ),
                  ),
                  TextField(
                    controller: laboratorioController,
                    decoration: const InputDecoration(labelText: 'Laboratorio'),
                    keyboardType: TextInputType.text,
                  ),
                  TextField(
                    controller: presentacionController,
                    decoration: const InputDecoration(labelText: 'Presentación'),
                    keyboardType: TextInputType.text,
                  ),
                  TextField(
                    controller: fechaController,
                    decoration: const InputDecoration(labelText: 'Fecha de Vencimiento (YYYY-MM-DD)'),
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d-]')), // solo números y guiones
                    ],
                  ),
                  // Permite números con punto decimal
                  TextField(
                    controller: precioCompraController,
                    decoration: const InputDecoration(labelText: 'Precio Compra'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // números decimales con hasta 2 decimales
                    ],
                  ),
                  TextField(
                    controller: precioVentaController,
                    decoration: const InputDecoration(labelText: 'Precio Venta'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextField(
                    controller: stockMinimoController,
                    decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextField(
                    controller: imagenController,
                    decoration: const InputDecoration(labelText: 'Enlace de Imagen (Drive)'),
                    keyboardType: TextInputType.url,
                  ),
                  SwitchListTile(
                    title: const Text('¿Activo?'),
                    value: estadoProducto,
                    onChanged: (value) {
                      setStateDialog(() => estadoProducto = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final data = {
                      'codigo': int.tryParse(codigoController.text.trim()) ?? 0,
                      'descripcion': descripcionController.text.trim(),
                      'categoria': categoriaSeleccionada,
                      'proveedor': proveedorSeleccionado,
                      'laboratorio': laboratorioController.text.trim(),
                      'presentacion': presentacionController.text.trim(),
                      'fecha_vencimiento': fechaController.text.trim().isNotEmpty
                          ? Timestamp.fromDate(DateTime.parse(fechaController.text.trim()))
                          : null,
                      'precio_compra': double.tryParse(precioCompraController.text.trim()) ?? 0.0,
                      'precio_venta': double.tryParse(precioVentaController.text.trim()) ?? 0.0,
                      'stock': int.tryParse(stockController.text.trim()) ?? 0,
                      'stock_minimo': int.tryParse(stockMinimoController.text.trim()) ?? 0,
                      'imagen': imagenController.text.trim(),
                      'estado': estadoProducto,
                    };

                    if (isEditando) {
                      await FirebaseFirestore.instance
                          .collection('productos')
                          .doc(producto!['id'])
                          .update(data);
                    } else {
                      await FirebaseFirestore.instance.collection('productos').add(data);
                    }

                    Navigator.pop(context);
                    obtenerProductos();
                  } catch (e) {
                    print('Error al guardar producto: $e');
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> eliminarProducto(String id) async {
    try {
      await FirebaseFirestore.instance.collection('productos').doc(id).delete();
      obtenerProductos();
    } catch (e) {
      print('Error al eliminar producto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: busquedaController,
              decoration: const InputDecoration(
                labelText: 'Buscar por descripción',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filtrarProductos,
            ),
          ),
          Expanded(
            child: productosFiltrados.isEmpty
                ? const Center(child: Text('No hay productos'))
                : ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      final urlImagen = convertirEnlaceDriveADirecto(producto['imagen'] ?? '');

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: (producto['imagen'] != null && producto['imagen'] != '')
                              ? Image.network(
                                  urlImagen,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                )
                              : const Icon(Icons.image_not_supported, size: 60),
                          title: Text(
                            producto['descripcion'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Categoría: ${producto['categoria'] ?? 'N/A'}'),
                              Text('Proveedor: ${producto['proveedor'] ?? 'N/A'}'),
                              Text('Stock: ${producto['stock'] ?? 0}'),
                              Text('Precio venta: S/ ${producto['precio_venta']?.toStringAsFixed(2) ?? '0.00'}'),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 10,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => mostrarFormulario(producto: producto),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Text('¿Eliminar producto "${producto['descripcion']}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                                      ElevatedButton(
                                        onPressed: () {
                                          eliminarProducto(producto['id']);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
