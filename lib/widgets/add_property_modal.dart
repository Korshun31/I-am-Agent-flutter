import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../models/property.dart';

const _propertyTypes = [
  ('resort', '🏘️', Color(0xFFC8E6C9), Color(0xFF81C784)),
  ('house', '🏡', Color(0xFFFFF9C4), Color(0xFFFFD54F)),
  ('condo', '🏢', Color(0xFFBBDEFB), Color(0xFF64B5F6)),
];

class AddPropertyModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final void Function({required String name, required String code, required String type}) onSave;
  final Property? editProperty;

  const AddPropertyModal({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onSave,
    this.editProperty,
  });

  @override
  State<AddPropertyModal> createState() => _AddPropertyModalState();
}

class _AddPropertyModalState extends State<AddPropertyModal> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  late String _type;

  @override
  void initState() {
    super.initState();
    _type = 'house';
  }

  @override
  void didUpdateWidget(AddPropertyModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      if (widget.editProperty != null) {
        _nameController.text = widget.editProperty!.name;
        _codeController.text = widget.editProperty!.code;
        _type = widget.editProperty!.type;
      } else {
        _nameController.clear();
        _codeController.clear();
        _type = 'house';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final lang = context.read<LanguageProvider>();
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    if (name.isEmpty) {
      _showError(lang.t('error'), lang.t('enterPropertyName'));
      return;
    }
    if (code.isEmpty) {
      _showError(lang.t('error'), lang.t('enterPropertyCode'));
      return;
    }
    widget.onSave(name: name, code: code, type: _type);
    widget.onClose();
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
      onTap: () {}, // prevent backdrop tap from closing - use X button
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white54),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    child: Consumer<LanguageProvider>(
                      builder: (_, lang, __) => Text(
                        widget.editProperty != null
                            ? lang.t('editProperty')
                            : lang.t('addProperty'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2C2C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Text('✕', style: TextStyle(fontSize: 20, color: Color(0xFFE85D4C), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Consumer<LanguageProvider>(
                  builder: (_, lang, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        lang.t('propertyType'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _propertyTypes.map((t) {
                          final (key, icon, bgColor, borderColor) = t;
                          final isActive = _type == key;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _type = key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isActive ? bgColor : const Color(0xFFEDEDEB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive ? borderColor : const Color(0xFFD5D5D0),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(icon, style: TextStyle(fontSize: 26, color: isActive ? Colors.black87 : Colors.black38)),
                                      const SizedBox(height: 4),
                                      Text(
                                        lang.t('propertyType_$key'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                                          color: isActive ? const Color(0xFF2C2C2C) : const Color(0xFFAAAAAA),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        lang.t('propertyName'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C2C2C)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: lang.t('propertyNamePlaceholder'),
                          filled: true,
                          fillColor: const Color(0xFFF5F2EB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0D8CC))),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang.t('propertyCode'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C2C2C)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: lang.t('propertyCodePlaceholder'),
                          filled: true,
                          fillColor: const Color(0xFFF5F2EB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0D8CC))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x0F2E7D32),
                          foregroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0x802E7D32)),
                          ),
                        ),
                        child: Text(lang.t('save'), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

