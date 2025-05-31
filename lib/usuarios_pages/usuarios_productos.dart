import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsuariosProductosPage extends StatefulWidget {
  final String userId;
  const UsuariosProductosPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UsuariosProductosPage> createState() => _UsuariosProductosPageState();
}

class _UsuariosProductosPageState extends State<UsuariosProductosPage> {
  String searchQuery = '';
  String? selectedCategoria;
  String? selectedLaboratorio;

  final carritoRef = FirebaseFirestore.instance.collection('carritos');

  String getImagenDriveUrl(String urlOriginal) {
    final regex = RegExp(r'd/([^/]+)');
    final match = regex.firstMatch(urlOriginal);
    if (match != null) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    }
    return '';
  }

  Future<void> agregarAlCarrito(Map<String, dynamic> producto) async {
    final userCarritoDoc = carritoRef.doc(widget.userId);
    final productosSubcoleccion = userCarritoDoc.collection('productos');

    final productoDoc = productosSubcoleccion.doc(producto['id'] ?? producto['descripcion']);

    final docSnapshot = await productoDoc.get();

    int nuevaCantidad = 1;
    double precioVenta = (producto['precio_venta'] is int)
        ? (producto['precio_venta'] as int).toDouble()
        : (producto['precio_venta'] ?? 0).toDouble();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      nuevaCantidad = (data['cantidad'] ?? 1) + 1;
    }

    double nuevoSubtotal = nuevaCantidad * precioVenta;

    await productoDoc.set({
      'descripcion': producto['descripcion'],
      'imagen': getImagenDriveUrl(producto['imagen']),
      'precio_venta': precioVenta,
      'cantidad': nuevaCantidad,
      'subtotal': nuevoSubtotal,
    });

    final carritoSnapshot = await userCarritoDoc.get();
    int totalItems = 0;
    double totalPrecio = 0;

    if (carritoSnapshot.exists) {
      final data = carritoSnapshot.data() as Map<String, dynamic>;
      totalItems = (data['totalItems'] ?? 0) + 1;
      totalPrecio = (data['totalPrecio'] ?? 0).toDouble() + precioVenta;
    } else {
      totalItems = 1;
      totalPrecio = precioVenta;
    }

    await userCarritoDoc.set({
      'totalItems': totalItems,
      'totalPrecio': totalPrecio,
    }, SetOptions(merge: true));
  }

  void mostrarConfirmacion(Map<String, dynamic> producto) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Agregar al carrito'),
        content: Text('¿Quieres agregar "${producto['descripcion']}" al carrito?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: Text('Agregar'),
            onPressed: () {
              Navigator.pop(dialogContext); // Cierra primero el diálogo
              agregarAlCarrito(producto).then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Producto añadido al carrito')),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catálogo de Productos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar productos'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final allProductos = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

          final categorias = allProductos
              .map((e) => e['categoria']?.toString())
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .toList();

          final laboratorios = allProductos
              .map((e) => e['laboratorio']?.toString())
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .toList();

          final productosFiltrados = allProductos.where((producto) {
            final nombre = producto['descripcion']?.toString().toLowerCase() ?? '';
            final categoria = producto['categoria']?.toString();
            final laboratorio = producto['laboratorio']?.toString();

            final coincideBusqueda = nombre.contains(searchQuery.toLowerCase());
            final coincideCategoria = selectedCategoria == null || selectedCategoria == categoria;
            final coincideLaboratorio = selectedLaboratorio == null || selectedLaboratorio == laboratorio;

            return coincideBusqueda && coincideCategoria && coincideLaboratorio;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCategoria,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [null, ...categorias].map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat ?? 'Todas'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoria = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedLaboratorio,
                      decoration: InputDecoration(
                        labelText: 'Laboratorio',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [null, ...laboratorios].map((lab) {
                        return DropdownMenuItem<String>(
                          value: lab,
                          child: Text(lab ?? 'Todos'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLaboratorio = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: productosFiltrados.isEmpty
                    ? Center(child: Text('No se encontraron productos'))
                    : GridView.builder(
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];
                          final imagenUrl = getImagenDriveUrl(producto['imagen']);

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      imagenUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image, size: 60),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto['descripcion'] ?? '',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'S/. ${producto['precio_venta']}',
                                        style: TextStyle(color: Colors.green[700]),
                                      ),
                                      Text('Stock: ${producto['stock']}'),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                                    onPressed: () => mostrarConfirmacion(producto),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
