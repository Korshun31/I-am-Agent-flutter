import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../assets/app_assets.dart';
import '../providers/language_provider.dart';
import '../models/property.dart';
import '../services/properties_service.dart';
import '../widgets/add_house_in_resort_modal.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final VoidCallback onPropertyUpdated;
  final void Function(Property p)? onSelectProperty;

  const PropertyDetailScreen({
    super.key,
    required this.property,
    required this.onBack,
    required this.onDelete,
    required this.onPropertyUpdated,
    this.onSelectProperty,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Property _p;
  List<Property> _resortHouses = [];
  Set<String> _expandedHouseIds = {};
  Property? _resort;
  bool _loadingResort = false;
  bool _addHouseModalVisible = false;
  String? _newHouseIdToExpand;

  @override
  void initState() {
    super.initState();
    _p = widget.property;
    if (_p.resortId != null) {
      _loadResort();
    }
    if (_p.type == 'resort') {
      _loadResortHouses();
    }
  }

  Future<void> _loadResort() async {
    if (_p.resortId == null) return;
    setState(() => _loadingResort = true);
    try {
      final all = await getProperties();
      Property? r;
      try {
        r = all.firstWhere((pr) => pr.id == _p.resortId);
      } on StateError {
        r = null;
      }
      setState(() {
        _resort = r;
        _loadingResort = false;
      });
    } catch (_) {
      setState(() => _loadingResort = false);
    }
  }

  Future<void> _loadResortHouses() async {
    if (_p.type != 'resort') return;
    try {
      final all = await getProperties();
      final houses = all.where((h) => h.resortId == _p.id).toList();
      setState(() {
        _resortHouses = houses;
        if (_newHouseIdToExpand != null && houses.any((h) => h.id == _newHouseIdToExpand)) {
          _expandedHouseIds = {..._expandedHouseIds, _newHouseIdToExpand!};
          _newHouseIdToExpand = null;
        }
      });
    } catch (_) {}
  }

  Future<void> _handleAddHouseSave({required String name, required String codeSuffix}) async {
    final lang = context.read<LanguageProvider>();
    try {
      final created = await createPropertyFull({
        'type': 'house',
        'resort_id': _p.id,
        'name': name,
        'code': _p.code,
        'code_suffix': codeSuffix.isEmpty ? null : codeSuffix,
        'city': _p.city,
        'district': _p.district,
        'location_id': _p.locationId,
        'owner_id': _p.ownerId,
      });
      setState(() {
        _addHouseModalVisible = false;
        _newHouseIdToExpand = created.id;
      });
      await _loadResortHouses();
      widget.onPropertyUpdated();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(lang.t('error')),
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(PropertyDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.id != widget.property.id) {
      _p = widget.property;
      _resort = null;
      if (_p.resortId != null) _loadResort();
      if (_p.type == 'resort') _loadResortHouses();
    }
  }

  String get _codeDisplay {
    if (_resort != null) {
      return '${_resort!.code}${_p.codeSuffix != null && _p.codeSuffix!.isNotEmpty ? ' (${_p.codeSuffix})' : ''}';
    }
    return _p.code;
  }

  String? get _city => _p.city ?? _resort?.city;
  String? get _district => _p.district ?? _resort?.district;
  int? get _beachDistance => _p.beachDistance ?? _resort?.beachDistance;
  int? get _marketDistance => _p.marketDistance ?? _resort?.marketDistance;
  String? get _googleMapsLink => _p as dynamic? ?? _resort as dynamic?;
  // For google_maps_link we need a field - Property model doesn't have it. Skip for now.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(_p.name),
        backgroundColor: const Color(0xFFF5F2EB),
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset(AppAssets.pencil, width: 24, height: 24, fit: BoxFit.contain),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset(AppAssets.trash, width: 24, height: 24, fit: BoxFit.contain),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
          _section(
            color: const Color(0x33FFCC00),
            border: const Color(0xFFFFCC00),
            children: [
              _infoRow(context.read<LanguageProvider>().t('propertyCode'), _codeDisplay),
              _infoRow(context.read<LanguageProvider>().t('pdCity'), _city ?? '—'),
              _infoRow(context.read<LanguageProvider>().t('propDistrict'), _district ?? '—'),
              _infoRow(context.read<LanguageProvider>().t('propBedrooms'), _p.bedrooms?.toString() ?? '—'),
              _infoRow(context.read<LanguageProvider>().t('propBeach'), _beachDistance != null ? '${_beachDistance} m' : '—'),
              _infoRow(context.read<LanguageProvider>().t('propMarket'), _marketDistance != null ? '${_marketDistance} m' : '—'),
            ],
          ),
          const SizedBox(height: 12),
          _pricingSection(context),
          if (_p.type == 'resort') ...[
            const SizedBox(height: 12),
            _resortHousesSection(context),
          ],
            ],
          ),
          if (_addHouseModalVisible)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: AddHouseInResortModal(
                visible: _addHouseModalVisible,
                onClose: () => setState(() => _addHouseModalVisible = false),
                onSave: _handleAddHouseSave,
                resortCode: _p.code,
              ),
            ),
        ],
      ),
    );
  }

  Widget _section({
    required Color color,
    required Color border,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pricingSection(BuildContext context) {
    final lang = context.read<LanguageProvider>();
    final sym = lang.currencySymbol;

    return _section(
      color: Colors.white,
      border: const Color(0xFFE0D8CC),
      children: [
        _infoRow(lang.t('pdPriceMonthly'), _p.priceMonthly != null ? '${_p.priceMonthly} $sym' : '—'),
        _infoRow(lang.t('pdBookingDeposit'), _p.bookingDeposit != null ? '${_p.bookingDeposit} $sym' : '—'),
        _infoRow(lang.t('pdSaveDeposit'), _p.saveDeposit != null ? '${_p.saveDeposit} $sym' : '—'),
        _infoRow(lang.t('pdCommission'), _p.commission != null ? '${_p.commission} $sym' : '—'),
        _infoRow(lang.t('pdElectricity'), _p.electricUnit != null ? '${_p.electricUnit} $sym' : '—'),
        _infoRow(lang.t('pdWater'), _p.waterUnit != null ? '${_p.waterUnit} $sym' : '—'),
        _infoRow(lang.t('pdGas'), _p.gasUnit != null ? '${_p.gasUnit} $sym' : '—'),
        _infoRow(lang.t('pdInternetMonth'), _p.internetMonth != null ? '${_p.internetMonth} $sym' : '—'),
        _infoRow(lang.t('pdCleaning'), _p.cleaningPrice != null ? '${_p.cleaningPrice} $sym' : '—'),
        _infoRow(lang.t('pdExitCleaning'), _p.exitCleaningPrice != null ? '${_p.exitCleaningPrice} $sym' : '—'),
      ],
    );
  }

  Widget _resortHousesSection(BuildContext context) {
    final lang = context.read<LanguageProvider>();

    return _section(
      color: const Color(0x33FFCC00),
      border: const Color(0xFFFFCC00),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.t('propHouses'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: () => setState(() => _addHouseModalVisible = true),
              icon: Image.asset(AppAssets.addProperty, width: 28, height: 28, fit: BoxFit.contain),
              tooltip: lang.t('addProperty'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_resortHouses.isEmpty)
          Text(
            lang.t('pdNoHouses'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B), fontStyle: FontStyle.italic),
          )
        else
          ..._resortHouses.map((h) => _resortHouseCard(context, h)),
      ],
    );
  }

  Widget _resortHouseCard(BuildContext context, Property item) {
    final expanded = _expandedHouseIds.contains(item.id);
    final codeDisplay = '${_p.code}${item.codeSuffix != null && item.codeSuffix!.isNotEmpty ? ' (${item.codeSuffix})' : ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onSelectProperty != null ? () => widget.onSelectProperty!(item) : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Image.asset(AppAssets.iconHouse, width: 28, height: 28, fit: BoxFit.contain),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    codeDisplay,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFD81B60)),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_expandedHouseIds.contains(item.id)) {
                          _expandedHouseIds = {..._expandedHouseIds}..remove(item.id);
                        } else {
                          _expandedHouseIds = {..._expandedHouseIds, item.id};
                        }
                      });
                    },
                    icon: Transform.rotate(
                      angle: expanded ? 3.14159 : 0,
                      child: Image.asset(AppAssets.arrowDown, width: 24, height: 24, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(context.read<LanguageProvider>().t('propBedrooms'), item.bedrooms?.toString() ?? '—'),
                  _infoRow(context.read<LanguageProvider>().t('pdArea'), item.area != null ? '${item.area} m2' : '—'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final lang = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.t('pdDeleteTitle')),
        content: Text(lang.t('pdDeleteConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.t('no'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await deleteProperty(_p.id);
                widget.onDelete();
              } catch (e) {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(lang.t('error')),
                      content: Text(e.toString()),
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
}
