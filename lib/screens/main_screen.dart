import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'real_estate_screen.dart';
import 'account_screen.dart';
import 'contacts_screen.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onLogout;

  const MainScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 3; // account tab by default (like RN app)
  String _screenWithinAccount = 'account'; // 'account' | 'contacts'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      body: Stack(
        children: [
          _buildContent(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(
              activeTab: _activeTab,
              onSelect: (index) => setState(() {
                _activeTab = index;
                if (index == 3) _screenWithinAccount = 'account';
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_activeTab == 0) {
      return const RealEstateScreen();
    }
    if (_activeTab == 3) {
      if (_screenWithinAccount == 'contacts') {
        return ContactsScreen(
          onBack: () => setState(() => _screenWithinAccount = 'account'),
        );
      }
      return AccountScreen(
        user: widget.user,
        onLogout: widget.onLogout,
        onOpenContacts: () => setState(() => _screenWithinAccount = 'contacts'),
      );
    }
    // Placeholder for bookings, calendar
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _activeTab == 1 ? 'Bookings' : 'Calendar',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
