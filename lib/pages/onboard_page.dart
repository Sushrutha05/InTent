import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:student_dating_app/pages/home_page.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
  }

class _OnboardingScreenState extends State<OnboardingScreen> {

  //controller for page
  PageController _controller = PageController();
  //Keeping track of the page that we are in
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (pageNo){
              setState(() {
                onLastPage = (pageNo == 4);
              });
            },
            children: [
              OnboardingPage1(),
              OnboardingPage2(),
              OnboardingPage3(),
              OnboardingPage4(),
              OnboardingPage5(),
            ],
          ),

          //dot indicator
          Container(
            alignment: Alignment(0,0.9),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    child: Text("Previous"),
                    onTap:(){ _controller.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );},
                  ),

                  SmoothPageIndicator(
                    controller: _controller,
                    count: 5,
                    effect: ExpandingDotsEffect(  // Customize dot effect
                      activeDotColor: Colors.blue,
                      dotColor: Colors.grey,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),),

                  onLastPage?
                      GestureDetector(
                        child: Text("Start Swiping"),
                        onTap: (){Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage())
                        );},
                      )
                  :
                    GestureDetector(
                      child: Text("Next"),
                      onTap:(){ _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );},
                    )

                ],
              ),)
        ],
      )
    );
  }
}


class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blueAccent[100],
        body:
        Center(
          child: Text("Real Connections.\nStudent-First.\nMulti-Intent.", style: TextStyle(fontSize: 45),),
        ),
      ),
    );
  }
}

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body:
            SafeArea(
              child:
                  Center(
                    child: Column(
                      children: [
                        //title
                        Text("What are you here for?"),

                        //select options
                        Container(
                          color: Colors.pink[200],
                          child:Text("💖 Romantic Connections"),
                        ),

                        Container(
                          color: Colors.green[200],
                          child: Text("🤝 New Friends")
                        ),

                        Container(
                          color: Colors.green[200],
                          child: Text("🧠 Study/Project Partners")
                        ),
                        //tip

                      ],
                    ),
                ),
            )
      )
    );
  }
}

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body:
            SafeArea(
              child:
              Center(
                child: Column(
                  children: [
                    //title
                    Text("What are you here for?"),

                    //select options
                    Container(
                      child:Text("🎨 Artsy"),
                    ),

                    Container(
                        child: Text("🤓 Study-Focused")
                    ),

                    Container(
                        child: Text("🧘 Calm")
                    ),

                    Container(
                        child: Text("🕺 Outgoing")
                    ),

                    Container(
                        child: Text("🎤 Deep Talks")
                    ),

                    Container(
                        child: Text("🔥 Flirty")
                    ),

                    Container(
                        child: Text("💼 Goal-Driven")
                    ),
                    //tip

                  ],
                ),
              ),
            )
        )
    );
  }
}



class OnboardingPage4 extends StatefulWidget {
  const OnboardingPage4({Key? key}) : super(key: key);

  @override
  _OnboardingPage4State createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  final _studyMajorController = TextEditingController();
  final _oneLinerController = TextEditingController();
  String personalityType = 'Introvert';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text("Let's talk about YOU"),

              // Major
              TextFormField(
                controller: _studyMajorController,
                decoration: InputDecoration(labelText: "Your Major"),
              ),

              // One-liner
              TextFormField(
                controller: _oneLinerController,
                decoration: InputDecoration(
                  labelText: "One line about you",
                  hintText: "Don't be shy. Go on, be creative",
                ),
              ),


              // Dropdown for personality type
              Text("What's your social energy?"),
              DropdownButton<String>(
                value: personalityType,
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 18, color: Colors.black),
                items: <String>['Introvert', 'Extrovert', 'Ambivert']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    personalityType = newValue!;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}


class OnboardingPage5 extends StatelessWidget {
  const OnboardingPage5({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body:
            SafeArea(
              child:
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //title
                    Text("You are all set", style: TextStyle(fontSize: 48),),
                    Text("Ready to find your vibe?", style: TextStyle(fontSize: 40),)
                  ],
                ),
              ),
            )
        )
    );
  }
}