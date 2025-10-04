import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../controllers/app_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';

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

  // Gemini AI integration
  late final GenerativeModel model;

  // Speech to text instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  // Text to speech instance
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = true;

  late AppPreferences appPreferences;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();


    // Initialize Gemini AI
    model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: 'AIzaSyD7Ub-fmdXtKoLH6rFBThNDKEA3NKiMAbA' // Replace with your actual API key
    );

    _loadPreferences();
    _initSpeech();
    _initTts();
  }


  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    appPreferences = AppPreferences(prefs);

    setState(() {
      _selectedLanguage = appPreferences.getPreferredLanguage();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add welcome message after context is available
    if (messages.isEmpty) {
      final loc = AppLocalizations.of(context);
      if (loc != null) {
        _addWelcomeMessage(loc.welcomeMessage);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _addWelcomeMessage(messageText) {
    messages.add(AIMessage(
      text: messageText,
      isAI: true,
      timestamp: DateTime.now(),
    ));
    setState(() {});
  }

  // Initialize speech recognition
  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  // Initialize text to speech
  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void _changeLanguage(String lang) async {
    String selectedLang;

    switch (lang.toLowerCase()) {
      case 'english':
        selectedLang = 'en-US';
        break;
      case 'french':
        selectedLang = 'fr-FR';
        break;
      case 'arabic':
        selectedLang = 'ar-EG';
        break;
      default:
        selectedLang = 'en-US';
    }

    await _flutterTts.setLanguage(selectedLang);
  }

  // Start listening for speech input
  void _startListening() async {
    _recognizedText = '';
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });

        // Get locale based on current language
        String localeId = _getLocaleId();

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              _messageController.text = _recognizedText;
            });
          },
          localeId: localeId, // Specify the locale
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            cancelOnError: true,
            listenMode: stt.ListenMode.confirmation,
          ),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }

  // Get locale ID based on current language
  String _getLocaleId() {
    switch (_selectedLanguage.toLowerCase()) {
      case 'en':
        return 'en-US';
      case 'fr':
        return 'fr-FR';
      case 'ar':
        return 'ar-SA'; // Saudi Arabic, also try 'ar-EG' for Egyptian
      default:
        return 'en-US';
    }
  }

  // Speak the given text
  Future<void> _speak(String text) async {
    if (text.isNotEmpty && _isSpeaking) {
      await _flutterTts.speak(text);
    }
  }

  // Stop speaking
  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
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
      showCustomSnackBar(context, (AppLocalizations.of(context)!.errorPickingImage));
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty && selectedImage == null) return;
    final loc = AppLocalizations.of(context)!;

    // Add user message
    messages.add(AIMessage(
      text: messageText.isNotEmpty ? messageText : loc.photoAnalysisRequest,
      isAI: false,
      timestamp: DateTime.now(),
      imageFile: selectedImage,
    ));

    _messageController.clear();
    selectedImage = null;
    setState(() {
      isLoading = true;
    });

    if (_isSpeaking) {
      await _stopSpeaking();
    }

    _scrollToBottom();

    try {
      final conversationHistory = messages.map((msg) =>
      '${msg.isUser ? "User" : "Assistant"}: ${msg.content}')
          .join('\n');

      // Create the prompt with farming assistant context
      String systemPrompt = """      
        Previous Conversation:
        $conversationHistory
        
        You are an AI Farming Assistant designed to help farmers with:
        - Plant disease identification and treatment
        - Crop care advice and best practices
        - Soil health and fertilizer recommendations
        - Irrigation guidance and water management
        - Pest control strategies
        - Weather-based farming tips
        
        Provide practical, actionable advice that farmers can implement.
        Keep responses conversational, helpful, and concise.
        Always respond in the same language the user used in their last message.
        
        Return a JSON object with the following keys:
        - "response": your helpful farming advice as a string
        - "language": the language detected (en for english,fr for french and ar for arabic)
      """;

      final content = Content.text(systemPrompt);
      final response = await model.generateContent([content]);
      final extractedJson = _extractJson(response.text!);

      final jsonResponse = json.decode(extractedJson);

      setState(() {
        isLoading = false;
      });

      // Update language if changed
      if(_selectedLanguage != jsonResponse['language']) {
        _selectedLanguage = jsonResponse['language'];
        _changeLanguage(jsonResponse['language']);
      }

      final aiResponseText = jsonResponse['response'] ??
          'I apologize, but I encountered an issue processing your request.';

      messages.add(AIMessage(
        text: aiResponseText,
        isAI: true,
        timestamp: DateTime.now(),
      ));

      // Speak the response
      _speak(aiResponseText);

    } catch (e) {
      final errorMessage = loc.genericError;
      messages.add(AIMessage(
        text: errorMessage,
        isAI: true,
        timestamp: DateTime.now(),
      ));
      _speak(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _extractJson(String responseText) {
    final RegExp regex = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final Match? match = regex.firstMatch(responseText);

    if (match != null) {
      return match.group(1)!;
    } else {
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonStart < jsonEnd) {
        return responseText.substring(jsonStart, jsonEnd + 1);
      }

      return '{"response": "I\'m having trouble processing your request. Could you try again?", "language": "english"}';
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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology, size: 24),
            SizedBox(width: 8),
            Text(loc.appBarTitle),
          ],
        ),
        actions: [
          // Toggle text-to-speech
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_off,
            ),
            onPressed: () {
              setState(() {
                _isSpeaking = !_isSpeaking;
              });
              if (!_isSpeaking) {
                _stopSpeaking();
              }
            },
          ),
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
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.aiBanner,
                    style: const TextStyle(
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
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                loc.aiAnalyzing,
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
                // Microphone button
                GestureDetector(
                  onTap: _startListening,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : theme.primaryColor.withAlpha(180),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.camera_alt,
                    color: theme.primaryColor,
                  ),
                  tooltip: loc.takePhotoForAnalysis,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _isListening ? loc.listening : loc.askAnything,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: _isListening ? Colors.red[400] : null,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
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
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(loc.helpTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.helpWhatCanHelp,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.camera_alt, loc.plantDiseaseId, loc.takePhotosOfSickPlants),
            _buildHelpItem(Icons.water_drop, loc.irrigationAdvice, loc.wateringSchedulesAndTechniques),
            _buildHelpItem(Icons.grass, loc.cropCare, loc.fertilizersSoilNutrition),
            _buildHelpItem(Icons.bug_report, loc.pestControl, loc.identifyAndTreatPlantPests),
            _buildHelpItem(Icons.wb_sunny, loc.weatherTips, loc.weatherBasedFarmingGuidance),
            const SizedBox(height: 12),
            Text(
              loc.voiceFeatures,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(loc.voiceFeaturesDesc,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              loc.tipsForBetterResults,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(loc.tipsDesc,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.gotIt),
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

  // Helper getter for consistency with old code
  bool get isUser => !isAI;
  String get content => text;
}