import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({Key? key}) : super(key: key);

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int totalAdmins = 0;
  int totalUsuarios = 0;
  int totalCategorias = 0;
  int totalProveedores = 0;
  int totalProductos = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerTotales();
  }

  Future<void> obtenerTotales() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final usuariosSnapshot = await firestore.collection('usuarios').get();
      int admins = 0;
      int usuarios = 0;
      for (var doc in usuariosSnapshot.docs) {
        final data = doc.data();
        var tipo = data['tipo'];
        if (tipo == null) {
          tipo = data['rol'] ?? data['userType'] ?? '';
        }
        final tipoStr = tipo.toString().toLowerCase();
        if (tipoStr == 'admin') admins++;
        else if (tipoStr == 'usuario') usuarios++;
      }

      final categoriasCount = (await firestore.collection('categorias').get()).docs.length;
      final proveedoresCount = (await firestore.collection('proveedores').get()).docs.length;
      final productosCount = (await firestore.collection('productos').get()).docs.length;

      setState(() {
        totalAdmins = admins;
        totalUsuarios = usuarios;
        totalCategorias = categoriasCount;
        totalProveedores = proveedoresCount;
        totalProductos = productosCount;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener totales: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildDashboardCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      shadowColor: color.withOpacity(0.4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.25), color.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 22,
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color.darken(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color colorAdmin = const Color(0xFF0A7ABF);
    final Color colorUsuarios = const Color(0xFF25A6D9);
    final Color colorCategorias = const Color(0xFF6EBF49);
    final Color colorProveedores = const Color(0xFF8BBF65);
    final Color colorProductos = const Color(0xFFF2F2F2);
    final Color fondo = const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: colorAdmin,
        elevation: 5,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/icon.png', // Aquí va tu logo
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  buildDashboardCard(
                    title: 'Admins',
                    count: totalAdmins,
                    icon: Icons.admin_panel_settings,
                    color: colorAdmin,
                  ),
                  const SizedBox(height: 14),
                  buildDashboardCard(
                    title: 'Usuarios',
                    count: totalUsuarios,
                    icon: Icons.person,
                    color: colorUsuarios,
                  ),
                  const SizedBox(height: 14),
                  buildDashboardCard(
                    title: 'Categorías',
                    count: totalCategorias,
                    icon: Icons.category,
                    color: colorCategorias,
                  ),
                  const SizedBox(height: 14),
                  buildDashboardCard(
                    title: 'Proveedores',
                    count: totalProveedores,
                    icon: Icons.local_shipping,
                    color: colorProveedores,
                  ),
                  const SizedBox(height: 14),
                  buildDashboardCard(
                    title: 'Productos',
                    count: totalProductos,
                    icon: Icons.medical_services,
                    color: colorProductos.darken(0.2),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }
}

// Extensión para oscurecer un color
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
