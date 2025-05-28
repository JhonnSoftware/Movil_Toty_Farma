import 'package:flutter/material.dart';
import 'login_page.dart'; // Importa tu página de login

class UsuarioMenuPage extends StatefulWidget {
  final String token;
  const UsuarioMenuPage({Key? key, required this.token}) : super(key: key);

  @override
  State<UsuarioMenuPage> createState() => _UsuarioMenuPageState();
}

class _UsuarioMenuPageState extends State<UsuarioMenuPage> {
  int _selectedIndex = 0;

  // Páginas iniciales (placeholder)
  static final List<Widget> _pages = <Widget>[
    Center(
        child: Text('Catálogo de Productos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(
        child: Text('Carrito de Compras',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(
        child: Text('Historial de Pedidos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(
        child: Text('Perfil de Usuario',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Color verdeLima = Color(0xFF7eda01);
  final Color azul = Color(0xFF1489b4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verdeLima,
        title: Text(
          'Botica - Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
        duration: Duration(milliseconds: 300),
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
