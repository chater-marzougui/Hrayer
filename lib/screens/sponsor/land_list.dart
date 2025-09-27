import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../structures/land_models.dart';
import 'land_details.dart';

class LandListScreen extends StatefulWidget {
  const LandListScreen({super.key});

  @override
  State<LandListScreen> createState() => _LandListScreenState();
}

class _LandListScreenState extends State<LandListScreen> {
  List<LandModel> availableLands = [];
  List<LandModel> filteredLands = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedCrop = 'All';
  String selectedFundingStatus = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> cropTypes = [
    'All', 'Tomatoes', 'Wheat', 'Corn', 'Rice', 'Potatoes',
    'Beans', 'Carrots', 'Onions', 'Lettuce', 'Other'
  ];

  final List<String> fundingStatuses = [
    'All', 'Just Started (0-25%)', 'In Progress (25-75%)', 'Almost Complete (75-99%)'
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableLands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableLands() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lands')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      availableLands = querySnapshot.docs
          .map((doc) => LandModel.fromFirestore(doc))
          .where((land) => !land.isFullyFunded) // Only show lands that need funding
          .toList();

      _applyFilters();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    filteredLands = availableLands.where((land) {
      // Search filter
      bool matchesSearch = searchQuery.isEmpty ||
          land.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          land.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
          land.intendedCrop.toLowerCase().contains(searchQuery.toLowerCase());

      // Crop filter
      bool matchesCrop = selectedCrop == 'All' ||
          land.intendedCrop.toLowerCase().contains(selectedCrop.toLowerCase()) ||
          (selectedCrop == 'Other' && !cropTypes.sublist(1, cropTypes.length - 1)
              .any((crop) => land.intendedCrop.toLowerCase().contains(crop.toLowerCase())));

      // Funding status filter
      bool matchesFunding = true;
      if (selectedFundingStatus != 'All') {
        double progress = land.progressPercentage;
        switch (selectedFundingStatus) {
          case 'Just Started (0-25%)':
            matchesFunding = progress <= 25;
            break;
          case 'In Progress (25-75%)':
            matchesFunding = progress > 25 && progress <= 75;
            break;
          case 'Almost Complete (75-99%)':
            matchesFunding = progress > 75 && progress < 100;
            break;
        }
      }

      return matchesSearch && matchesCrop && matchesFunding;
    }).toList();

    setState(() {});
  }

  Future<void> _sponsorLand(LandModel land, double amount) async {
    if (amount <= 0) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Update the land document
      final landRef = FirebaseFirestore.instance.collection('lands').doc(land.id);

      await landRef.update({
        'sponsors': FieldValue.arrayUnion([currentUser.uid]),
        'fulfilled.Sponsor Contribution': FieldValue.increment(amount),
      });

      // Add a system message to the chat
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(land.id)
          .collection('messages')
          .add({
        'landId': land.id,
        'senderId': 'system',
        'senderName': 'System',
        'senderRole': 'system',
        'text': '🎉 New sponsor joined! A generous contribution of \${amount.toStringAsFixed(0)} has been made to support this project.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your sponsorship!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAvailableLands(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing sponsorship: $e')),
        );
      }
    }
  }

  void _showSponsorDialog(LandModel land) {
    final theme = Theme.of(context);
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sponsor ${land.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help ${land.title} reach its funding goal!',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Remaining needed: \${(land.totalNeeded - land.totalFulfilled).toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
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
                  child: Text('\$amount'),
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
                _sponsorLand(land, amount);
              }
            },
            child: const Text('Sponsor Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crop filter
        Text(
          'Filter by Crop',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: cropTypes.map((crop) {
            bool isSelected = selectedCrop == crop;
            return FilterChip(
              label: Text(crop),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCrop = crop;
                });
                _applyFilters();
              },
              selectedColor: theme.primaryColor.withAlpha(51),
              checkmarkColor: theme.primaryColor,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Funding status filter
        Text(
          'Filter by Funding Status',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: fundingStatuses.map((status) {
            bool isSelected = selectedFundingStatus == status;
            return FilterChip(
              label: Text(
                status,
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFundingStatus = status;
                });
                _applyFilters();
              },
              selectedColor: theme.primaryColor.withAlpha(51),
              checkmarkColor: theme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLandCard(LandModel land) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAlreadySponsored = land.sponsors.contains(currentUser?.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder or first image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(25),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.agriculture,
                        size: 48,
                        color: theme.primaryColor.withAlpha(128),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${land.images.length} photo${land.images.length != 1 ? 's' : ''} available',
                        style: TextStyle(
                          color: theme.primaryColor.withAlpha(128),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(land.progressPercentage),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getUrgencyText(land.progressPercentage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isAlreadySponsored)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SPONSORED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        land.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      land.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

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

                Text(
                  land.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                // Funding progress
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${land.progressPercentage.toStringAsFixed(0)}% funded',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\${land.totalFulfilled.toStringAsFixed(0)} of \${land.totalNeeded.toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: land.progressPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LandDetailsScreen(land: land),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isAlreadySponsored
                            ? null
                            : () => _showSponsorDialog(land),
                        icon: Icon(
                          isAlreadySponsored ? Icons.check : Icons.volunteer_activism,
                          size: 16,
                        ),
                        label: Text(
                          isAlreadySponsored ? 'Sponsored' : 'Sponsor Now',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: isAlreadySponsored
                              ? Colors.grey
                              : theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(double progress) {
    if (progress < 25) return Colors.red;
    if (progress < 75) return Colors.orange;
    return Colors.green;
  }

  String _getUrgencyText(double progress) {
    if (progress < 25) return 'URGENT';
    if (progress < 75) return 'IN PROGRESS';
    return 'ALMOST THERE';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Browse Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Projects',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFilterChips(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects by name, location, or crop...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              onChanged: (value) {
                searchQuery = value;
                _applyFilters();
              },
            ),
          ),

          // Results header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredLands.length} projects available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (searchQuery.isNotEmpty || selectedCrop != 'All' || selectedFundingStatus != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        selectedCrop = 'All';
                        selectedFundingStatus = 'All';
                        _searchController.clear();
                      });
                      _applyFilters();
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Projects list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadAvailableLands,
              child: filteredLands.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No projects found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search criteria',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredLands.length,
                itemBuilder: (context, index) {
                  return _buildLandCard(filteredLands[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}