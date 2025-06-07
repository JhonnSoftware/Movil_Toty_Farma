import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagoPage extends StatefulWidget {
  final String userId;
  final double total;
  final QuerySnapshot productosSnapshot;

  const PagoPage({
    Key? key,
    required this.userId,
    required this.total,
    required this.productosSnapshot,
  }) : super(key: key);

  @override
  State<PagoPage> createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _procesarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final pedidoData = {
      'userId': widget.userId,
      'total': widget.total,
      'fecha': Timestamp.now(),
      'productos': widget.productosSnapshot.docs.map((doc) => doc.data()).toList(),
    };

    await FirebaseFirestore.instance.collection('pedidos').add(pedidoData);

    final carritoRef = FirebaseFirestore.instance.collection('carritos').doc(widget.userId);
    final productosRef = carritoRef.collection('productos');

    for (var doc in widget.productosSnapshot.docs) {
      await productosRef.doc(doc.id).delete();
    }

    await carritoRef.update({'totalItems': 0, 'totalPrecio': 0});

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra realizada con éxito')),
      );
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Widget _buildResumenDeCompra() {
    return Card(
      color: const Color(0xFFF2F2F2),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen de Compra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A7ABF))),
            const SizedBox(height: 12),
            ...widget.productosSnapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['imagen'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['nombre'] ?? 'Producto',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(data['descripcion'] ?? '',
                              style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text("S/. ${data['precio_venta']?.toStringAsFixed(2) ?? '0.00'}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6EBF49))),
                Text('S/. ${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF0A7ABF)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF25A6D9), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Confirmar Pago'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A7ABF),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildResumenDeCompra(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Datos de la Tarjeta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A7ABF),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _cardNumberController,
                  label: 'Número de Tarjeta',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.length < 16 ? 'Número inválido' : null,
                ),
                _buildTextField(
                  controller: _cardHolderController,
                  label: 'Nombre del Titular',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _expiryDateController,
                        label: 'Vencimiento (MM/AA)',
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Campo requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _cvvController,
                        label: 'CVV',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.length != 3 ? 'CVV inválido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : _procesarPago,
          icon: const Icon(Icons.lock),
          label: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Pagar Ahora', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EBF49),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
