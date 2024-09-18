import 'dart:convert';
import "package:flutter/material.dart";
import 'package:dio/dio.dart';

class GamePageProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  List? questions;
  final String difficultyLevel;
  int _currentQuestionCount = 0;
  int _maxQuestions = 10;
  int _correctCount = 0;

  BuildContext context;
  GamePageProvider({required this.context, required this.difficultyLevel}) {
    _dio.options.baseUrl = 'https://opentdb.com/api.php';
    _getQuestionsFromAPI();
  }

  Future<void> _getQuestionsFromAPI() async {
    var _response = await _dio.get(
      '',
      queryParameters: {
        'amount': 10,
        'type': 'boolean',
        'difficulty': difficultyLevel,
      },
    );
    var _data = jsonDecode(_response.toString());
    // print(_data);
    questions = _data["results"];
    notifyListeners();
  }

  String getCurrentQuestionText() {
    return questions![_currentQuestionCount]["question"];
  }

  void answerQuestion(String _answer) async {
    bool isCorrect =
        questions![_currentQuestionCount]["correct_answer"] == _answer;
    _currentQuestionCount++;
    //print(isCorrect ? "correct" : "InCorrect");
    _correctCount += isCorrect ? 1 : 0;
    showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissal on outside tap
        builder: (BuildContext _context) {
          return AlertDialog(
            backgroundColor: isCorrect ? Colors.green : Colors.red,
            title: Icon(
              isCorrect ? Icons.check_circle : Icons.cancel_sharp,
              color: Colors.white,
            ),
          );
        });
    await Future.delayed(const Duration(seconds: 1));

    Navigator.pop(context);
    if (_currentQuestionCount == _maxQuestions) {
      endGame();
    } else {
      notifyListeners();
    }
  }

  Future<void> endGame() async {
    showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissal on outside tap
        builder: (BuildContext _context) {
          return AlertDialog(
            backgroundColor: Colors.blue,
            title: const Text(
              'End Game!',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            content: Text(
              "Score: $_correctCount/$_maxQuestions",
              style: const TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
            ),
          );
        });
    await Future.delayed(const Duration(seconds: 3));
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // First pop: dismiss the dialog
    }

    await Future.delayed(const Duration(
        milliseconds: 300)); // Add a slight delay for smoother transition

    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Second pop: pop back to the previous screen
    }
  }
}
