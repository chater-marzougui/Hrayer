import 'package:base_template/l10n/app_localizations.dart';
import 'package:base_template/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedRole = 'Sponsor';
  bool _isLoading = false;
  bool _isCurrentUserFarmer = false;

  final List<String> _roleOptions = ['Farmer', 'Sponsor'];

  @override
  void initState() {
    super.initState();
    _checkCurrentUserRole();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentUserRole() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _isCurrentUserFarmer = userData['role'] == 'farmer';
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _addUser(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;

    // Check if current user is farmer (admin)
    if (!_isCurrentUserFarmer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.onlyAdminsCanAddUsers),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception(loc.noAuthenticatedUser);
      }

      // Check if phone number already exists
      final existingUserQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: _phoneController.text.trim())
          .get();

      if (existingUserQuery.docs.isNotEmpty) {
        throw Exception(loc.userWithPhoneNumberExists);
      }

      // Create user invitation document
      final invitationData = {
        'phoneNumber': _phoneController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'role': _selectedRole.toLowerCase(),
        'invitedBy': currentUser.uid,
        'invitedByName': currentUser.displayName ?? 'Admin',
        'status': 'invited', // invited, accepted, expired
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': FieldValue.serverTimestamp(), // In production, set this to future date
      };

      await FirebaseFirestore.instance
          .collection('invitations')
          .add(invitationData);

      // Also create a pending user record for tracking
      final pendingUserData = {
        'phoneNumber': _phoneController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'role': _selectedRole.toLowerCase(),
        'status': 'pending_signup',
        'invitedBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('pending_users')
          .add(pendingUserData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${_nameController.text.trim()}!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _phoneController.clear();
        _nameController.clear();
        _emailController.clear();
        setState(() {
          _selectedRole = 'Sponsor';
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, loc.errorGeneric(e), type: SnackBarType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.addNewUser),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCurrentUserFarmer 
                      ? Colors.blue.withAlpha(25)
                      : Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCurrentUserFarmer 
                        ? Colors.blue.withAlpha(76)
                        : Colors.orange.withAlpha(76),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCurrentUserFarmer ? Icons.admin_panel_settings : Icons.info_outline,
                      color: _isCurrentUserFarmer ? Colors.blue[700] : Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isCurrentUserFarmer 
                            ? loc.asAFarmerYouCanInvite
                            : loc.onlyAdminsCanAddUsersPlatform,
                        style: TextStyle(
                          color: _isCurrentUserFarmer ? Colors.blue[700] : Colors.orange[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                loc.userInformation,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Full Name Field
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading && _isCurrentUserFarmer,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: loc.fullName,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.pleaseEnterTheUser;
                  }
                  if (value.trim().length < 2) {
                    return loc.nameMustBeAtLeast2Chars;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                enabled: !_isLoading && _isCurrentUserFarmer,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: loc.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  hintText: '+1234567890',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.pleaseEnterPhoneNumber;
                  }
                  // Basic phone validation
                  final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{8,}$');
                  if (!phoneRegex.hasMatch(value.trim())) {
                    return loc.pleaseEnterAValidPhoneNumber;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email Field (Optional)
              TextFormField(
                controller: _emailController,
                enabled: !_isLoading && _isCurrentUserFarmer,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: loc.emailOptional,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return loc.pleaseEnterAValidEmailAddress;
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Role Selection
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                onChanged: (!_isLoading && _isCurrentUserFarmer) ? (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  }
                } : null,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: const Icon(Icons.people_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                items: _roleOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Role Description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primaryColor.withAlpha(76)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedRole == 'Farmer' ? loc.farmerRole : loc.sponsorRole,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedRole == 'Farmer' 
                          ? loc.farmerRoleDescription
                          : loc.sponsorRoleDescription,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (_isLoading || !_isCurrentUserFarmer) ? null : () => _addUser(loc),
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.person_add),
                  label: Text(
                    _isLoading ? loc.sendingInvitation : loc.sendInvitation,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCurrentUserFarmer ? theme.primaryColor : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              if (!_isCurrentUserFarmer) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(76)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.youNeedAdminPrivileges,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}