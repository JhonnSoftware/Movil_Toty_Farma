import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProveedoresPage extends StatefulWidget {
  const ProveedoresPage({super.key});

  @override
  State<ProveedoresPage> createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _seleccionados = [];

  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  void _agregarProveedor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _rucController,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: const InputDecoration(labelText: 'RUC (11 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration: const InputDecoration(labelText: 'Teléfono (9 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_validarCampos()) {
                _firestore.collection('proveedores').add({
                  'ruc': int.parse(_rucController.text),
                  'nombre': _nombreController.text,
                  'telefono': int.parse(_telefonoController.text),
                  'direccion': _direccionController.text,
                  'correo': _correoController.text,
                  'estado': false,
                });
                _limpiarCampos();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  bool _validarCampos() {
    if (_rucController.text.length != 11) {
      _mostrarMensaje('El RUC debe tener 11 dígitos.');
      return false;
    }
    if (_telefonoController.text.length != 9) {
      _mostrarMensaje('El teléfono debe tener 9 dígitos.');
      return false;
    }
    if (!_correoController.text.contains('@') || !_correoController.text.contains('.')) {
      _mostrarMensaje('Ingresa un correo válido.');
      return false;
    }
    return true;
  }

  void _limpiarCampos() {
    _rucController.clear();
    _nombreController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _correoController.clear();
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _editarProveedor(DocumentSnapshot proveedor) {
    _rucController.text = proveedor['ruc'].toString();
    _nombreController.text = proveedor['nombre'];
    _telefonoController.text = proveedor['telefono'].toString();
    _direccionController.text = proveedor['direccion'];
    _correoController.text = proveedor['correo'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _rucController,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: const InputDecoration(labelText: 'RUC (11 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration: const InputDecoration(labelText: 'Teléfono (9 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_validarCampos()) {
                _firestore.collection('proveedores').doc(proveedor.id).update({
                  'ruc': int.parse(_rucController.text),
                  'nombre': _nombreController.text,
                  'telefono': int.parse(_telefonoController.text),
                  'direccion': _direccionController.text,
                  'correo': _correoController.text,
                });
                _limpiarCampos();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  void _eliminarSeleccionados() {
    for (var id in _seleccionados) {
      _firestore.collection('proveedores').doc(id).delete();
    }
    _seleccionados.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proveedores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _seleccionados.isEmpty ? null : _eliminarSeleccionados,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('proveedores').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final proveedores = snapshot.data!.docs;
          return ListView.builder(
            itemCount: proveedores.length,
            itemBuilder: (context, index) {
              var proveedor = proveedores[index];
              var isSelected = _seleccionados.contains(proveedor.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _seleccionados.add(proveedor.id);
                        } else {
                          _seleccionados.remove(proveedor.id);
                        }
                      });
                    },
                  ),
                  title: Text(proveedor['nombre']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RUC: ${proveedor['ruc']}'),
                      Text('Teléfono: ${proveedor['telefono']}'),
                      Text('Dirección: ${proveedor['direccion']}'),
                      Text('Correo: ${proveedor['correo']}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Switch(
                            value: proveedor['estado'],
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            onChanged: (value) {
                              _firestore
                                  .collection('proveedores')
                                  .doc(proveedor.id)
                                  .update({'estado': value});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editarProveedor(proveedor),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarProveedor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
