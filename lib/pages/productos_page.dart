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
                children: [
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(labelText: 'Código'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    value: categoriaSeleccionada.isNotEmpty ? categoriaSeleccionada : null,
                    items: categorias
                        .map((categoria) => DropdownMenuItem(value: categoria, child: Text(categoria)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => categoriaSeleccionada = value);
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Proveedor'),
                    value: proveedorSeleccionado.isNotEmpty ? proveedorSeleccionado : null,
                    items: proveedores
                        .map((proveedor) => DropdownMenuItem(value: proveedor, child: Text(proveedor)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => proveedorSeleccionado = value);
                      }
                    },
                  ),
                  TextField(
                    controller: laboratorioController,
                    decoration: const InputDecoration(labelText: 'Laboratorio'),
                  ),
                  TextField(
                    controller: presentacionController,
                    decoration: const InputDecoration(labelText: 'Presentación'),
                  ),
                  TextField(
                    controller: fechaController,
                    decoration: const InputDecoration(labelText: 'Fecha de Vencimiento (YYYY-MM-DD)'),
                  ),
                  TextField(
                    controller: precioCompraController,
                    decoration: const InputDecoration(labelText: 'Precio Compra'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: precioVentaController,
                    decoration: const InputDecoration(labelText: 'Precio Venta'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: stockMinimoController,
                    decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: imagenController,
                    decoration: const InputDecoration(labelText: 'Enlace de Imagen (Drive)'),
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
          IconButton(icon: const Icon(Icons.add), onPressed: () => mostrarFormulario()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por descripción...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          busquedaController.clear();
                          filtrarProductos('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: filtrarProductos,
            ),
          ),
        ),
      ),
      body: productosFiltrados.isEmpty
          ? const Center(child: Text('No se encontraron productos'))
          : ListView.builder(
              itemCount: productosFiltrados.length,
              itemBuilder: (context, index) {
                final producto = productosFiltrados[index];
                final urlImagenOriginal = producto['imagen'] as String? ?? '';
                final urlImagenDirecta = convertirEnlaceDriveADirecto(urlImagenOriginal);

                return ListTile(
                  leading: urlImagenOriginal.isNotEmpty
                      ? Image.network(
                          urlImagenDirecta,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(producto['descripcion'] ?? 'Sin nombre'),
                  subtitle: Text(
                      'S/ ${producto['precio_venta'] ?? 0.0} - Stock: ${producto['stock'] ?? 0} - Stock mínimo: ${producto['stock_minimo'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => mostrarFormulario(producto: producto)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarProducto(producto['id'])),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
