import 'package:base_template/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../helpers/current_location_service.dart';
import '../../widgets/weather_forecast.dart';
import '../../widgets/widgets.dart';
import '../../structures/land_models.dart';
import 'land_list.dart';
import 'land_details.dart';
import 'chat_farmers.dart';

class SponsorDashboard extends StatefulWidget {
  const SponsorDashboard({super.key});

  @override
  State<SponsorDashboard> createState() => _SponsorDashboardState();
}

class _SponsorDashboardState extends State<SponsorDashboard> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<LandModel> sponsoredLands = [];
  bool isLoading = true;
  double totalSponsored = 0.0;
  int activeSponsorships = 0;
  int farmersBenefited = 0;
  double latitude = 0.0;
  double longitude = 0.0;
  String locationName = 'Unknown Location';

  @override
  void initState() {
    super.initState();
    _loadSponsoredLands();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final position = await CurrentLocationService.getCurrentLocationWithName();
    print(position);
    if (position == null) return;
    setState(() {
      latitude = position.latitude; // Example: Tunisia latitude
      longitude = position.longitude; // Example: Tunisia longitude
      locationName = position.locationName;
    });
  }


  Future<void> _loadSponsoredLands() async {
    if (currentUser == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lands')
          .where('sponsors', arrayContains: currentUser!.uid)
          .get();

      sponsoredLands = querySnapshot.docs
          .map((doc) => LandModel.fromFirestore(doc))
          .toList();

      // Calculate stats
      totalSponsored = 0;
      Set<String> uniqueFarmers = {};

      for (var land in sponsoredLands) {
        // For demo, assume user contributed proportionally
        double userContribution = land.totalFulfilled * (1.0 / land.sponsors.length);
        totalSponsored += userContribution;
        uniqueFarmers.add(land.ownerId);
      }

      activeSponsorships = sponsoredLands.where((land) => land.isActive).length;
      farmersBenefited = uniqueFarmers.length;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        showCustomSnackBar(context, loc.errorLoadingSponsorships(e));
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

  Widget _buildSponsoredLandCard(LandModel land) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: land.isFullyFunded
                        ? Colors.green.withAlpha(51)
                        : theme.primaryColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    land.isFullyFunded ? 'Completed' : 'Active',
                    style: TextStyle(
                      color: land.isFullyFunded ? Colors.green : theme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${land.totalFulfilled.toStringAsFixed(0)} of \$${land.totalNeeded.toStringAsFixed(0)} raised',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  '${land.sponsors.length} sponsor${land.sponsors.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
                          builder: (context) => ChatFarmersScreen(land: land),
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

  Widget _buildImpactSection() {
    if (sponsoredLands.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;


    final completedProjects = sponsoredLands.where((land) => land.isFullyFunded).length;
    final totalHectares = sponsoredLands.fold(0.0, (sum, land) => sum + land.size);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withAlpha(25),
            theme.primaryColor.withAlpha(12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                loc.yourImpact,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildImpactItem(
                  loc.projectsCompleted,
                  completedProjects.toString(),
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildImpactItem(
                  loc.totalHectares,
                  totalHectares.toStringAsFixed(1),
                  Icons.landscape,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.thankYouForSupporting,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.primaryColor, size: 32),
            const SizedBox(width: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.sponsorDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LandListScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadSponsoredLands,
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
                      loc.activeProjects,
                      activeSponsorships.toString(),
                      Icons.agriculture,
                      theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      loc.totalContributed,
                      totalSponsored.toStringAsFixed(0),
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      loc.farmersHelped,
                      farmersBenefited.toString(),
                      Icons.people,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                loc.quickActions,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 24),
              if (latitude != 0.0 && longitude != 0.0)
                WeatherWidget(
                  latitude: latitude,
                  longitude: longitude,
                  locationName: locationName,
                ),

              const SizedBox(height: 24),

              // Impact Section
              _buildImpactSection(),

              // My Sponsorships Section
              Text(
                loc.mySponsorships,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (sponsoredLands.isEmpty)
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
                        Icons.volunteer_activism,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.noSponsorshipsYet,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.browseProjectsAndMakeADifference,
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
                              builder: (context) => const LandListScreen(),
                            ),
                          ).then((_) => _loadSponsoredLands());
                        },
                        icon: const Icon(Icons.search),
                        label: Text(loc.browseProjects),
                      ),
                    ],
                  ),
                )
              else
                ...sponsoredLands.map((land) => _buildSponsoredLandCard(land)),
            ],
          ),
        ),
      ),
    );
  }
}