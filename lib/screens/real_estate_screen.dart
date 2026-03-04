import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../models/property.dart';
import '../services/properties_service.dart';
import '../widgets/add_property_modal.dart';
import 'property_detail_screen.dart';

const _typeColors = {
  'resort': (Color(0xB2A8E6A3), Color(0xFFA8E6A3)),
  'house': (Color(0xFFFFF9C4), Color(0xFFFFD54F)),
  'condo': (Color(0xFFBBDEFB), Color(0xFF64B5F6)),
};

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  List<Property> _properties = [];
  bool _loading = true;
  String _searchQuery = '';
  bool _addModalVisible = false;
  Set<String> _expandedIds = {};
  Property? _selectedProperty;
  Property? _backTarget;

  Future<void> _loadProperties() async {
    setState(() => _loading = true);
    try {
      final list = await getProperties();
      setState(() {
        _properties = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _navigateToProperty(Property? p) {
    setState(() {
      _backTarget = _selectedProperty;
      _selectedProperty = p;
    });
  }

  void _handleBack() {
    setState(() {
      _selectedProperty = _backTarget;
      _backTarget = null;
    });
  }

  Future<void> _handleSaveProperty({
    required String name,
    required String code,
    required String type,
  }) async {
    final lang = context.read<LanguageProvider>();
    try {
      await createProperty(name: name, code: code, type: type);
      if (mounted) setState(() => _addModalVisible = false);
      _loadProperties();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(lang.t('error')),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(lang.t('back')),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleDeleteProperty(Property prop) {
    final lang = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.t('pdDeleteTitle')),
        content: Text(lang.t('pdDeleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.t('no')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await deleteProperty(prop.id);
                setState(() => _selectedProperty = null);
                _loadProperties();
              } catch (e) {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(lang.t('error')),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c), child: Text(lang.t('back'))),
                      ],
                    ),
                  );
                }
              }
            },
            child: Text(lang.t('yes'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedProperty != null) {
      return PropertyDetailScreen(
        property: _selectedProperty!,
        onBack: _handleBack,
        onDelete: () => _handleDeleteProperty(_selectedProperty!),
        onPropertyUpdated: _loadProperties,
        onSelectProperty: _navigateToProperty,
      );
    }

    final topLevel = _properties.where((p) => p.resortId == null).toList();
    final filtered = _searchQuery.trim().isEmpty
        ? topLevel
        : topLevel.where((p) {
            final q = _searchQuery.trim().toLowerCase();
            return p.name.toLowerCase().contains(q) || p.code.toLowerCase().contains(q);
          }).toList();
    final sorted = List<Property>.from(filtered)
      ..sort((a, b) {
        const order = {'resort': 0, 'house': 1, 'condo': 2};
        final diff = (order[a.type] ?? 1) - (order[b.type] ?? 1);
        if (diff != 0) return diff;
        return a.name.compareTo(b.name);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Spacer(),
                  Consumer<LanguageProvider>(
                    builder: (_, lang, __) => Text(
                      lang.t('realEstate'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Text('⚙️')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0D8CC)),
                      ),
                      child: Row(
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Consumer<LanguageProvider>(
                              builder: (_, lang, __) => TextField(
                                onChanged: (v) => setState(() => _searchQuery = v),
                                decoration: InputDecoration(
                                  hintText: lang.t('search'),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _addModalVisible = true),
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_expandedIds.length == sorted.length) {
                          _expandedIds.clear();
                        } else {
                          _expandedIds = sorted.map((p) => p.id).toSet();
                        }
                      });
                    },
                    icon: Icon(
                      _expandedIds.length == sorted.length ? Icons.folder_open : Icons.folder,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF5DB87A)))
                  : sorted.isEmpty
                      ? Center(
                          child: Consumer<LanguageProvider>(
                            builder: (_, lang, __) => Text(
                              lang.t('realEstateEmpty'),
                              style: const TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, bottom: 80),
                          itemCount: sorted.length,
                          itemBuilder: (_, i) => _PropertyItem(
                            item: sorted[i],
                            expanded: _expandedIds.contains(sorted[i].id),
                            onToggle: () {
                              setState(() {
                                final id = sorted[i].id;
                                if (_expandedIds.contains(id)) {
                                  _expandedIds = {..._expandedIds}..remove(id);
                                } else {
                                  _expandedIds = {..._expandedIds, id};
                                }
                              });
                            },
                            onPress: () => _navigateToProperty(sorted[i]),
                          ),
                        ),
            ),
              ],
            ),
          ),
          if (_addModalVisible)
            GestureDetector(
              onTap: () => setState(() => _addModalVisible = false),
              child: Container(color: Colors.black54),
            ),
          if (_addModalVisible)
            Center(
              child: AddPropertyModal(
                visible: _addModalVisible,
                onClose: () => setState(() => _addModalVisible = false),
                onSave: ({required name, required code, required type}) {
                  _handleSaveProperty(name: name, code: code, type: type);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _PropertyItem extends StatelessWidget {
  final Property item;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onPress;

  const _PropertyItem({
    required this.item,
    required this.expanded,
    required this.onToggle,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor) = _typeColors[item.type] ?? _typeColors['house']!;

    return Consumer<LanguageProvider>(
      builder: (_, lang, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onPress,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(_iconForType(item.type), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD81B60),
                      ),
                    ),
                    IconButton(
                      onPressed: onToggle,
                      icon: Icon(
                        expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: item.photos?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(item.photos!.first, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.photo, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(lang.t('propDistrict'), item.district ?? '—'),
                          if (item.type == 'resort') _detailRow(lang.t('propHouses'), item.housesCount != null ? '${item.housesCount} pc' : '—'),
                          if (item.type == 'house') _detailRow(lang.t('propBedrooms'), item.bedrooms?.toString() ?? '—'),
                          if (item.type == 'condo') _detailRow(lang.t('propFloors'), item.floors?.toString() ?? '—'),
                          _detailRow(lang.t('propBeach'), item.beachDistance != null ? '${item.beachDistance} m' : '—'),
                          _detailRow(lang.t('propMarket'), item.marketDistance != null ? '${item.marketDistance} m' : '—'),
                        ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'resort':
        return Icons.apartment;
      case 'condo':
        return Icons.business;
      default:
        return Icons.home;
    }
  }
}
