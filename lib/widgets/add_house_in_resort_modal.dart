import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class AddHouseInResortModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final void Function({required String name, required String codeSuffix}) onSave;
  final String resortCode;

  const AddHouseInResortModal({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onSave,
    required this.resortCode,
  });

  @override
  State<AddHouseInResortModal> createState() => _AddHouseInResortModalState();
}

class _AddHouseInResortModalState extends State<AddHouseInResortModal> {
  final _nameController = TextEditingController();
  final _codeSuffixController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeSuffixController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final lang = context.read<LanguageProvider>();
    final name = _nameController.text.trim();
    final codeSuffix = _codeSuffixController.text.trim();

    if (name.isEmpty) {
      _showError(lang.t('error'), lang.t('enterPropertyName'));
      return;
    }
    widget.onSave(name: name, codeSuffix: codeSuffix);
    widget.onClose();
    _nameController.clear();
    _codeSuffixController.clear();
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.read<LanguageProvider>().t('back')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {},
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Consumer<LanguageProvider>(
          builder: (_, lang, __) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lang.t('addProperty'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Color(0xFFE85D4C)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${lang.t('propertyCode')}: ${widget.resortCode}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: lang.t('propertyName'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeSuffixController,
                decoration: InputDecoration(
                  labelText: lang.t('wizInternalCodeSuffix'),
                  hintText: '72-А',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5DB87A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(lang.t('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
