import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../structures/land_models.dart';
import 'add_land.dart';
import 'proof_upload.dart';
import 'chat_sponsors.dart';
import 'chat_ai.dart';
import '../user_management/add_user.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<LandModel> userLands = [];
  bool isLoading = true;
  double totalEarnings = 0.0;
  int activeLands = 0;

  @override
  void initState() {
    super.initState();
    _loadUserLands();
  }

  Future<void> _loadUserLands() async {
    if (currentUser == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lands')
          .where('ownerId', isEqualTo: currentUser!.uid)
          .get();

      userLands = querySnapshot.docs
          .map((doc) => LandModel.fromFirestore(doc))
          .toList();

      totalEarnings = userLands.fold(0.0, (sum, land) => sum + land.totalFulfilled);
      activeLands = userLands.where((land) => land.isActive).length;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lands: $e')),
        );
      }
    }
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withAlpha(76),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandCard(LandModel land) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        land.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${land.size} hectares • ${land.intendedCrop}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        land.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: land.isFullyFunded
                            ? Colors.green.withAlpha(51)
                            : theme.primaryColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        land.isFullyFunded ? 'Fully Funded' : '${land.progressPercentage.toStringAsFixed(0)}% Funded',
                        style: TextStyle(
                          color: land.isFullyFunded ? Colors.green : theme.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            LinearProgressIndicator(
              value: land.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                land.isFullyFunded ? Colors.green : theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '\$${land.totalFulfilled.toStringAsFixed(0)} of \$${land.totalNeeded.toStringAsFixed(0)} raised',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProofUploadScreen(land: land),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatSponsorsScreen(land: land),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Farm Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserScreen()),
              );
            },
            tooltip: 'Add User',
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUserLands,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      'Active Lands',
                      activeLands.toString(),
                      Icons.terrain,
                      theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      'Total Funding',
                      '\$${totalEarnings.toStringAsFixed(0)}',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      'Total Lands',
                      userLands.length.toString(),
                      Icons.landscape,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickActionButton(
                    'Add Land',
                    Icons.add_location,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddLandScreen(),
                        ),
                      ).then((_) => _loadUserLands());
                    },
                  ),
                  _buildQuickActionButton(
                    'AI Assistant',
                    Icons.psychology,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatAIScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    'Weather',
                    Icons.wb_sunny,
                        () {
                      // TODO: Implement weather screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Weather feature coming soon!')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // My Lands Section
              Text(
                'My Lands',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (userLands.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withAlpha(76)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.agriculture,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No lands registered yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first land to start seeking sponsorship',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddLandScreen(),
                            ),
                          ).then((_) => _loadUserLands());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Land'),
                      ),
                    ],
                  ),
                )
              else
                ...userLands.map((land) => _buildLandCard(land)),
            ],
          ),
        ),
      ),
    );
  }
}