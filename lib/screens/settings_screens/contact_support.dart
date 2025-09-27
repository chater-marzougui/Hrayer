import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Widgets/widgets.dart';
import '../../controllers/user_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../structures/structs.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userManager = UserController();
  final db = FirebaseFirestore.instance;
  User? goraUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitSupportRequest(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await db.collection('supportRequests').doc(goraUser!.uid).set({
        'name': _nameController.text,
        'email': goraUser!.email,
        'userId': goraUser!.uid,
        'messages': FieldValue.arrayUnion([
          {
            'timestamp': Timestamp.now(),
            'subject': _subjectController.text,
            'message': _messageController.text,
            'answered': false,
          },
        ]),
      }, SetOptions(merge: true));

      if (mounted) {
        showSnackBar(context, loc.supportRequestSubmittedSuccessfully);
      }

      _subjectController.clear();
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        showSnackBar(context, loc.errorSubmittingSupportRequest);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        goraUser = _userManager.currentUser!;
        _nameController.text = goraUser!.displayName;
        _emailController.text = goraUser!.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.contactSupport)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextField(loc, _nameController, "Name", loc.enterYourName),
                    buildTextField(
                      loc,
                      _emailController,
                      "Email",
                      loc.enterYourEmail,
                      email: true,
                    ),
                    buildTextField(
                      loc,
                      _subjectController,
                      "Subject",
                      loc.enterTheSubjectOfYourMessage,
                    ),
                    buildTextField(
                      loc,
                      _messageController,
                      "Message",
                      loc.enterYourMessage,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          style: theme.elevatedButtonTheme.style,
                          onPressed: () => _submitSupportRequest(loc),
                          child: Text(loc.submitRequest),
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              buildInfoCard(
                context,
                Icons.support_agent_sharp,
                loc.contactInformation,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailRow(
                      context,
                      Icons.location_on_outlined,
                      "Location",
                      "Sup'Com Raoued Km 3,5 - 2083, Ariana Tunisie",
                      wrapText: true,
                    ),
                    buildDetailRow(
                      context,
                      Icons.phone,
                      "Phone",
                      "+216 28356927",
                    ),
                    buildDetailRow(
                      context,
                      Icons.email,
                      "Email",
                      "chater.marzougui@supcom.tn",
                      wrapText: true,
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

  Widget buildTextField(
    AppLocalizations loc,
    TextEditingController controller,
    String label,
    String hint, {
    bool email = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          if (email && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return loc.pleaseEnterAValidEmailAddress;
          }
          return null;
        },
      ),
    );
  }
}

Widget buildInfoCard(
  BuildContext context,
  IconData icon,
  String title,
  Widget content,
) {
  final theme = Theme.of(context);
  return Card(
    elevation: 4,
    color: theme.cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: theme.iconTheme.color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    ),
  );
}

Widget buildDetailRow(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  bool wrapText = false,
}) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child:
        wrapText
            ? Column(
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: theme.iconTheme.color),
                    const SizedBox(width: 8),
                    Text(
                      '$label: ',
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(value, style: theme.textTheme.titleSmall),
              ],
            )
            : Row(
              children: [
                Icon(icon, size: 20, color: theme.iconTheme.color),
                const SizedBox(width: 8),
                Text(
                  '$label: ',
                  style: theme.textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(child: Text(value, style: theme.textTheme.titleSmall)),
              ],
            ),
  );
}
