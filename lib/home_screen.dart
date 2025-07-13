import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import 'package:online_compiler/services/compiler_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompilerProvider>(context, listen: false).fetchRuntimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompilerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Compiler'),
        actions: [
          DropdownButton<String>(
            value: provider.selectedLanguage,
            items: provider.availableLanguages.map((language) {
              return DropdownMenuItem(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                provider.setLanguage(value);
              }
            },
          ),
          if (provider.availableVersions.isNotEmpty)
            DropdownButton<String>(
              value: provider.selectedVersion,
              items: provider.availableVersions.map((version) {
                return DropdownMenuItem(
                  value: version,
                  child: Text(version),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setVersion(value);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HighlightView(
                provider.code,
                language: provider.selectedLanguage,
                theme: githubTheme,
                padding: const EdgeInsets.all(12),
                textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Input (STDIN)',
                border: OutlineInputBorder(),
              ),
              onChanged: provider.setStdin,
            ),
          ),
          ElevatedButton(
            onPressed: provider.isLoading ? null : provider.compileAndExecute,
            child: provider.isLoading 
                ? const CircularProgressIndicator()
                : const Text('Run Code'),
          ),
                    Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(200.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: SingleChildScrollView(
                child: Text(
                  provider.output,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}