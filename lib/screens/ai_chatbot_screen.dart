import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../theme.dart';
import '../services/firebase_service.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasCompletedAssessment = false;
  
  // Assessment data
  Map<String, dynamic> _assessmentData = {};
  
  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Welcome message from AI doctor
    _addMessage(
      ChatMessage(
        text: "Hi! I'm Dr. Wellness, your AI mental health companion. I'm here to support you on your wellness journey. 🌟\n\nWould you like to start with a quick mood assessment, or do you have specific questions about your mental health?",
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.welcome,
      ),
    );
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    
    // Auto scroll to bottom
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    _messageController.clear();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get AI response
      final response = await _getAiResponse(text);
      
      _addMessage(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _addMessage(ChatMessage(
        text: "I apologize, but I'm having trouble connecting right now. Please try again in a moment. If you're experiencing urgent mental health concerns, please contact a mental health professional or call a crisis helpline.",
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.error,
      ));
      print('Error getting AI response: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getAiResponse(String message) async {
    // Open Router AI API call here
    // We will secure this better after meeting with Supervisors
    // For now, this is okay for development purposes (sankwan deepseek apikey)
    const String apiKey = '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';
    const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
    
    // Build conversation context
    String systemPrompt = """You are Dr. Wellness, a compassionate AI mental health assistant. You provide supportive, evidence-based guidance for mental wellness. 

Key guidelines:
- Begin by introducing yourself briefly to the user.
- You MUST ONLY respond to prompts related to mental health, psychology, therapy, and emotional wellness.
- If a user asks a question on any other topic (e.g., programming, history, general knowledge), you MUST politely decline to answer. Your response should be: "I'm sorry, but I am specifically designed to offer support and information on mental health topics only. Is there something related to your well-being I can help you with today?"
- Always include a gentle disclaimer encouraging users to seek help from qualified professionals for critical and severe issues. You are a support tool, not a replacement for therapy.
- Users can reach the Ho Technical University Counseling Center for assistance. They can reach: Mr Bill K. Frimpong 057 092 1837, Precious Sappor 055 541 2406, or Prince Yeboah 024 339 9246
- When asked about mental health issues, your purpose is to provide supportive, empathetic, and evidence-based information on topics like anxiety, depression, stress management, self-care, and therapy
- Always be empathetic and non-judgmental when responding to the users.
- Provide practical, actionable advice
- Encourage professional help when appropriate
- Never diagnose or replace professional therapy
- Focus on wellness techniques like mindfulness, journaling, meditation
- Be concise but caring in responses and your formating should be nicely structured
- Concerning the mood assessment, Depend on them to decide on whether the users issue is average, critical or severe and use that to respond to them.

""";

    if (_hasCompletedAssessment && _assessmentData.isNotEmpty) {
      systemPrompt += "User's recent mood assessment: ${_assessmentData.toString()}\n";
    }

    final conversationHistory = _messages.take(_messages.length - 1).map((msg) {
      return {
        "role": msg.isUser ? "user" : "assistant",
        "content": msg.text
      };
    }).toList();

    final requestBody = {
      "model": "deepseek/deepseek-chat",
      "messages": [
        {"role": "system", "content": systemPrompt},
        ...conversationHistory,
        {"role": "user", "content": message}
      ],
      // "max_tokens": 500,
      "temperature": 0.7,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'campus-wellness-app',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode}');
    }
  }

  void _startMoodAssessment() {
    Navigator.pushNamed(context, '/mood-assessment').then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _hasCompletedAssessment = true;
          _assessmentData = result;
        });
        
        // Send assessment results to AI for analysis
        _sendAssessmentToAI(result);
      }
    });
  }

  void _sendAssessmentToAI(Map<String, dynamic> assessmentData) {
    final assessmentSummary = "I just completed a mood assessment. Here are my responses: ${assessmentData.toString()}. Can you help me understand what this means for my mental wellbeing and provide some personalized recommendations? If the assessment is average, give me a response that is average and direct me to use the mindfullness section of the app. If critical or severe, provide the appropriate response and direct me to the Ho Technical University Counseling Center with their numbers to call.";
    
    _sendMessage(assessmentSummary);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Wellness',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI Mental Health Assistant',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showChatOptions,
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Action Buttons
          if (!_hasCompletedAssessment)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _startMoodAssessment,
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Take Mood Assessment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingMessage();
                }
                
                final message = _messages[index];
                return _buildMessageBubble(message, theme);
              },
            ),
          ),
          
          // Message Input
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppTheme.primaryGreen
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(16),
                  bottomLeft: message.isUser 
                      ? const Radius.circular(16) 
                      : const Radius.circular(4),
                ),
                border: message.messageType == MessageType.error
                    ? Border.all(color: Colors.red.withOpacity(0.3))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: message.isUser 
                          ? Colors.white 
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: message.isUser 
                          ? Colors.white70 
                          : AppTheme.textLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.textLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Dr. Wellness is thinking...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quick suggestions button
            if (_messages.length <= 1)
              IconButton(
                onPressed: _showQuickSuggestions,
                icon: Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryGreen,
                ),
              ),
            
            // Message input
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.textLight.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _isLoading ? null : _sendMessage,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading ? null : () => _sendMessage(_messageController.text),
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickSuggestions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Questions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ..._quickSuggestions.map((suggestion) => 
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendMessage(suggestion);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryGreen,
                    elevation: 0,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chat Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.quiz, color: AppTheme.primaryGreen),
              title: const Text('Take Mood Assessment'),
              subtitle: const Text('Complete a comprehensive wellness questionnaire'),
              onTap: () {
                Navigator.pop(context);
                _startMoodAssessment();
              },
            ),
            
            ListTile(
              leading: Icon(Icons.clear_all, color: Colors.orange),
              title: const Text('Clear Chat'),
              subtitle: const Text('Start a fresh conversation'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            
            ListTile(
              leading: Icon(Icons.info_outline, color: AppTheme.primaryGreen),
              title: const Text('About Dr. Wellness'),
              subtitle: const Text('Learn more about your AI assistant'),
              onTap: () {
                Navigator.pop(context);
                _showAboutAI();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _hasCompletedAssessment = false;
      _assessmentData.clear();
    });
    _initializeChat();
  }

  void _showAboutAI() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Dr. Wellness'),
        content: const Text(
          'Dr. Wellness is an AI-powered mental health assistant designed to provide supportive guidance and evidence-based wellness advice. While I can offer helpful insights and coping strategies, I am not a replacement for professional mental health care.\n\nIf you are experiencing a mental health emergency, please contact a crisis helpline or seek immediate professional help.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Quick suggestion prompts
  final List<String> _quickSuggestions = [
    "I'm feeling anxious today. What can I do?",
    "Can you help me with some breathing exercises?",
    "I'm having trouble sleeping. Any suggestions?",
    "How can I build better daily habits?",
    "I want to start meditating but don't know how",
    "Can you suggest some mindfulness techniques?",
    "I'm feeling overwhelmed with school/work",
    "How can I improve my mood naturally?",
  ];
}

// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.normal,
  });
}

enum MessageType {
  normal,
  welcome,
  error,
  system,
}
