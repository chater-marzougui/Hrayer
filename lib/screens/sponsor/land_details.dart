import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../structures/land_models.dart';
import 'chat_farmers.dart';
import 'image_viewer.dart';

class LandDetailsScreen extends StatefulWidget {
  final LandModel land;

  const LandDetailsScreen({required this.land, super.key});

  @override
  State<LandDetailsScreen> createState() => _LandDetailsScreenState();
}

class _LandDetailsScreenState extends State<LandDetailsScreen> {
  List<LandUpdateModel> updates = [];
  bool isLoading = true;
  bool isSponsoring = false;
  late LandModel currentLand;
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    currentLand = widget.land;
    _pageController = PageController();
    _loadUpdates();
  }

  Future<void> _loadUpdates() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lands')
          .doc(widget.land.id)
          .collection('updates')
          .orderBy('timestamp', descending: true)
          .get();

      updates = querySnapshot.docs
          .map((doc) => LandUpdateModel.fromFirestore(doc))
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sponsorProject(double amount) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      isSponsoring = true;
    });

    try {
      // Update the land document
      final landRef = FirebaseFirestore.instance.collection('lands').doc(widget.land.id);

      await landRef.update({
        'sponsors': FieldValue.arrayUnion([currentUser.uid]),
        'fulfilled.Sponsor Contribution': FieldValue.increment(amount),
      });

      // Add a system message to the chat
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.land.id)
          .collection('messages')
          .add({
        'landId': widget.land.id,
        'senderId': 'system',
        'senderName': 'System',
        'senderRole': 'system',
        'text': '🎉 New sponsor joined! A generous contribution of \$${amount.toStringAsFixed(0)} has been made to support this project.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Reload land data
      final updatedDoc = await landRef.get();
      if (updatedDoc.exists) {
        setState(() {
          currentLand = LandModel.fromFirestore(updatedDoc);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your sponsorship!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing sponsorship: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSponsoring = false;
        });
      }
    }
  }

  void _showSponsorDialog() {
    final theme = Theme.of(context);
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sponsor ${currentLand.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help this project reach its funding goal!',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Funding Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: currentLand.progressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remaining: \$${(currentLand.totalNeeded - currentLand.totalFulfilled).toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sponsorship Amount (\$)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 16),
            // Quick amount buttons
            Text(
              'Quick amounts:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [25, 50, 100, 250, 500].map((amount) {
                return ElevatedButton(
                  onPressed: () {
                    amountController.text = amount.toString();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor.withAlpha(51),
                    foregroundColor: theme.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text('\$$amount'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _sponsorProject(amount);
              }
            },
            child: const Text('Sponsor Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  currentLand.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: currentLand.isFullyFunded
                      ? Colors.green.withAlpha(51)
                      : theme.primaryColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentLand.isFullyFunded ? 'FULLY FUNDED' : 'SEEKING FUNDING',
                  style: TextStyle(
                    color: currentLand.isFullyFunded ? Colors.green : theme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildInfoItem(Icons.location_on, 'Location', currentLand.location),
              const SizedBox(width: 20),
              _buildInfoItem(Icons.landscape, 'Size', '${currentLand.size} hectares'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(Icons.grass, 'Crop', currentLand.intendedCrop),
              const SizedBox(width: 20),
              _buildInfoItem(Icons.people, 'Sponsors', '${currentLand.sponsors.length}'),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentLand.description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.primaryColor),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Funding Progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentLand.progressPercentage.toStringAsFixed(1)}% Complete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              Text(
                '\$${currentLand.totalFulfilled.toStringAsFixed(0)} of \$${currentLand.totalNeeded.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: currentLand.progressPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              currentLand.isFullyFunded ? Colors.green : theme.primaryColor,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 16),

          if (currentLand.needs.isNotEmpty) ...[
            Text(
              'Funding Breakdown',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...currentLand.needs.entries.map((entry) {
              final needed = entry.value;
              final fulfilled = currentLand.fulfilled[entry.key] ?? 0;
              final progress = needed > 0 ? (fulfilled / needed) * 100 : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${fulfilled.toStringAsFixed(0)} / \$${needed.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 100 ? Colors.green : theme.primaryColor,
                      ),
                      minHeight: 4,
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildUpdateCard(LandUpdateModel update) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getUpdateTypeColor(update.updateType).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    update.updateType.toUpperCase(),
                    style: TextStyle(
                      color: _getUpdateTypeColor(update.updateType),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(update.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              update.note,
              style: theme.textTheme.bodyMedium,
            ),
            if (update.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${update.images.length} photo${update.images.length != 1 ? 's' : ''} attached',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getUpdateTypeColor(String type) {
    switch (type) {
      case 'milestone':
        return Colors.green;
      case 'issue':
        return Colors.red;
      case 'harvest':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAlreadySponsored = currentLand.sponsors.contains(currentUser?.uid);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatFarmersScreen(land: currentLand),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project image placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primaryColor.withAlpha(76)),
              ),
              child: currentLand.images.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 64,
                      color: theme.primaryColor.withAlpha(128),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No photos available',
                      style: TextStyle(
                        color: theme.primaryColor.withAlpha(128),
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
                : Stack(
                  children: [
                    // PageView for swipeable images
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: currentLand.images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _openImageViewer(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              currentLand.images[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.error,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    // Image counter indicator
                    if (currentLand.images.length > 1)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(180),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${currentLand.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Navigation dots (optional)
                    if (currentLand.images.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            currentLand.images.length,
                                (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withAlpha(128),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
              ),
            ),
            const SizedBox(height: 20),

            // Basic info section
            _buildInfoSection(),

            const SizedBox(height: 20),

            // Funding section
            _buildFundingSection(),

            const SizedBox(height: 20),

            // Updates section
            Row(
              children: [
                Text(
                  'Project Updates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${updates.length} update${updates.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (updates.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withAlpha(76)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.update,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No updates yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'The farmer will post progress updates here',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...updates.map((update) => _buildUpdateCard(update)),

            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: currentLand.isFullyFunded || isAlreadySponsored
          ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatFarmersScreen(land: currentLand),
                ),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text('Join Chat'),
            backgroundColor: theme.primaryColor,
          )
              : FloatingActionButton.extended(
                onPressed: isSponsoring ? null : _showSponsorDialog,
                icon: isSponsoring
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.volunteer_activism),
                    label: Text(isSponsoring ? 'Processing...' : 'Sponsor Project'),
                    backgroundColor: isSponsoring ? Colors.grey : theme.primaryColor,
              ),
        );
  }

  void _openImageViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          images: currentLand.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}