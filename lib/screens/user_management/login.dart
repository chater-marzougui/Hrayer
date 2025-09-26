import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../bottom_navbar.dart';
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
        showSnackBar(context, "Google Sign-In failed: ${e.toString()}");
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

  Future<void> _login() async {
    if (!_validateAuthData()) return;

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
      String message = "Login failed";
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email";
          break;
        case 'wrong-password':
          message = "Incorrect password";
          break;
        case 'invalid-email':
          message = "Invalid email address";
          break;
        case 'user-disabled':
          message = "This account has been disabled";
          break;
        case 'too-many-requests':
          message = "Too many failed attempts. Please try again later";
          break;
        default:
          message = "Login failed: ${e.message}";
      }

      setState(() {
        errorMessage = message;
      });

      if (mounted) {
        showSnackBar(context, message);
      }
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred";
      });

      if (mounted) {
        showSnackBar(context, "An unexpected error occurred");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateAuthData() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, "Please fill in all fields");
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showSnackBar(context, "Please enter a valid email address");
      return false;
    }

    final passwordRegex = RegExp(r'^(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      showSnackBar(
        context,
        "Password must be at least 8 characters long and contain a number",
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 25),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your journey',
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
                    labelText: 'Email Address',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary.withValues(alpha: 205),
                    ),
                    hintText: 'Enter your email',
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
                    hintText: 'Enter your password',
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
                    "Don't have an account? Sign up",
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
                  onPressed: (_isLoading || _isGoogleSignInLoading) ? null : _login,
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
                    'Sign In',
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
                        'Or continue with',
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
              Container(
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
                    _isGoogleSignInLoading ? 'Signing in...' : 'Continue with Google',
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