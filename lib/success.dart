import 'package:flutter/material.dart';
import 'package:gs_erp/main.dart';
import 'package:lottie/lottie.dart';


class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  MyScreenState createState() => MyScreenState();
}

class MyScreenState extends State<MyScreen> {
  late TextStyle buttonTextStyle = const TextStyle(fontSize: 15,fontWeight: FontWeight.bold);
  late Size buttonSize = const Size(150, 40.5);
  late EdgeInsets buttonPadding = const EdgeInsets.all(7);
  late double? buttonIconSize =  22.5;
  late Icon buttonPrevIcon = const Icon(Icons.navigate_before, size: 22.5);
  late Icon buttonNextIcon = const Icon(Icons.navigate_next, size: 22.5);
  late Icon buttonSubmitIcon = const Icon(Icons.send, size: 22.5);
  late SizedBox circularProgressIndicator = const SizedBox(
    width: 20.0,
    height: 20.0,
    child: CircularProgressIndicator(
      strokeWidth: 4.0,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF4ECE72),
        body: LayoutBuilder(
            builder: (context, constraints) {
              bool tabletScreen = constraints.maxWidth > 600;

              if (tabletScreen) {
                buttonTextStyle =
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
                buttonSize = const Size(200, 54);
                buttonPadding = const EdgeInsets.all(10);
                buttonPrevIcon = const Icon(Icons.navigate_before, size: 30);
                buttonNextIcon = const Icon(Icons.navigate_next, size: 30);
                buttonSubmitIcon = const Icon(Icons.send);
                circularProgressIndicator = const SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              }

              return SingleChildScrollView(child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 64.0),
                      Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            Circle(MediaQuery
                                .of(context)
                                .size
                                .width * 0.8, const Color(0xFF4CC06D),
                                children: [
                                  Circle(MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.6, const Color(0xFF4AB368),
                                      children: [
                                        Circle(MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.4,
                                            const Color(0xFF48A764),
                                            border: true,
                                            children: [
                                              Lottie.network(
                                                'https://assets10.lottiefiles.com/packages/lf20_xlkxtmul.json',
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                                frameRate: FrameRate(60),
                                                repeat: false,
                                                animate: true,
                                              ),
                                              // Icon(
                                              //     Icons.check,
                                              //     color: Colors.white,
                                              //     size: MediaQuery
                                              //         .of(context)
                                              //         .size
                                              //         .width * 0.2),
                                            ]),
                                      ]),
                                ])
                          ]),
                      const SizedBox(height: 32.0),
                      const Center(
                        child: Text(
                          'Your business has been registered successfully, \nNow login to perform business related activities.',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (
                              context) => const MyApp()));
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 2,
                            padding: buttonPadding,
                            fixedSize: buttonSize,
                            textStyle: buttonTextStyle,
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.yellow,
                            shape: const StadiumBorder()
                        ),
                        child: const Text('Go Login'),
                      ),
                    ],
                  )),
              );
            })
    );
  }
}

class Circle extends StatelessWidget {
  final double size;
  final Color color;
  final List<Widget> children;
  final bool border;

  Circle(this.size, this.color, {this.children = const [], this.border = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: border ? Border.all(color: const Color(0xFF3D9357), width: 2.0) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
  }
}
