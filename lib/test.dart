import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OnboardingPage(), // Properly wrapped with MaterialApp
    );
  }
}

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int? selectedIndex; // Store the selected option index

  final List<String> options = [
    "Student",
    "Professional",
    "Explorer",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Onboarding")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Which best describes you?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            for (int i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selectedIndex == i
                        ? Colors.blueAccent
                        : Colors.transparent,
                    side: BorderSide(
                      color: selectedIndex == i
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      options[i],
                      style: TextStyle(
                        color: selectedIndex == i
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: selectedIndex != null
                    ? () {
                  final selectedOption = options[selectedIndex!];
                  print("Selected option: $selectedOption");
                  // Navigate or store preference here
                }
                    : null,
                child: Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






