import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
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
  int selectedFundingStatus = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> cropTypes = [
    'All', 'Tomatoes', 'Wheat', 'Corn', 'Rice', 'Potatoes',
    'Beans', 'Carrots', 'Onions', 'Lettuce', 'Other'
  ];

  final List<int> fundingStatusesIndexes = [0, 1, 2, 3];

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
          .get();

      availableLands = querySnapshot.docs
          .map((doc) => LandModel.fromFirestore(doc))
          .where((land) => land.isActive == true)
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
        final loc = AppLocalizations.of(context)!;
        showCustomSnackBar(context, loc.errorLoadingProjects(e));
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
      if (selectedFundingStatus != 0) {
        double progress = land.progressPercentage;
        switch (selectedFundingStatus) {
          case 1:
            matchesFunding = progress <= 25;
            break;
          case 2:
            matchesFunding = progress > 25 && progress <= 75;
            break;
          case 3:
            matchesFunding = progress > 75 && progress < 100;
            break;
        }
      }

      return matchesSearch && matchesCrop && matchesFunding;
    }).toList();

    setState(() {});
  }

  Future<void> _sponsorLand(AppLocalizations loc, LandModel land, double amount) async {
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
        'text': loc.newSponsorJoinedTnd(amount.toStringAsFixed(0)),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.thankYouForSponsorship),
            backgroundColor: Colors.green,
          ),
        );
        _loadAvailableLands(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, loc.errorProcessingSponsorship(e));
      }
    }
  }

  void _showSponsorDialog(LandModel land) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.sponsorLandTitle(land.title)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.helpLandReachFundingGoal(land.title),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              loc.remainingNeeded((land.totalNeeded - land.totalFulfilled).toStringAsFixed(0)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: loc.sponsorshipAmountTnd,
                hintStyle: theme.textTheme.bodySmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: 'TND ',
              ),
            ),
            const SizedBox(height: 16),
            // Quick amount buttons
            Wrap(
              spacing: 8,
              children: [50, 100, 250, 500, 1000, 2000].map((amount) {
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
                  child: Text('$amount'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _sponsorLand(loc, land, amount);
              }
            },
            child: Text(loc.sponsorNow),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final List<String> fundingStatuses = [
      'All', loc.justStarted0_25, loc.inProgress25_75, loc.almostComplete75_99
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crop filter
        Text(
          loc.filterByCrop,
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
          loc.filterByFundingStatus,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: fundingStatuses.map((status) {
            bool isSelected = fundingStatuses[selectedFundingStatus] == status;
            return FilterChip(
              label: Text(
                status,
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFundingStatus = fundingStatuses.indexOf(status);
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
    final loc = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAlreadySponsored = land.sponsors.contains(currentUser?.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: land.images.isNotEmpty ? Image.network(
                    land.images[0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity
                  ) :
                  Icon(
                    Icons.landscape,
                    size: 64,
                    color: theme.primaryColor.withAlpha(100),
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
                      _getUrgencyText(loc, land.progressPercentage),
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
                                '${land.totalFulfilled.toStringAsFixed(0)} of ${land.totalNeeded.toStringAsFixed(0)}',
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
                        label: Text(loc.viewDetails),
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
                          isAlreadySponsored ? 'Sponsored' : loc.sponsorNow,
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

  String _getUrgencyText(AppLocalizations loc, double progress) {
    if (progress < 25) return 'URGENT';
    if (progress < 75) return loc.inProgress;
    return loc.almostThere;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.browseProjects),
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
                        loc.filterProjects,
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
                          child: Text(loc.applyFilters),
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
                hintText: loc.searchProjects,
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
                if (searchQuery.isNotEmpty || selectedCrop != 'All' || selectedFundingStatus != 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        selectedCrop = 'All';
                        selectedFundingStatus = 0;
                        _searchController.clear();
                      });
                      _applyFilters();
                    },
                    child: Text(loc.clearFilters),
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
                      loc.noProjectsFound,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.tryAdjustingSearch,
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