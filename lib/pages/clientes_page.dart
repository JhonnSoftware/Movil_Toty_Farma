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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();

  String _dniBusqueda = '';

  void _agregarUsuario() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Usuario'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration: const InputDecoration(labelText: 'Teléfono'),
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
                decoration: const InputDecoration(labelText: 'DNI'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (_validarCampos()) {
                _firestore.collection('usuarios').add({
                  'name': _nombreController.text,
                  'apellido': _apellidoController.text,
                  'telefono': int.parse(_telefonoController.text),
                  'direccion': _direccionController.text,
                  'dni': int.parse(_dniController.text),
                  'email': _emailController.text,
                  'password': _passwordController.text,
                  'rol': 'usuario',
                  'foto': '',
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
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(texto);
  }

  bool _validarCampos() {
    if (_nombreController.text.isEmpty || !_soloLetras(_nombreController.text)) {
      _mostrarMensaje('Nombre inválido');
      return false;
    }
    if (_apellidoController.text.isEmpty || !_soloLetras(_apellidoController.text)) {
      _mostrarMensaje('Apellido inválido');
      return false;
    }
    if (_telefonoController.text.length != 9) {
      _mostrarMensaje('El teléfono debe tener 9 dígitos.');
      return false;
    }
    if (_dniController.text.length != 8) {
      _mostrarMensaje('El DNI debe tener 8 dígitos.');
      return false;
    }
    if (_direccionController.text.isEmpty) {
      _mostrarMensaje('La dirección no puede estar vacía.');
      return false;
    }
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _mostrarMensaje('Correo inválido');
      return false;
    }
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _mostrarMensaje('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }
    return true;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _apellidoController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _dniController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  void _editarUsuario(DocumentSnapshot usuario) {
    _nombreController.text = usuario['name'];
    _apellidoController.text = usuario['apellido'];
    _telefonoController.text = usuario['telefono'].toString();
    _direccionController.text = usuario['direccion'];
    _dniController.text = usuario['dni'].toString();
    _emailController.text = usuario['email'];
    _passwordController.text = usuario['password'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration: const InputDecoration(labelText: 'Teléfono'),
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
                decoration: const InputDecoration(labelText: 'DNI'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (_validarCampos()) {
                _firestore.collection('usuarios').doc(usuario.id).update({
                  'name': _nombreController.text,
                  'apellido': _apellidoController.text,
                  'telefono': int.parse(_telefonoController.text),
                  'direccion': _direccionController.text,
                  'dni': int.parse(_dniController.text),
                  'email': _emailController.text,
                  'password': _passwordController.text,
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
      _firestore.collection('usuarios').doc(id).delete();
    }
    _seleccionados.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _seleccionados.isEmpty ? null : _eliminarSeleccionados,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _busquedaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Buscar por DNI',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _dniBusqueda = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('usuarios')
                  .where('rol', isEqualTo: 'usuario')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final usuarios = snapshot.data!.docs.where((usuario) {
                  if (_dniBusqueda.isEmpty) return true;
                  return usuario['dni'].toString().contains(_dniBusqueda);
                }).toList();

                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    var usuario = usuarios[index];
                    var isSelected = _seleccionados.contains(usuario.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _seleccionados.add(usuario.id);
                              } else {
                                _seleccionados.remove(usuario.id);
                              }
                            });
                          },
                        ),
                        title: Text('${usuario['name']} ${usuario['apellido']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DNI: ${usuario['dni']}'),
                            Text('Teléfono: ${usuario['telefono']}'),
                            Text('Dirección: ${usuario['direccion']}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Switch(
                                  value: usuario['estado'],
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                  onChanged: (value) {
                                    _firestore.collection('usuarios').doc(usuario.id).update({'estado': value});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarUsuario(usuario),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarUsuario,
        child: const Icon(Icons.add),
      ),
    );
  }
}
