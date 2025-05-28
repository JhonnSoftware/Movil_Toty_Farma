import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color fondo = Color(0xFF040240);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Admins'),
        backgroundColor: fondo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('rol', isEqualTo: 'admin') // 🔎 Solo admins
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error al cargar'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final usuarios = snapshot.data!.docs;

          return ListView.builder(
            itemCount: usuarios.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              final data = usuario.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: data['foto'] != null
                        ? NetworkImage(data['foto'])
                        : null,
                    child: data['foto'] == null ? Icon(Icons.person) : null,
                  ),
                  title: Text('${data['name']} ${data['apellido']}'),
                  subtitle: Text('Correo: ${data['email']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditarUsuarioDialog(
                          userId: usuario.id,
                          userData: data,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CrearUsuarioAdminDialog(),
          );
        },
        backgroundColor: fondo,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class EditarUsuarioDialog extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditarUsuarioDialog({required this.userId, required this.userData});

  @override
  State<EditarUsuarioDialog> createState() => _EditarUsuarioDialogState();
}

class _EditarUsuarioDialogState extends State<EditarUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;
  late TextEditingController telefonoController;
  late TextEditingController direccionController;
  String rolSeleccionado = 'admin';
  File? _imagenSeleccionada;

  final List<String> roles = ['usuario', 'empleado', 'admin', 'superadmin'];

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.userData['name']);
    apellidoController = TextEditingController(text: widget.userData['apellido']);
    emailController = TextEditingController(text: widget.userData['email']);
    telefonoController = TextEditingController(text: widget.userData['telefono']);
    direccionController = TextEditingController(text: widget.userData['direccion']);
    rolSeleccionado = widget.userData['rol'];
  }

  Future<String?> subirImagen(File imagen) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('fotos_usuarios/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }

  Future<void> guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      String? urlFoto;

      if (_imagenSeleccionada != null) {
        urlFoto = await subirImagen(_imagenSeleccionada!);
      }

      await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).update({
        'name': nombreController.text,
        'apellido': apellidoController.text,
        'email': emailController.text,
        'telefono': telefonoController.text,
        'direccion': direccionController.text,
        'rol': rolSeleccionado,
        if (urlFoto != null) 'foto': urlFoto,
      });

      Navigator.of(context).pop();
    }
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imagenSeleccionada = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Admin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: seleccionarImagen,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _imagenSeleccionada != null
                      ? FileImage(_imagenSeleccionada!)
                      : (widget.userData['foto'] != null
                          ? NetworkImage(widget.userData['foto'])
                          : null) as ImageProvider?,
                  child: _imagenSeleccionada == null && widget.userData['foto'] == null
                      ? Icon(Icons.add_a_photo)
                      : null,
                ),
              ),
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Correo'),
              ),
              TextFormField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
              ),
              DropdownButtonFormField<String>(
                value: rolSeleccionado,
                items: roles.map((rol) {
                  return DropdownMenuItem(value: rol, child: Text(rol));
                }).toList(),
                onChanged: (nuevoRol) {
                  if (nuevoRol != null) {
                    setState(() {
                      rolSeleccionado = nuevoRol;
                    });
                  }
                },
                decoration: InputDecoration(labelText: 'Rol'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: guardarCambios,
          child: Text('Guardar'),
        ),
      ],
    );
  }
}

class CrearUsuarioAdminDialog extends StatefulWidget {
  @override
  State<CrearUsuarioAdminDialog> createState() => _CrearUsuarioAdminDialogState();
}

class _CrearUsuarioAdminDialogState extends State<CrearUsuarioAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();
  File? _imagenSeleccionada;

  Future<String?> subirImagen(File imagen) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('fotos_usuarios/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }

  Future<void> crearUsuario() async {
    if (_formKey.currentState!.validate()) {
      String? urlFoto;
      if (_imagenSeleccionada != null) {
        urlFoto = await subirImagen(_imagenSeleccionada!);
      }

      await FirebaseFirestore.instance.collection('usuarios').add({
        'name': nombreController.text,
        'apellido': apellidoController.text,
        'email': emailController.text,
        'telefono': telefonoController.text,
        'direccion': direccionController.text,
        'rol': 'admin', // 👑 Rol fijo
        'foto': urlFoto,
      });

      Navigator.of(context).pop();
    }
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imagenSeleccionada = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nuevo Admin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: seleccionarImagen,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _imagenSeleccionada != null
                      ? FileImage(_imagenSeleccionada!)
                      : null,
                  child: _imagenSeleccionada == null ? Icon(Icons.add_a_photo) : null,
                ),
              ),
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Correo'),
              ),
              TextFormField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: crearUsuario,
          child: Text('Crear'),
        ),
      ],
    );
  }
}
