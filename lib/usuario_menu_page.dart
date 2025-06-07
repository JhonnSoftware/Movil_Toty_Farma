import 'package:flutter/material.dart';
import 'login_page.dart'; // Página de login
import 'usuarios_pages/usuarios_productos.dart'; // Página de productos
import 'usuarios_pages/usuarios_carrito.dart'; // Página de carrito
import 'usuarios_pages/usuarios_perfil.dart'; // Página de perfil
import 'usuarios_pages/historial_pedidos.dart'; // Página de historial pedidos

class UsuarioMenuPage extends StatefulWidget {
  final String token; // Token o userId para identificar al usuario
  const UsuarioMenuPage({Key? key, required this.token}) : super(key: key);

  @override
  State<UsuarioMenuPage> createState() => _UsuarioMenuPageState();
}

class _UsuarioMenuPageState extends State<UsuarioMenuPage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  final Color verdeLima = const Color(0xFF7eda01);
  final Color azul = const Color(0xFF1489b4);

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      UsuariosProductosPage(userId: widget.token),  // Página de productos
      UsuariosCarritoPage(userId: widget.token),    // Página de carrito
      HistorialPedidosPage(userId: widget.token),   // Página de historial real
      UsuarioPerfilPage(userId: widget.token),      // Página de perfil
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verdeLima,
        title: const Text(
          'Botica - Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
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
        ],
      ),
    );
  }
}
