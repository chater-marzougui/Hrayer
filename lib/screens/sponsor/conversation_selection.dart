import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../structures/land_models.dart';
import 'chat_farmers.dart';

class SponsorConversationSelectionScreen extends StatefulWidget {
  const SponsorConversationSelectionScreen({super.key});

  @override
  State<SponsorConversationSelectionScreen> createState() => _SponsorConversationSelectionScreenState();
}

class _SponsorConversationSelectionScreenState extends State<SponsorConversationSelectionScreen> {
  List<LandModel> sponsoredLands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSponsoredLands();
  }

  Future<void> _loadSponsoredLands() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lands')
          .where('sponsors', arrayContains: currentUser.uid)
          .where('isActive', isEqualTo: true)
          .get();

      sponsoredLands = querySnapshot.docs
          .map((doc) => LandModel.fromFirestore(doc))
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sponsored lands: $e')),
        );
      }
    }
  }

  Future<String> _getFarmerName(String farmerId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(farmerId)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data()?['name'] ?? 'Unknown Farmer';
      }
      return 'Unknown Farmer';
    } catch (e) {
      return 'Unknown Farmer';
    }
  }

  Future<int> _getUnreadMessageCount(String landId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return 0;

      // For simplicity, we'll just return 0 here
      // In a real app, you might want to track read status
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildLandCard(LandModel land) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatFarmersScreen(land: land),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.primaryColor.withAlpha(76)),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: theme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        FutureBuilder<String>(
                          future: _getFarmerName(land.ownerId),
                          builder: (context, snapshot) {
                            return Text(
                              'By ${snapshot.data ?? 'Loading...'} • ${land.location}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<int>(
                        future: _getUnreadMessageCount(land.id),
                        builder: (context, snapshot) {
                          final unreadCount = snapshot.data ?? 0;
                          if (unreadCount > 0) {
                            return Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      land.intendedCrop,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${land.size} hectares',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${land.sponsors.length} sponsors',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              LinearProgressIndicator(
                value: land.progressPercentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${land.progressPercentage.toStringAsFixed(0)}% funded',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '\$${land.totalFulfilled.toStringAsFixed(0)} / \$${land.totalNeeded.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withAlpha(76)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          size: 12,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Supporting',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.withAlpha(76)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 12,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to chat',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        title: const Text('Select Conversation'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSponsoredLands,
              child: sponsoredLands.isEmpty
                  ? _buildEmptyState()
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.primaryColor.withAlpha(76)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Select a project to start or continue conversation with the farmer and other sponsors',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Projects You Support (${sponsoredLands.length})',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.withAlpha(76)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.volunteer_activism,
                                      size: 14,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Active Sponsor',
                                      style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Expanded(
                            child: ListView.builder(
                              itemCount: sponsoredLands.length,
                              itemBuilder: (context, index) {
                                return _buildLandCard(sponsoredLands[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Conversations',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You need to sponsor projects to start conversations with farmers.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to land list screen
              Navigator.pop(context);
              // Switch to Lands tab (tab index 1)
              // This will be handled by the navigation bar
            },
            icon: const Icon(Icons.volunteer_activism),
            label: const Text('Find Projects to Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}