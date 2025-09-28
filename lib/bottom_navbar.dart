import 'package:base_template/screens/user_management/role_selection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'l10n/app_localizations.dart';

// Farmer pages
import 'screens/farmer/dashboard.dart' as farmer;
import 'screens/farmer/add_land.dart';
import 'screens/farmer/chat_ai.dart';
import 'screens/farmer/conversation_selection.dart';
import 'screens/farmer/farms_list.dart';

// Sponsor pages
import 'screens/sponsor/dashboard.dart' as sponsor;
import 'screens/sponsor/land_list.dart';
import 'screens/sponsor/conversation_selection.dart' as sponsor_conv;

// Shared pages
import 'screens/profile_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  static void switchToPage(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomePageState>();
    if (state != null) {
      state._onItemTapped(index);
    }
  }

  @override
  State<BottomNavbar> createState() => _HomePageState();
}

class _HomePageState extends State<BottomNavbar> {
  int _selectedIndex = 0;
  String? role;
  DateTime? lastPressed;

  late List<Widget> _pages;
  late List<Widget> _pageWidgets;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final userRole = doc.data()?['role'] as String?;

    // If role is null, navigate to role selection screen
    if (userRole == null) {
      final result = await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const RoleSelectionScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      if (result == true) {
        _loadUserRole(); // Recursively call to get updated role
        return;
      } else {
        await FirebaseAuth.instance.signOut();
        return;
      }
    }

    setState(() {
      role = userRole;
      _setupPages();
    });
  }

  void _setupPages() {

    final loc = AppLocalizations.of(context)!;
    if (role == "farmer") {
      _pages = [
        const farmer.FarmerDashboard(),
        const AddLandScreen(),
        const FarmsListScreen(),
        const ChatAIScreen(),
        const ConversationSelectionScreen(),
        const ProfileScreen(),
      ];

      _navItems = [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: loc.dashboard),
        BottomNavigationBarItem(
            icon: const Icon(Icons.add_photo_alternate), label: loc.addLand),
        BottomNavigationBarItem(
            icon: Icon(Icons.upload_file), label: loc.proofs),
        BottomNavigationBarItem(
            icon: const Icon(Icons.psychology), label: loc.aiChat),
        BottomNavigationBarItem(
            icon: Icon(Icons.group), label: loc.sponsors),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: loc.profile),
      ];
    } else {
      // sponsor
      _pages = [
        const sponsor.SponsorDashboard(),
        const LandListScreen(),
        const sponsor_conv.SponsorConversationSelectionScreen(),
        const ProfileScreen(),
      ];

      _navItems = [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: loc.dashboard),
        BottomNavigationBarItem(
            icon: Icon(Icons.list_alt), label: loc.lands),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat), label: loc.chats),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: loc.profile),
      ];
    }

    _pageWidgets = _pages.asMap().entries.map((entry) {
      return Offstage(
        offstage: _selectedIndex != entry.key,
        child: TickerMode(
          enabled: _selectedIndex == entry.key,
          child: entry.value,
        ),
      );
    }).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      for (int i = 0; i < _pageWidgets.length; i++) {
        _pageWidgets[i] = Offstage(
          offstage: _selectedIndex != i,
          child: TickerMode(
            enabled: _selectedIndex == i,
            child: _pages[i],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    // Show loading until role is fetched
    if (role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          Fluttertoast.showToast(msg: loc.tapAgainToExit);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: _pageWidgets,
                ),
              ),
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                backgroundColor: theme.cardColor,
                onTap: _onItemTapped,
                selectedItemColor: theme.primaryColor,
                unselectedItemColor: theme.colorScheme.tertiary,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: _navItems,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
