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
        title: const Text(
          'Select a Domain',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: -2.5,
                    offset: Offset(7, 7),
                  ),
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(7, 7),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  domains[index].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
