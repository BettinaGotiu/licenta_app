import 'package:flutter/material.dart';
import 'prompt_selection_screen.dart';

class DomainSelectionPage extends StatelessWidget {
  final List<String> domains = [
    'art',
    'career',
    'education',
    'environment',
    'imagination',
    'mindset',
    'science',
    'sport',
    'technology'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Domain'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: domains.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PromptSelectionPage(domain: domains[index]),
                ),
              );
            },
            child: Card(
              elevation: 5,
              child: Center(
                child: Text(
                  domains[index].toUpperCase(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
