import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final apellido = _apellidoController.text.trim();
    final dni = _dniController.text.trim();
    final telefono = _telefonoController.text.trim();
    final direccion = _direccionController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if ([name, apellido, dni, telefono, direccion, email, password]
        .any((element) => element.isEmpty)) {
      setState(() {
        _message = 'Por favor completa todos los campos';
      });
      return;
    }

    if (dni.length != 8 || telefono.length != 9) {
      setState(() {
        _message = 'DNI debe tener 8 dígitos y teléfono 9 dígitos';
      });
      return;
    }

    try {
      final existing = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() {
          _message = 'El correo ya está registrado';
        });
        return;
      }

      await FirebaseFirestore.instance.collection('usuarios').add({
        'name': name,
        'apellido': apellido,
        'dni': dni,
        'telefono': telefono,
        'direccion': direccion,
        'email': email,
        'password': password,
        'rol': 'usuario',
        'estado': true, // ← CORREGIDO a booleano
        'foto': '',
      });

      setState(() {
        _message = 'Cuenta creada correctamente';
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _message = 'Error al registrar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color fondo = Color(0xFF040240);
    final Color acento = Color(0xFFD7F205);

    return Scaffold(
      backgroundColor: fondo,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.app_registration, size: 60, color: fondo),
                  SizedBox(height: 12),
                  Text(
                    'Crear una cuenta',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: fondo),
                  ),
                  SizedBox(height: 28),
                  _buildInputField(
                    _nameController,
                    Icons.person,
                    'Nombre',
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
                    ],
                  ),
                  _buildInputField(
                    _apellidoController,
                    Icons.person_outline,
                    'Apellido',
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
                    ],
                  ),
                  _buildInputField(
                    _dniController,
                    Icons.badge,
                    'DNI',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                  ),
                  _buildInputField(
                    _telefonoController,
                    Icons.phone,
                    'Teléfono',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
                  _buildInputField(
                    _direccionController,
                    Icons.home,
                    'Dirección',
                    keyboardType: TextInputType.streetAddress,
                  ),
                  _buildInputField(
                    _emailController,
                    Icons.email,
                    'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildInputField(
                    _passwordController,
                    Icons.lock,
                    'Contraseña',
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acento,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 6,
                    ),
                    icon: Icon(Icons.check),
                    label: Text('Registrarse', style: TextStyle(fontSize: 16)),
                    onPressed: _register,
                  ),
                  SizedBox(height: 14),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fondo,
                      side: BorderSide(color: fondo),
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Volver al login'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _message.contains('Error') || _message.contains('correo')
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    IconData icon,
    String label, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
