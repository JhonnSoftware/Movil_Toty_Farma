import 'package:flutter/material.dart';
import 'dart:async'; // Necesario para Timer
import 'login_page.dart';
import 'usuarios_pages/usuarios_productos.dart';
import 'usuarios_pages/usuarios_carrito.dart';
import 'usuarios_pages/usuarios_perfil.dart';
import 'usuarios_pages/historial_pedidos.dart';
import 'usuarios_pages/sensores_page.dart'; // NUEVA IMPORTACIÓN

class UsuarioMenuPage extends StatefulWidget {
  final String token;
  const UsuarioMenuPage({Key? key, required this.token}) : super(key: key);

  @override
  State<UsuarioMenuPage> createState() => _UsuarioMenuPageState();
}

class _UsuarioMenuPageState extends State<UsuarioMenuPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  Timer? _inactivityTimer;

  final Color verdeLima = const Color(0xFF7eda01);
  final Color azul = const Color(0xFF1489b4);

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      UsuariosProductosPage(userId: widget.token),
      UsuariosCarritoPage(userId: widget.token),
      HistorialPedidosPage(userId: widget.token),
      UsuarioPerfilPage(userId: widget.token),
      SensoresPage(), // NUEVA PÁGINA AGREGADA
    ];
    _resetInactivityTimer(); // Inicia el temporizador al entrar
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _resetInactivityTimer(); // Reinicia al cambiar de sección
  }

  void _cerrarSesion() {
    _inactivityTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: verdeLima,
          title: Row(
            children: [
              Image.asset(
                'assets/images/icon.png',
                height: 35,
              ),
              const SizedBox(width: 10),
              const Text(
                'Botica - Usuario',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: _cerrarSesion,
            )
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: verdeLima,
          unselectedItemColor: azul,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: 'Productos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Carrito',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors), // Icono para sensores
              label: 'Sensor',
            ),
          ],
        ),
      ),
    );
  }
}
