import 'package:flutter/material.dart';
import '../pages/clientes_page.dart';
import '../pages/proveedores_page.dart';
import '../pages/categorias_page.dart';
import '../pages/productos_page.dart';

class HomePage extends StatefulWidget {
  final String? token;

  const HomePage({Key? key, this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    Center(child: Text('Inicio', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    //ClientesPage(),
    ClientesPage(),
    ProveedoresPage(),
    CategoriasPage(),
    Center(child: Text('Productos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    Center(child: Text('Usuarios', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    Center(child: Text('Flujo de caja', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    Center(child: Text('Registrar Compra', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    Center(child: Text('Historial Compras', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    Center(child: Text('Registrar Venta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    Center(child: Text('Historial Ventas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Color verdeLima = Color(0xFF7eda01);
  final Color azul = Color(0xFF1489b4);
  final Color fondoDrawer = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verdeLima,
        title: Text(
          'Menú Principal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 6,
        shadowColor: azul.withOpacity(0.5),
      ),
      drawer: Drawer(
        child: Container(
          color: fondoDrawer,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [verdeLima, azul],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  'Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: Text(
                  'token: ${widget.token ?? "No token"}',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: verdeLima),
                ),
              ),

              _drawerListTile(
                icon: Icons.home,
                title: 'Inicio',
                index: 0,
                selected: _selectedIndex == 0,
              ),

              _drawerExpansionTile(
                icon: Icons.manage_accounts,
                title: 'Administración',
                children: [
                  _drawerListTile(
                    icon: Icons.people,
                    title: 'Usuarios',
                    index: 5,
                    selected: _selectedIndex == 5,
                  ),
                  _drawerListTile(
                    icon: Icons.attach_money,
                    title: 'Flujo de caja',
                    index: 6,
                    selected: _selectedIndex == 6,
                  ),
                ],
              ),

              _drawerListTile(
                icon: Icons.people_alt,
                title: 'Clientes',
                index: 1,
                selected: _selectedIndex == 1,
              ),
              _drawerListTile(
                icon: Icons.local_shipping,
                title: 'Proveedores',
                index: 2,
                selected: _selectedIndex == 2,
              ),
              _drawerListTile(
                icon: Icons.category,
                title: 'Categorías',
                index: 3,
                selected: _selectedIndex == 3,
              ),
              _drawerListTile(
                icon: Icons.shopping_bag,
                title: 'Productos',
                index: 4,
                selected: _selectedIndex == 4,
              ),

              _drawerExpansionTile(
                icon: Icons.shopping_cart,
                title: 'Compras',
                children: [
                  _drawerListTile(
                    icon: Icons.add_shopping_cart,
                    title: 'Registrar Compra',
                    index: 7,
                    selected: _selectedIndex == 7,
                  ),
                  _drawerListTile(
                    icon: Icons.history,
                    title: 'Historial Compras',
                    index: 8,
                    selected: _selectedIndex == 8,
                  ),
                ],
              ),

              _drawerExpansionTile(
                icon: Icons.point_of_sale,
                title: 'Ventas',
                children: [
                  _drawerListTile(
                    icon: Icons.add_shopping_cart,
                    title: 'Registrar Venta',
                    index: 9,
                    selected: _selectedIndex == 9,
                  ),
                  _drawerListTile(
                    icon: Icons.history,
                    title: 'Historial Ventas',
                    index: 10,
                    selected: _selectedIndex == 10,
                  ),
                ],
              ),

              Divider(thickness: 1.2),
              ListTile(
                leading: Icon(Icons.logout, color: azul),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: azul,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                hoverColor: verdeLima.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _drawerListTile({
    required IconData icon,
    required String title,
    required int index,
    required bool selected,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? azul : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? azul : Colors.black87,
          fontSize: 16,
        ),
      ),
      selected: selected,
      selectedTileColor: azul.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
      hoverColor: azul.withOpacity(0.1),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  Widget _drawerExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: azul),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: azul,
            fontSize: 16,
          ),
        ),
        childrenPadding: EdgeInsets.only(left: 20, bottom: 5),
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        children: children,
        iconColor: verdeLima,
        collapsedIconColor: azul,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        maintainState: true,
      ),
    );
  }
}
