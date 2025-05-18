import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _seleccionadas = [];

  final TextEditingController _nombreController = TextEditingController();

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _agregarCategoria() {
    _nombreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
          controller: _nombreController,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nombre = _nombreController.text.trim();
              if (nombre.isEmpty) {
                _mostrarMensaje('El nombre no puede estar vacío.');
                return;
              }

              _firestore.collection('categorias').add({
                'nombre': nombre,
                'estado': true,
              });

              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarCategoria(DocumentSnapshot categoria) {
    _nombreController.text = categoria['nombre'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoría'),
        content: TextField(
          controller: _nombreController,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nuevoNombre = _nombreController.text.trim();
              if (nuevoNombre.isEmpty) {
                _mostrarMensaje('El nombre no puede estar vacío.');
                return;
              }

              _firestore.collection('categorias').doc(categoria.id).update({
                'nombre': nuevoNombre,
              });

              Navigator.pop(context);
            },
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  void _eliminarSeleccionadas() {
    for (var id in _seleccionadas) {
      _firestore.collection('categorias').doc(id).delete();
    }
    _seleccionadas.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _seleccionadas.isEmpty ? null : _eliminarSeleccionadas,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categorias').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categorias = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              final isSelected = _seleccionadas.contains(categoria.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _seleccionadas.add(categoria.id);
                        } else {
                          _seleccionadas.remove(categoria.id);
                        }
                      });
                    },
                  ),
                  title: Text(categoria['nombre']),
                  subtitle: Row(
                    children: [
                      const Text('Estado:'),
                      Switch(
                        value: categoria['estado'],
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        onChanged: (value) {
                          _firestore.collection('categorias').doc(categoria.id).update({
                            'estado': value,
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarCategoria(categoria),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCategoria,
        child: const Icon(Icons.add),
      ),
    );
  }
}
