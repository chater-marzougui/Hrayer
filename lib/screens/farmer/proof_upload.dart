import 'package:base_template/widgets/widgets.dart';
import 'package:base_template/helpers/image_upload.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../l10n/app_localizations.dart';
import '../../structures/land_models.dart';

class ProofUploadScreen extends StatefulWidget {
  final LandModel land;

  const ProofUploadScreen({required this.land, super.key});

  @override
  State<ProofUploadScreen> createState() => _ProofUploadScreenState();
}

class _ProofUploadScreenState extends State<ProofUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  List<File> selectedImages = [];
  bool isLoading = false;
  String selectedUpdateType = 'weekly';
  final ImagePicker _picker = ImagePicker();
  List<LandUpdateModel> previousUpdates = [];

  final List<String> updateTypes = [
    'weekly',
    'milestone',
    'issue',
    'harvest'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreviousUpdates();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousUpdates() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lands')
          .doc(widget.land.id)
          .collection('updates')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      previousUpdates = querySnapshot.docs
          .map((doc) => LandUpdateModel.fromFirestore(doc))
          .toList();

      setState(() {});
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      showCustomSnackBar(context, loc.errorLoadingUpdates(e));
    }
  }

  Future<void> _pickImages() async {
    final loc = AppLocalizations.of(context)!;
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty && images.length <= 3) {
        setState(() {
          selectedImages = images.map((xFile) => File(xFile.path)).toList();
        });
      } else if (images.length > 3) {
          showCustomSnackBar(context, loc.maximum3ImagesAllowedForUpdates);
      }
    } catch (e) {
        showCustomSnackBar(context, loc.errorPickingImages(e));
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context)!;
    if (selectedImages.isEmpty) {
      showCustomSnackBar(context, (loc.pleaseAddAtLeastOnePhoto));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      List<String> imagePaths = [];
      // In production, upload images to Firebase Storage
      for (var image in selectedImages) {
        for (int i = 0; i < 3; i++) {
          final path = await uploadImage(context, image);
          if (path != null) {
            imagePaths.add(path);
            break;
          }
        }
      }

      final updateData = {
        'landId': widget.land.id,
        'farmerId': currentUser.uid,
        'note': _noteController.text.trim(),
        'images': imagePaths,
        'updateType': selectedUpdateType,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('lands')
          .doc(widget.land.id)
          .collection('updates')
          .add(updateData);

      // Also create a notification in the chat
      final chatMessage = {
        'landId': widget.land.id,
        'senderId': currentUser.uid,
        'senderName': 'System',
        'senderRole': 'system',
        'text': '📸 New $selectedUpdateType update: ${_noteController.text.trim()}',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.land.id)
          .collection('messages')
          .add(chatMessage);

      if (mounted) {
        showCustomSnackBar(context, loc.updateSubmittedSuccessfully);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
          showCustomSnackBar(context, loc.errorGeneric(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildUpdateTypeSelector() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.updateType,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: updateTypes.map((type) {
              bool isSelected = selectedUpdateType == type;
              return ChoiceChip(
                label: Text(
                  type.capitalize(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedUpdateType = type;
                    });
                  }
                },
                selectedColor: theme.primaryColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousUpdateCard(LandUpdateModel update) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    update.updateType.capitalize(),
                    style: TextStyle(
                      color: theme.primaryColor,
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
            const SizedBox(height: 8),
            Text(
              update.note,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (update.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${update.images.length} photo(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Update: ${widget.land.title}'),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Land Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.primaryColor.withAlpha(76)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.land.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      '${widget.land.size} hectares • ${widget.land.intendedCrop}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: widget.land.progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.land.progressPercentage.toStringAsFixed(0)}% funded',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Update Type Selector
              _buildUpdateTypeSelector(),

              const SizedBox(height: 24),

              // Photo Upload
              Text(
                loc.progressPhotos,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primaryColor.withAlpha(76),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: selectedImages.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.addProgressPhotosMax3,
                        style: TextStyle(color: theme.primaryColor),
                      ),
                    ],
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: selectedImages.length + (selectedImages.length < 3 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == selectedImages.length) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.grey[600],
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Progress Note
              Text(
                loc.progressNote,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: loc.describeCurrentProgress,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.pleaseProvideProgressUpdateNote;
                  }
                  if (value.trim().length < 10) {
                    return loc.pleaseProvideDetailedUpdate;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Previous Updates
              if (previousUpdates.isNotEmpty) ...[
                Text(
                  loc.recentUpdates,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...previousUpdates.map((update) => _buildPreviousUpdateCard(update)),
                const SizedBox(height: 24),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submitUpdate,
                  icon: const Icon(Icons.upload),
                  label: Text(
                    isLoading ? 'Submitting...' : loc.submitUpdate,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}