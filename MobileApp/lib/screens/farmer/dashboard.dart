import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../user_management/add_user.dart';
import 'chat_ai.dart';
import 'famer_main_data.dart';
import 'iot_dashboard.dart';


class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myFarmDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserScreen()),
              );
            },
            tooltip: loc.addUser,
          ),
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatAIScreen()),
              );
            },
          ),
        ],
        backgroundColor: theme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Main Data', // Or use loc.mainData if you add it to localization
            ),
            Tab(
              icon: Icon(Icons.sensors),
              text: 'IoT Sensors', // Or use loc.iotSensors
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MainDataPage(), // Your original dashboard content
          IoTDashboardPage(), // Your IoT dashboard
        ],
      ),
    );
  }
}