import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final List<String> questions = [
    "Little interest or pleasure in doing things?",
    "Feeling down, depressed, or hopeless?",
    "Trouble falling or staying asleep, or sleeping too much?",
    "Feeling tired or having little energy?",
    "Poor appetite or overeating?",
    "Feeling bad about yourself — or that you are a failure?",
    "Trouble concentrating on things, such as reading or watching TV?",
    "Moving or speaking so slowly that other people notice, or being fidgety?",
    "Thoughts that you would be better off dead or hurting yourself?",
  ];

  List<int> answers = List.filled(9, 0);
  int _currentQuestion = 0;

  void _nextQuestion() {
    if (_currentQuestion < questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      int totalScore = answers.reduce((a, b) => a + b);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('PHQ-9 Score'),
          content: Text('Your total score is $totalScore'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to dashboard or next feature
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _prevQuestion() {
    if (_currentQuestion > 0) setState(() => _currentQuestion--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / questions.length,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF56AB2F),
                minHeight: 8,
              ),
              const SizedBox(height: 20),

              // Question Counter
              Text(
                'Question ${_currentQuestion + 1} of ${questions.length}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Question Text
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    questions[_currentQuestion],
                    style: const TextStyle(fontSize: 20, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Answer Buttons
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final List<String> options = [
                      'Not at all',
                      'Several days',
                      'More than half the days',
                      'Nearly every day'
                    ];
                    final colors = [
                      Colors.green.shade50,
                      Colors.green.shade100,
                      Colors.green.shade200,
                      Colors.green.shade300
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            answers[_currentQuestion] = index;
                          });
                          _nextQuestion();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors[index],
                          foregroundColor: Colors.black87,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          options[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Previous Button
              if (_currentQuestion > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _prevQuestion,
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    label: const Text(
                      'Previous',
                      style: TextStyle(color: Colors.black54),
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
