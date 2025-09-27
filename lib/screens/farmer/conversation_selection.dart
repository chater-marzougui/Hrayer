import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../structures/land_models.dart';
import 'chat_sponsors.dart';

class ConversationSelectionScreen extends StatefulWidget {
  const ConversationSelectionScreen({super.key});

  @override
  State<ConversationSelectionScreen> createState() => _ConversationSelectionScreenState();
}

class _ConversationSelectionScreenState extends State<ConversationSelectionScreen> {
  List<LandModel> userLands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserLands();
  }

  Future<void> _loadUserLands() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lands')
          .where('ownerId', isEqualTo: currentUser.uid)
          .where('isActive', isEqualTo: true)
          .get();

      userLands = querySnapshot.docs
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
          SnackBar(content: Text('Error loading your lands: $e')),
        );
      }
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
              builder: (context) => ChatSponsorsScreen(land: land),
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
                        Text(
                          land.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
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
              
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.withAlpha(76)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to open conversation with sponsors',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
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
              onRefresh: _loadUserLands,
              child: userLands.isEmpty
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
                                    'Select a land to start or continue conversation with your sponsors',
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
                          
                          Text(
                            'Your Lands (${userLands.length})',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Expanded(
                            child: ListView.builder(
                              itemCount: userLands.length,
                              itemBuilder: (context, index) {
                                return _buildLandCard(userLands[index]);
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
            'No Conversations Available',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You need to have active lands with sponsors to start conversations.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add land screen
              Navigator.pop(context);
              // Switch to Add Land tab (tab index 1)
              // This will be handled by the navigation bar
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Land'),
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