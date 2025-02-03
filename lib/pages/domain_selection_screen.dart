import 'package:flutter/material.dart';
import 'prompt_selection_screen.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

// Define the color palette
final Color primaryColor = Color(0xFF3539AC);
final Color secondaryColor = Color(0xFF11BDE3);

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140.0),
        child: ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, left: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 0.0, right: 80.0, bottom: 20),
                    child: Text(
                      'Domain Selection',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nacelle',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(4, 4), // changes position of shadow
                  ),
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: -2,
                    blurRadius: 8,
                    offset: Offset(-4, -4), // changes position of shadow
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  domains[index].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
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
