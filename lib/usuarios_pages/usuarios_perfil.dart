import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../usuarios_pages/gpsusuario_page.dart'; // ← Ajusta este import al path correcto

class UsuarioPerfilPage extends StatefulWidget {
  final String userId;

  const UsuarioPerfilPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UsuarioPerfilPage> createState() => _UsuarioPerfilPageState();
}

class _UsuarioPerfilPageState extends State<UsuarioPerfilPage> {
  final Color verdeLima = const Color(0xFF7eda01);
  final Color azul = const Color(0xFF1489b4);

  Map<String, dynamic>? userData;
  bool loading = false;

  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => loading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('name', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userData = snapshot.docs.first.data();
        });
      } else {
        setState(() {
          userData = null;
        });
      }
    } catch (e) {
      print('Error cargando usuario: $e');
      setState(() {
        userData = null;
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileExists = await file.exists();
        final fileLength = await file.length();

        if (fileExists && fileLength > 0) {
          setState(() {
            _selectedImageFile = file;
          });
          _showPreviewDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archivo inválido o vacío.')),
          );
        }
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar imagen')),
      );
    }
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Foto'),
        content: _selectedImageFile == null
            ? const SizedBox.shrink()
            : Image.file(_selectedImageFile!),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedImageFile = null);
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _uploadImageAsBase64AndSave();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImageAsBase64AndSave() async {
    if (_selectedImageFile == null || userData == null) return;

    final fileExists = await _selectedImageFile!.exists();
    final fileLength = await _selectedImageFile!.length();

    if (!fileExists || fileLength == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo de imagen no es válido.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final bytes = await _selectedImageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('name', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userDoc.docs.first.id)
            .update({'foto': base64Image});

        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (e) {
      print('Error subiendo imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen')),
      );
    } finally {
      setState(() {
        loading = false;
        _selectedImageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil de Usuario')),
        body: Center(
          child: Text('No se encontró la información del usuario ${widget.userId}'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: azul,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: userData!['foto'] != null && userData!['foto'].isNotEmpty
                  ? MemoryImage(base64Decode(userData!['foto']))
                  : NetworkImage('https://i.pravatar.cc/150?u=${widget.userId}') as ImageProvider,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeLima,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar de Galería'),
              style: ElevatedButton.styleFrom(
                backgroundColor: azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 24),
            Text(
              '${userData!['name']} ${userData!['apellido']}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userData!['email'] ?? 'Email no disponible',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildUserInfoTile(Icons.phone, 'Teléfono', userData!['telefono']),
            _buildUserInfoTile(Icons.badge, 'DNI', userData!['dni']),
            _buildUserInfoTile(Icons.location_on, 'Dirección', userData!['direccion']),
            _buildUserInfoTile(Icons.shield, 'Rol', userData!['rol']),
            _buildUserInfoTile(
              Icons.check_circle,
              'Estado',
              userData!['estado'] == true ? 'Activo' : 'Inactivo',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de edición aún no implementada')),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Ver GPS de Tienda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeLima,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TiendaGpsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoTile(IconData icon, String label, dynamic value) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value?.toString() ?? 'No disponible'),
    );
  }
}
