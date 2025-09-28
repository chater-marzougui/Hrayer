import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../structures/land_models.dart';

class ChatFarmersScreen extends StatefulWidget {
  final LandModel land;

  const ChatFarmersScreen({required this.land, super.key});

  @override
  State<ChatFarmersScreen> createState() => _ChatFarmersScreenState();
}

class _ChatFarmersScreenState extends State<ChatFarmersScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late CollectionReference messagesRef;
  String? currentUserName;
  String? currentUserRole;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.land.id)
        .collection('messages');
    _getCurrentUserInfo();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserInfo() async {
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
            currentUserName = userData['name'] ?? 'User';
            currentUserRole = userData['role'] ?? 'sponsor';
          });
        }
      }
    } catch (e) {
      setState(() {
        currentUserName = 'User';
        currentUserRole = 'sponsor';
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final messageData = {
        'landId': widget.land.id,
        'senderId': currentUser.uid,
        'senderName': currentUserName ?? 'User',
        'senderRole': currentUserRole ?? 'sponsor',
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await messagesRef.add(messageData);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        showCustomSnackBar(context, loc.failedToSendMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(ChatMessage message) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = message.senderId == currentUser?.uid;
    final isSystemMessage = message.senderRole == 'system';

    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withAlpha(76)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color avatarColor;
    IconData avatarIcon;

    switch (message.senderRole) {
      case 'farmer':
        avatarColor = Colors.pink.withAlpha(76);
        avatarIcon = Icons.landslide_outlined;
        break;
      case 'sponsor':
        avatarColor = Colors.orange.withAlpha(76);
        avatarIcon = Icons.volunteer_activism;
        break;
      default:
        avatarColor = Colors.grey.withAlpha(76);
        avatarIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: avatarColor,
              child: Icon(
                avatarIcon,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? theme.primaryColor
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      '${message.senderName} (${_getRoleDisplayName(message.senderRole)})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(message.senderRole),
                      ),
                    ),
                  if (!isCurrentUser) const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : null,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white.withAlpha(178)
                          : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: currentUserRole == 'farmer'
                  ? Colors.pink.withAlpha(76)
                  : Colors.orange.withAlpha(76),
              child: Icon(
                currentUserRole == 'farmer' ? Icons.landslide_outlined : Icons.volunteer_activism,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'farmer':
        return 'Farmer';
      case 'sponsor':
        return 'Sponsor';
      default:
        return 'User';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'farmer':
        return Colors.pink[700]!;
      case 'sponsor':
        return Colors.orange[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildParticipantsList() {
    final theme = Theme.of(context);
    final totalParticipants = widget.land.sponsors.length + 1; // +1 for the farmer

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(25),
        border: Border(
          bottom: BorderSide(color: theme.primaryColor.withAlpha(76)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.group, color: theme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.land.title,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$totalParticipants participants • ${widget.land.intendedCrop} • ${widget.land.progressPercentage.toStringAsFixed(0)}% funded',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.land.isActive ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.land.isActive ? 'ACTIVE' : 'COMPLETED',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectInfo() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
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
            Row(
              children: [
                Icon(Icons.agriculture, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  loc.projectInformation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(loc.projectName, widget.land.title),
            _buildInfoRow(loc.location, widget.land.location),
            _buildInfoRow(loc.size, '${widget.land.size} hectares'),
            _buildInfoRow(loc.crop, widget.land.intendedCrop),
            _buildInfoRow(loc.totalNeeded, '\${widget.land.totalNeeded.toStringAsFixed(0)}'),
            _buildInfoRow(loc.amountRaised, '\${widget.land.totalFulfilled.toStringAsFixed(0)}'),
            _buildInfoRow(loc.progress, '${widget.land.progressPercentage.toStringAsFixed(1)}%'),
            _buildInfoRow(loc.sponsors, '${widget.land.sponsors.length}'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: widget.land.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.projectChat,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${widget.land.sponsors.length + 1} participants',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showProjectInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Project info banner
          _buildParticipantsList(),

          // Chat guidelines banner
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.withAlpha(25),
            child: Row(
              children: [
                Icon(Icons.shield, color: Colors.blue[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.transparentGroupChatDisclaimer,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          loc.errorLoadingMessages,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${snapshot.error}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs
                    .map((doc) => ChatMessage.fromFirestore(doc))
                    .toList() ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.noMessagesYet,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.startTheConversation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.primaryColor.withAlpha(76)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lightbulb_outline, color: theme.primaryColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                loc.tipShareProgress,
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    // Add date separator if needed
                    bool showDateSeparator = false;
                    if (index == 0) {
                      showDateSeparator = true;
                    } else {
                      final prevMessage = messages[index - 1];
                      final currentDate = DateTime(
                        message.timestamp.year,
                        message.timestamp.month,
                        message.timestamp.day,
                      );
                      final prevDate = DateTime(
                        prevMessage.timestamp.year,
                        prevMessage.timestamp.month,
                        prevMessage.timestamp.day,
                      );
                      showDateSeparator = !currentDate.isAtSameMomentAs(prevDate);
                    }

                    return Column(
                      children: [
                        if (showDateSeparator) ...[
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDate(message.timestamp),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        _buildMessage(message),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(51),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: currentUserRole == 'farmer'
                          ? loc.shareAnUpdateWithSponsors
                          : loc.sendEncouragementOrAskQuestions,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: isLoading ? null : _sendMessage,
                    icon: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}