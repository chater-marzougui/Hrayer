
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:math';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  List<AIMessage> messages = [];
  bool isLoading = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    messages.add(AIMessage(
      text: '🌱 Hello! I\'m your AI farming assistant. I can help you with:\n\n'
          '• Plant disease identification\n'
          '• Crop care advice\n'
          '• Soil and fertilizer recommendations\n'
          '• Irrigation guidance\n'
          '• Weather-based farming tips\n\n'
          'Feel free to ask questions or upload photos of your plants!',
      isAI: true,
      timestamp: DateTime.now(),
    ));
    setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty && selectedImage == null) return;

    // Add user message
    messages.add(AIMessage(
      text: messageText.isNotEmpty ? messageText : 'Photo analysis request',
      isAI: false,
      timestamp: DateTime.now(),
      imageFile: selectedImage,
    ));

    _messageController.clear();
    selectedImage = null;
    setState(() {
      isLoading = true;
    });

    _scrollToBottom();

    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock AI response
    String aiResponse = _generateAIResponse(messageText);

    messages.add(AIMessage(
      text: aiResponse,
      isAI: true,
      timestamp: DateTime.now(),
    ));

    setState(() {
      isLoading = false;
    });
    _scrollToBottom();
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Plant disease responses
    if (message.contains('disease') || message.contains('sick') || message.contains('dying')) {
      return _getRandomResponse([
        '🔍 Based on common symptoms, this could be:\n\n'
            '• **Fungal infection** - Apply copper-based fungicide\n'
            '• **Nutrient deficiency** - Check soil pH and add balanced fertilizer\n'
            '• **Overwatering** - Reduce irrigation frequency\n\n'
            'Monitor for 3-5 days and let me know if symptoms persist.',

        '🌿 Plant health analysis:\n\n'
            '• **Yellow leaves** - Often nitrogen deficiency or overwatering\n'
            '• **Brown spots** - Likely fungal disease, improve air circulation\n'
            '• **Wilting** - Check soil moisture and root health\n\n'
            'Would you like specific treatment recommendations?',
      ]);
    }

    // Irrigation advice
    if (message.contains('water') || message.contains('irrigation')) {
      return _getRandomResponse([
        '💧 Irrigation recommendations:\n\n'
            '• **Morning watering** (6-8 AM) is most effective\n'
            '• **Deep, less frequent** watering promotes root growth\n'
            '• **Check soil moisture** 2-3 inches deep before watering\n'
            '• **Mulching** reduces water evaporation by 30-50%\n\n'
            'What crop are you growing? I can provide specific guidance.',

        '🚿 Smart watering tips:\n\n'
            '• **Sandy soil**: Water more frequently, less volume\n'
            '• **Clay soil**: Water less frequently, more volume\n'
            '• **Drip irrigation**: 90% more efficient than sprinklers\n\n'
            'Current weather suggests watering every 2-3 days.',
      ]);
    }

    // Fertilizer advice
    if (message.contains('fertilizer') || message.contains('nutrient')) {
      return _getRandomResponse([
        '🌱 Fertilizer guidance:\n\n'
            '• **N-P-K ratio** depends on growth stage\n'
            '• **Vegetative stage**: High nitrogen (20-10-10)\n'
            '• **Flowering stage**: Higher phosphorus (10-20-10)\n'
            '• **Organic options**: Compost, bone meal, fish emulsion\n\n'
            'When did you last fertilize? I can suggest timing.',

        '🧪 Nutrient management:\n\n'
            '• **Soil test first** - Know what your soil needs\n'
            '• **Slow-release fertilizers** reduce nutrient loss\n'
            '• **Foliar feeding** for quick nutrient uptake\n'
            '• **Avoid over-fertilizing** - Can burn roots\n\n'
            'What symptoms are you seeing in your plants?',
      ]);
    }

    // General farming advice
    if (message.contains('pest') || message.contains('insect')) {
      return _getRandomResponse([
        '🐛 Integrated Pest Management:\n\n'
            '• **Identify the pest** first - Different treatments needed\n'
            '• **Natural predators** - Encourage beneficial insects\n'
            '• **Neem oil** - Effective organic pesticide\n'
            '• **Companion planting** - Natural pest deterrent\n\n'
            'Can you describe the pest or upload a photo?',

        '🛡️ Pest control strategies:\n\n'
            '• **Prevention first** - Healthy plants resist pests better\n'
            '• **Crop rotation** - Breaks pest life cycles\n'
            '• **Physical barriers** - Row covers, sticky traps\n'
            '• **Organic sprays** - Soap solution, garlic spray\n\n'
            'What type of damage are you seeing?',
      ]);
    }

    // Weather-related advice
    if (message.contains('weather') || message.contains('rain') || message.contains('sun')) {
      return _getRandomResponse([
        '🌤️ Weather-based farming tips:\n\n'
            '• **Before rain**: Harvest ripe crops, secure supports\n'
            '• **Hot weather**: Increase watering, provide shade cloth\n'
            '• **Cold snap**: Cover sensitive plants, move containers\n'
            '• **Windy conditions**: Stake tall plants, check irrigation\n\n'
            'Check local 7-day forecast for planning.',

        '🌡️ Climate adaptation strategies:\n\n'
            '• **Mulching** - Protects from temperature extremes\n'
            '• **Season extension** - Row covers, cold frames\n'
            '• **Drought-resistant varieties** - For dry climates\n'
            '• **Proper timing** - Plant according to frost dates\n\n'
            'What\'s your local growing zone?',
      ]);
    }

    // Default responses
    return _getRandomResponse([
      '🤖 I\'d be happy to help! Could you provide more details about:\n\n'
          '• What crop you\'re growing\n'
          '• The specific problem you\'re facing\n'
          '• Current growing conditions\n\n'
          'The more information you provide, the better I can assist you!',

      '🌾 Thanks for your question! To give you the best advice, I need to know:\n\n'
          '• Your location and climate\n'
          '• What stage your crops are in\n'
          '• Any symptoms you\'re observing\n\n'
          'Feel free to upload photos - they help a lot with diagnosis!',

      '👨‍🌾 I\'m here to help with all your farming questions! You can ask me about:\n\n'
          '• Plant diseases and treatment\n'
          '• Soil health and fertilizers\n'
          '• Irrigation and water management\n'
          '• Pest control strategies\n\n'
          'What would you like to know more about?',
    ]);
  }

  String _getRandomResponse(List<String> responses) {
    final random = Random();
    return responses[random.nextInt(responses.length)];
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

  Widget _buildMessage(AIMessage message) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isAI) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green.withAlpha(76),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isAI
                    ? theme.cardColor
                    : theme.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        message.imageFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isAI ? null : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isAI
                          ? Colors.grey[600]
                          : Colors.white.withAlpha(178),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!message.isAI) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.pink.withAlpha(76),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.psychology, size: 24),
            SizedBox(width: 8),
            Text('AI Farming Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // AI capabilities banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              border: Border(
                bottom: BorderSide(color: Colors.green.withAlpha(76)),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-powered plant disease identification • Crop care advice • 24/7 availability',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.green.withAlpha(76),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI is analyzing...',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _buildMessage(messages[index]);
              },
            ),
          ),

          // Image preview
          if (selectedImage != null) ...[
            Container(
              height: 100,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withAlpha(76)),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

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
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.camera_alt,
                    color: theme.primaryColor,
                  ),
                  tooltip: 'Take photo for analysis',
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ask about crops, diseases, fertilizers...',
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

  void _showHelpDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: theme.primaryColor),
            const SizedBox(width: 8),
            const Text('AI Assistant Help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What can the AI help you with:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.camera_alt, 'Plant Disease ID', 'Take photos of sick plants'),
            _buildHelpItem(Icons.water_drop, 'Irrigation Advice', 'Watering schedules and techniques'),
            _buildHelpItem(Icons.grass, 'Crop Care', 'Fertilizers, soil, and nutrition'),
            _buildHelpItem(Icons.bug_report, 'Pest Control', 'Identify and treat plant pests'),
            _buildHelpItem(Icons.wb_sunny, 'Weather Tips', 'Weather-based farming guidance'),
            const SizedBox(height: 12),
            Text(
              'Tips for better results:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text('• Take clear, well-lit photos\n'
                '• Provide specific details about your problem\n'
                '• Mention your crop type and location\n'
                '• Ask follow-up questions for clarification',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class AIMessage {
  final String text;
  final bool isAI;
  final DateTime timestamp;
  final File? imageFile;

  AIMessage({
    required this.text,
    required this.isAI,
    required this.timestamp,
    this.imageFile,
  });
}

class AIMessageBubble extends StatelessWidget {
  final AIMessage message;

  const AIMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAI = message.isAI;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
      isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isAI) ...[
          const Icon(
            Icons.psychology,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isAI ? theme.cardColor : Colors.green.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageFile != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      message.imageFile!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isAI) ...[
          const SizedBox(width: 12),
          const Icon(
            Icons.person,
            color: Colors.orange,
            size: 20,
          ),
        ],
      ],
    );
  }
}

