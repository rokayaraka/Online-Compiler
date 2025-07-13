import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Add this variable at the top of your class (if not already present)
// Make sure your class extends ChangeNotifier
class CompilerService extends ChangeNotifier {
  bool _isLoading = false;
  String _selectedLanguage = 'python'; // Set a default language or update as needed
  String _code = ''; // Add this line to define the _code variable
  String _output = ''; // Add this line to define the _output variable

  Future<void> compileAndExecute() async {
    _isLoading = true;
    notifyListeners();
  _isLoading = true;
  notifyListeners();

  try {
    final response = await http.post(
      Uri.parse('https://emkc.org/api/v2/piston/execute'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'language': _selectedLanguage,
        'source': _code,
      }),
    );

    final data = jsonDecode(response.body);
    _output = data['run']['output'] ?? 'No output';
  } catch (e) {
    _output = 'Error: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
  }
}