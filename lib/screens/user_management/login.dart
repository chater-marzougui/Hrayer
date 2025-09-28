import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../bottom_navbar.dart';
import '../../l10n/app_localizations.dart';
import "../../structures/structs.dart" as structs;
import "../../controllers/user_controller.dart";

import '../../widgets/widgets.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserController _userManager = UserController();

  bool _isObscure = true;
  bool _isLoading = false;
  bool _isGoogleSignInLoading = false;
  String errorMessage = '';

  Future<void> _signInWithGoogle() async {
    if (_isGoogleSignInLoading) return;

    setState(() {
      _isGoogleSignInLoading = true;
      errorMessage = '';
    });

    await _googleSignIn.initialize();

    try {
      // Sign out any existing user first to avoid conflicts
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Trigger the authentication flow
      _googleSignIn.authenticationEvents.listen(_handleAuthenticationEvent);
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();


      if (googleUser.authentication.idToken == null) {
        // User cancelled the sign-in
        setState(() {
          _isGoogleSignInLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Parse user's display name
        String firstName = '';
        String lastName = '';

        if (user.displayName != null) {
          List<String> nameParts = user.displayName!.split(' ');
          if (nameParts.isNotEmpty) {
            firstName = nameParts.first;
            if (nameParts.length > 1) {
              lastName = nameParts.skip(1).join(' ');
            }
          }
        }

        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Show dialog to complete profile
          final completeProfile = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AdditionalUserDetailsDialog(
              uid: user.uid,
              displayName: user.displayName ?? '',
              firstName: firstName,
              lastName: lastName,
              email: user.email ?? '',
              profileImage: user.photoURL ?? '',
              onUserCreated: (structs.User newUser) {
                _userManager.setUser(newUser);
              },
            ),
          );

          if (completeProfile == true) {
            // User completed profile, now fetch the updated document
            userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (userDoc.exists) {
              _userManager.setUser(structs.User.fromFirestore(userDoc));
              _navigateToHomePage();
            }
          }
        } else {
          // User exists, proceed to home
          _userManager.setUser(structs.User.fromFirestore(userDoc));
          _navigateToHomePage();
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = "Google Sign-In failed: ${e.toString()}";
      });
      if (mounted) {
        showCustomSnackBar(context, "Google Sign-In failed: ${e.toString()}");
      }
    } finally {
      setState(() {
        _isGoogleSignInLoading = false;
      });
    }
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    // You can handle different authentication events here if needed
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
      // Handle sign-in event
        break;
      case GoogleSignInAuthenticationEventSignOut():
      // Handle sign-out event
        break;
    }
  }

  void _navigateToHomePage() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
    }
  }

  Future<void> _login(AppLocalizations loc) async {
    if (!_validateAuthData(loc)) return;

    setState(() {
      _isLoading = true;
      errorMessage = '';
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          _userManager.setUser(structs.User.fromFirestore(userDoc));
          _navigateToHomePage();
        } else {
          // User document doesn't exist, redirect to signup
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = loc.loginFailed;
      switch (e.code) {
        case 'user-not-found':
          message = loc.noAccountFoundWithThisEmail;
          break;
        case 'wrong-password':
          message = loc.incorrectPassword;
          break;
        case 'invalid-email':
          message = loc.invalidEmailAddress;
          break;
        case 'user-disabled':
          message = loc.thisAccountHasBeenDisabled;
          break;
        case 'too-many-requests':
          message = loc.tooManyFailedAttempts;
          break;
        default:
          message = loc.loginFailedWithMessage(message);
      }

      setState(() {
        errorMessage = message;
      });

      if (mounted) {
        showCustomSnackBar(context, message);
      }
    } catch (e) {
      setState(() {
        errorMessage = loc.anUnexpectedErrorOccurred;
      });

      if (mounted) {
        showCustomSnackBar(context, loc.anUnexpectedErrorOccurred);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateAuthData(AppLocalizations loc) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showCustomSnackBar(context, loc.pleaseFillInAllFields);
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showCustomSnackBar(context, loc.pleaseEnterAValidEmailAddress);
      return false;
    }

    final passwordRegex = RegExp(r'^(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      showCustomSnackBar(
        context,
        loc.passwordRequirements,
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          height: screenHeight - MediaQuery.of(context).padding.top,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Section
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 144,
                        width: 144,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      loc.welcomeBack,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.signInToContinueYourJourney,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 180),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Email Field
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _emailController,
                  enabled: !_isLoading && !_isGoogleSignInLoading,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: loc.emailAddress,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary.withValues(alpha: 205),
                    ),
                    hintText: loc.enterYourEmail,
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 128),
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 75),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 75),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              // Password Field
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _passwordController,
                  enabled: !_isLoading && !_isGoogleSignInLoading,
                  obscureText: _isObscure,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary.withValues(alpha: 205),
                    ),
                    hintText: loc.enterYourPassword,
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 128),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: theme.colorScheme.primary.withValues(alpha: 180),
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 75),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 75),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              // Sign Up Link
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: (_isLoading || _isGoogleSignInLoading) ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    loc.dontHaveAnAccountSignUp,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Login Button
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isGoogleSignInLoading) ? null : () => _login(loc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 150),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                      : Text(
                    loc.signIn,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Divider
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: theme.dividerColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        loc.orContinueWith,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 144),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: theme.dividerColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Google Sign In Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (_isLoading || _isGoogleSignInLoading) ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    elevation: 1,
                    shadowColor: Colors.black.withValues(alpha: 25),
                    side: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: theme.cardColor.withValues(alpha: 150),
                  ),
                  icon: _isGoogleSignInLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                      : Image.asset(
                    'assets/icons/google_logo.png',
                    height: 24,
                    width: 24,
                  ),
                  label: Text(
                    _isGoogleSignInLoading ? loc.signingIn : 'Continue with Google',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
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