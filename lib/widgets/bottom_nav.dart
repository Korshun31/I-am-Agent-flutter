import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../assets/app_assets.dart';
import '../providers/language_provider.dart';

const _tabColors = [
  Color(0xE6FFE066), // base - yellow
  Color(0xE66FCF97), // bookings - green
  Color(0xE656CCF2), // calendar - blue
  Color(0xE6EB5757), // account - red
];

const _tabKeys = ['base', 'bookings', 'calendar', 'myAccount'];

class BottomNav extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onSelect;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (_, lang, __) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Row(
          children: List.generate(4, (index) {
            final isActive = activeTab == index;
            final color = _tabColors[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(left: index > 0 ? -22 : 0),
                  height: isActive ? 62 : 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(index == 0 ? 20 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isActive ? 0.14 : 0.08),
                        offset: Offset(0, isActive ? 2 : 1),
                        blurRadius: isActive ? 5 : 3,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isActive
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(_iconPathForIndex(index), width: 28, height: 28, fit: BoxFit.contain),
                            const SizedBox(height: 4),
                            Text(
                              lang.t(_tabKeys[index]),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2C2C),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : Image.asset(_iconPathForIndex(index), width: 28, height: 28, fit: BoxFit.contain),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _iconPathForIndex(int i) {
    switch (i) {
      case 0:
        return AppAssets.base;
      case 1:
        return AppAssets.bookings;
      case 2:
        return AppAssets.calendar;
      case 3:
        return AppAssets.account;
      default:
        return AppAssets.base;
    }
  }
}
