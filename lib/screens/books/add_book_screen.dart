import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/book_provider.dart';
import '../../theme/app_theme.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final isbnController = TextEditingController();
  final quantityController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  
  // State: false = Returned/Available, true = Issued/Unavailable
  bool _isIssued = false; 
  bool _isLoading = false;

  String? _validateNonEmpty(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Enter $field';
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter quantity';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Invalid number';
    if (parsed < 1) return 'Min 1';
    return null;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final book = BookModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      isbn: isbnController.text.trim(),
      quantity: int.parse(quantityController.text.trim()),
      issued: _isIssued, 
    );

    try {
      await context.read<BookProvider>().addBook(book);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    isbnController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                    controller: titleController,
                    label: 'Title',
                    icon: Icons.book,
                    validator: (v) => _validateNonEmpty(v, 'title'),
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    controller: authorController,
                    label: 'Author',
                    icon: Icons.person,
                    validator: (v) => _validateNonEmpty(v, 'author'),
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    controller: isbnController,
                    label: 'ISBN',
                    icon: Icons.qr_code,
                    validator: (v) => _validateNonEmpty(v, 'ISBN'),
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    controller: quantityController,
                    label: 'Quantity',
                    icon: Icons.inventory_2,
                    keyboardType: TextInputType.number,
                    validator: _validateQuantity,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    "Set Initial Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  
                  // CUSTOM DUAL SELECTOR (Issue vs Return)
                  Row(
                    children: [
                      Expanded(
                        child: _statusOption(
                          label: "Return",
                          icon: Icons.assignment_return,
                          isSelected: !_isIssued,
                          activeColor: AppTheme.successColor,
                          onTap: () => setState(() => _isIssued = false),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _statusOption(
                          label: "Issue",
                          icon: Icons.assignment_turned_in,
                          isSelected: _isIssued,
                          activeColor: AppTheme.errorColor,
                          onTap: () => setState(() => _isIssued = true),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  // Helper for the Issue/Return buttons
  Widget _statusOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: isSelected ? activeColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }
}