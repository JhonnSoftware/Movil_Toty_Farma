import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _seleccionados = [];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();

  void _agregarCliente() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
              ),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
              ),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration:
                    const InputDecoration(labelText: 'Teléfono (9 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration:
                    const InputDecoration(labelText: 'DNI (8 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                _firestore.collection('clientes').add({
                  'nombre': _nombreController.text,
                  'apellido': _apellidoController.text,
                  'telefono': int.parse(_telefonoController.text),
                  'direccion': _direccionController.text,
                  'dni': int.parse(_dniController.text),
                  'estado': true,
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

  bool _soloLetras(String texto) {
    final RegExp regex = RegExp(r'^[a-zA-Z\s]+$');
    return regex.hasMatch(texto);
  }

  bool _validarCampos() {
    if (_nombreController.text.isEmpty ||
        !_soloLetras(_nombreController.text)) {
      _mostrarMensaje('El nombre solo debe contener letras.');
      return false;
    }

    if (_apellidoController.text.isEmpty ||
        !_soloLetras(_apellidoController.text)) {
      _mostrarMensaje('El apellido solo debe contener letras.');
      return false;
    }

    if (_dniController.text.length != 8) {
      _mostrarMensaje('El DNI debe tener 8 dígitos.');
      return false;
    }

    if (_telefonoController.text.length != 9) {
      _mostrarMensaje('El teléfono debe tener 9 dígitos.');
      return false;
    }

    if (_direccionController.text.isEmpty) {
      _mostrarMensaje('La dirección no puede estar vacía.');
      return false;
    }

    return true;
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _apellidoController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _dniController.clear();
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _editarCliente(DocumentSnapshot cliente) {
    _nombreController.text = cliente['nombre'];
    _apellidoController.text = cliente['apellido'];
    _telefonoController.text = cliente['telefono'].toString();
    _direccionController.text = cliente['direccion'];
    _dniController.text = cliente['dni'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cliente'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
              ),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
              ),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration:
                    const InputDecoration(labelText: 'Teléfono (9 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration:
                    const InputDecoration(labelText: 'DNI (8 dígitos)'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                _firestore.collection('clientes').doc(cliente.id).update({
                  'nombre': _nombreController.text,
                  'apellido': _apellidoController.text,
                  'telefono': int.parse(_telefonoController.text),
                  'direccion': _direccionController.text,
                  'dni': int.parse(_dniController.text),
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
      _firestore.collection('clientes').doc(id).delete();
    }
    _seleccionados.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _seleccionados.isEmpty ? null : _eliminarSeleccionados,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('clientes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clientes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              var cliente = clientes[index];
              var isSelected = _seleccionados.contains(cliente.id);

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _seleccionados.add(cliente.id);
                        } else {
                          _seleccionados.remove(cliente.id);
                        }
                      });
                    },
                  ),
                  title: Text(
                      '${cliente['nombre']} ${cliente['apellido']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DNI: ${cliente['dni']}'),
                      Text('Teléfono: ${cliente['telefono']}'),
                      Text('Dirección: ${cliente['direccion']}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Switch(
                            value: cliente['estado'],
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            onChanged: (value) {
                              _firestore
                                  .collection('clientes')
                                  .doc(cliente.id)
                                  .update({'estado': value});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editarCliente(cliente),
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
        onPressed: _agregarCliente,
        child: const Icon(Icons.add),
      ),
    );
  }
}
