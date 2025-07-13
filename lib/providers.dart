import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerProvider with ChangeNotifier {
  String _output = '';
  bool _isLoading = false;
  String _selectedLanguage = 'python';
  String _code = 'print("Hello World")';
  String _stdin = '';
  Map<String, dynamic> _languageVersions = {};
  String _selectedVersion = '';

  // Getters
  String get output => _output;
  bool get isLoading => _isLoading;
  String get selectedLanguage => _selectedLanguage;
  String get code => _code;
  String get stdin => _stdin;
  String get selectedVersion => _selectedVersion;
  List<String> get availableVersions => 
      _languageVersions[_selectedLanguage]?.cast<String>() ?? [];

  // Setters
  void setLanguage(String language) {
    _selectedLanguage = language;
    _selectedVersion = availableVersions.isNotEmpty ? availableVersions.first : '';
    notifyListeners();
  }

  void setCode(String code) => _code = code;
  void setStdin(String input) => _stdin = input;
  void setVersion(String version) {
    _selectedVersion = version;
    notifyListeners();
  }

  // Fetch available language runtimes
  Future<void> fetchRuntimes() async {
    try {
      final response = await http.get(
        Uri.parse('https://emkc.org/api/v2/piston/runtimes'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, List<String>> versions = {};
        
        for (var runtime in data) {
          final language = runtime['language'];
          final version = runtime['version'];
          versions.putIfAbsent(language, () => []).add(version);
        }
        
        _languageVersions = versions;
        _selectedVersion = availableVersions.isNotEmpty ? availableVersions.first : '';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching runtimes: $e');
    }
  }

    List<String> get availableLanguages => _languageVersions.keys.toList();
  // Execute code
  Future<void> compileAndExecute() async {
    _isLoading = true;
    _output = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://emkc.org/api/v2/piston/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'language': _selectedLanguage,
          'version': _selectedVersion,
          'files': [
            {
              'name': _getFileName(),
              'content': _code,
            }
          ],
          'stdin': _stdin,
        }),
      );

      final data = jsonDecode(response.body);
      _output = data['run']['output'] ?? 'No output';
      if (data['run']['stderr']?.isNotEmpty ?? false) {
        _output += '\n\nError: ${data['run']['stderr']}';
      }
    } catch (e) {
      _output = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getFileName() {
    switch (_selectedLanguage) {
      case 'python': return 'main.py';
      case 'java': return 'Main.java';
      case 'cpp': return 'main.cpp';
      case 'javascript': return 'script.js';
      default: return 'main';
    }
  }
}