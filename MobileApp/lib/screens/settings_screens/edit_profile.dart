import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/user_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final goraUser = UserController().currentUser;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();



  User? user;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _nameController.text = goraUser?.displayName ?? "";
      _lastNameController.text = goraUser?.lastName ?? "";
      _emailController.text = goraUser?.email ?? "";
      _phoneNumberController.text = goraUser?.phoneNumber ?? "";
    }
  }

  Future<void> _updateProfile(AppLocalizations loc) async {
    bool reauthenticated = await _reauthenticateUser();
    if (!reauthenticated) {
      if (mounted) showCustomSnackBar(context, loc.wrongPassword);
      return;
    }

    try {
      if (_nameController.text != user!.displayName) {
        await user!.updateDisplayName(_nameController.text);
      }
      if (_emailController.text != user!.email) {
        await user!.verifyBeforeUpdateEmail(_emailController.text);
      }

      await db.collection('users').doc(user!.uid).set({
        'displayName': _nameController.text + _lastNameController.text,
        'firstName': _nameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
      }, SetOptions(merge: true));

      // Optionally reload user data
      UserController().reloadUser();
      await user!.reload();
      setState(() {
        user = _auth.currentUser;
      });

      if (mounted) showCustomSnackBar(context, loc.profileUpdatedSuccessfully);
    } catch (e) {
      if (mounted) showCustomSnackBar(context, loc.errorUpdatingProfile(e));
    }
  }

  Future<void> _updatePassword(AppLocalizations loc) async {
    bool reauthenticated = await _reauthenticateUser();

    if (!reauthenticated) {
      if (mounted) showCustomSnackBar(context, loc.wrongPassword);
      return;
    }

    try {
      await user!.updatePassword(_newPasswordController.text);
      if (mounted) showCustomSnackBar(context, loc.passwordUpdatedSuccessfully);
    } catch (e) {
      if (mounted) showCustomSnackBar(context, loc.errorUpdatingPassword(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    if (goraUser == null) {
      return const Scaffold(
        body: Center(child: CustomLoadingScreen(message: "Loading")),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(loc.editProfile)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(loc),
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: const Color(0x00087a22),
                      backgroundImage: _getProfileImage(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(context, _nameController, loc.firstName),
                  const SizedBox(height: 16),
                  buildTextField(
                    context,
                    _lastNameController,
                    loc.lastName,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    context,
                    _phoneNumberController,
                    loc.phoneNumber,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    context,
                    _emailController,
                    "Email",
                    validator: (str) => _emailValidator(str, loc),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showUpdatePasswordDialog(loc),
                          child: Text(
                            loc.changePassword,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            } else {
                              _showUpdateProfileDialog(loc);
                            }
                          },
                          child: Text(
                            loc.applyChanges,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showUpdateProfileDialog(AppLocalizations loc) => showDialog(
    context: context,
    builder:
        (context) => Theme(
          data: Theme.of(context),
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(loc.typeYourPasswordToApplyChanges),
                  const SizedBox(height: 16),
                  buildTextField(
                    context,
                    _passwordController,
                    "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _updateProfile(loc);
                      Navigator.of(context).pop();
                    },
                    child: Text(loc.applyChanges),
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  Future<void> _pickImage(AppLocalizations loc) async {
    final source = await _showImageSourceDialog(loc);
    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog(AppLocalizations loc) async {
    return await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(loc.chooseAnImageSource),
            content: Text(
              loc.wouldYouLikeToTakeAPictureOrChooseFromGallery,
            ),
            actions: [
              TextButton(
                child: Text(loc.camera),
                onPressed: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              TextButton(
                child: Text(loc.gallery),
                onPressed: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
          ),
    );
  }

  Future<bool> _reauthenticateUser() async {
    String currentPassword = _passwordController.text;

    AuthCredential credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );
    try {
      await user!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      if (mounted) showCustomSnackBar(context, loc.errorReauthenticatingUser(e));
      return false;
    }
  }

  void _showUpdatePasswordDialog(AppLocalizations loc) => showDialog(
    context: context,
    builder:
        (context) => Theme(
          data: Theme.of(context),
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    loc.typeYourOldPasswordAndTheNewOneToApplyChanges,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    context,
                    _passwordController,
                    loc.oldPassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    context,
                    _newPasswordController,
                    loc.newPassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    context,
                    _confirmPasswordController,
                    loc.confirmPassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Validate the passwords
                      if (_newPasswordController.text !=
                          _confirmPasswordController.text) {
                        showCustomSnackBar(context, loc.passwordsDoNotMatch);
                        return;
                      }
                      try {
                        _updatePassword(loc);
                        Navigator.of(context).pop();
                        showCustomSnackBar(context, loc.passwordUpdatedSuccessfully);
                      } catch (e) {
                        if (mounted) showCustomSnackBar(context, loc.errorUpdatingPassword(e));
                      }
                    },
                    child: Text(loc.applyChanges),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _showRecoverPasswordDialog(loc);
                    },
                    child: Text(loc.forgotPassword),
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  void _showRecoverPasswordDialog(AppLocalizations loc) => showDialog(
    context: context,
    builder:
        (dialogContext) => Theme(
          data: Theme.of(context),
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(loc.enterYourEmailToRecoverYourPassword),
                  const SizedBox(height: 16),
                  buildTextField(
                    dialogContext,
                    _emailController,
                    "Email",
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: _emailController.text,
                        );

                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          showCustomSnackBar(
                            context,
                            'Password recovery email sent to ${_emailController.text}',
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          showCustomSnackBar(
                            context,
                            loc.errorSendingPasswordRecoveryEmail(e),
                          );
                        }
                      }
                    },
                    child: Text(loc.recoverPassword),
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  String? _emailValidator(String? value, AppLocalizations loc) {
    if (value == null || !value.contains('@')) {
      return loc.pleaseEnterAValidEmailAddress;
    }
    return null;
  }

  ImageProvider _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (goraUser?.profileImage != null &&
        goraUser!.profileImage.isNotEmpty) {
      return NetworkImage(goraUser!.profileImage);
    } else {
      return const AssetImage('assets/icons/default_profile_pic_man.png');
    }
  }
}
