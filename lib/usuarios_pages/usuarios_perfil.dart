import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioPerfilPage extends StatelessWidget {
  final String userId;

  const UsuarioPerfilPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color verdeLima = const Color(0xFF7eda01);
    final Color azul = const Color(0xFF1489b4);

    print('UsuarioPerfilPage recibe userId: $userId'); // DEBUG

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No se encontró la información del usuario.'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  userData['foto'] ?? 'https://i.pravatar.cc/150?u=$userId',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${userData['name']} ${userData['apellido']}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                userData['email'],
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildUserInfoTile(Icons.phone, 'Teléfono', userData['telefono']),
              _buildUserInfoTile(Icons.badge, 'DNI', userData['dni']),
              _buildUserInfoTile(Icons.location_on, 'Dirección', userData['direccion']),
              _buildUserInfoTile(Icons.shield, 'Rol', userData['rol']),
              _buildUserInfoTile(
                Icons.check_circle,
                'Estado',
                userData['estado'] == true ? 'Activo' : 'Inactivo',
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
            ],
          ),
        );
      },
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
