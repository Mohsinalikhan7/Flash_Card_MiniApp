import 'package:flutter/material.dart';

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 150, 135, 140),
        useMaterial3: true,
      ),
      home: const FlashcardHomePage(),
    );
  }
}

class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});
}

class FlashcardHomePage extends StatefulWidget {
  const FlashcardHomePage({super.key});

  @override
  State<FlashcardHomePage> createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage> {
  // Starter deck — users can add, edit, or delete freely.
  final List<Flashcard> _cards = [
    Flashcard(
      question: 'What is Flutter?',
      answer:
          'An open-source UI toolkit by Google for building natively compiled apps.',
    ),
    Flashcard(question: 'What language does Flutter use?', answer: 'Dart'),
    Flashcard(
      question: 'What widget starts every Flutter app?',
      answer: 'runApp()',
    ),
    Flashcard(
      question: 'What is stateless widgets',
      answer: 'That can not change its state',
    ),
    Flashcard(
      question: 'What is statefull widgets',
      answer: 'That can change its state',
    ),
  ];

  int _currentIndex = 0;
  bool _showAnswer = true;

  Flashcard? get _currentCard => _cards.isEmpty ? null : _cards[_currentIndex];

  void _goNext() {
    if (_cards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
      _showAnswer = false;
    });
  }

  void _goPrevious() {
    if (_cards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
      _showAnswer = false;
    });
  }

  void _toggleAnswer() {
    if (_cards.isEmpty) return;
    setState(() => _showAnswer = !_showAnswer);
  }

  void _openCardDialog({Flashcard? existing}) {
    final questionController = TextEditingController(
      text: existing?.question ?? '',
    );
    final answerController = TextEditingController(
      text: existing?.answer ?? '',
    );
    final isEditing = existing != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Flashcard' : 'Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final q = questionController.text.trim();
                final a = answerController.text.trim();
                if (q.isEmpty || a.isEmpty) return;

                setState(() {
                  if (isEditing) {
                    existing.question = q;
                    existing.answer = a;
                  } else {
                    _cards.add(Flashcard(question: q, answer: a));
                    _currentIndex = _cards.length - 1;
                  }
                  _showAnswer = false;
                });
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCurrentCard() {
    if (_cards.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _cards.removeAt(_currentIndex);
                if (_currentIndex >= _cards.length && _cards.isNotEmpty) {
                  _currentIndex = _cards.length - 1;
                }
                _showAnswer = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _currentCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Quiz'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_cards.isNotEmpty)
                Text(
                  'Card ${_currentIndex + 1} of ${_cards.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: card == null
                    ? const Center(
                        child: Text(
                          'No flashcards yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : GestureDetector(
                        onTap: _toggleAnswer,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            key: ValueKey('$_currentIndex-$_showAnswer'),
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _showAnswer ? 'ANSWER' : 'QUESTION',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: _showAnswer
                                          ? Colors.green
                                          : Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _showAnswer ? card.answer : card.question,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (card != null)
                FilledButton.tonal(
                  onPressed: _toggleAnswer,
                  child: Text(_showAnswer ? 'Show Question' : 'Show Answer'),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _cards.isEmpty ? null : _goPrevious,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _cards.isEmpty ? null : _goNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: card == null
                        ? null
                        : () => _openCardDialog(existing: card),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: card == null ? null : _deleteCurrentCard,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCardDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
