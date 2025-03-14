import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/common/CustomError.dart';
import 'package:gs_erp/models/Currency.dart';
import 'package:gs_erp/dashboard.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:gs_erp/success.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http.service.dart';

import 'models/Timezone.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GS ERP',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  void _handleLogin(BuildContext context) async {
    if(loginFormKey.currentState!.validate()) {
      String username = usernameController.text;
      String password = passwordController.text;

      username = "smrgillani";
      password = "Google@123";

      final payload = {
        "username": username,
        "password": password
      };


      dynamic response = await RestSerice().postData("/login", payload);

      if(response.containsKey('access_token')){
        if(response['access_token'].toString().isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool setAuthToken = await prefs.setString("access_token", response['access_token'].toString());
          if(setAuthToken){
            Navigator.push(
                context!, MaterialPageRoute(builder: (context) => const Dashboard()));
          }
        }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Button Pressed!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: loginFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/logo-cv.png', width: 350.0, height: 350.0),
              const SizedBox(height: 16.0),
              AllComponents().buildTextFormField(labelText: 'Username', controller: usernameController, validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please specify your Username.';
                }
                return null;
              }),
              const SizedBox(height: 16.0),
              AllComponents().buildTextFormField(labelText: 'Password', controller: passwordController, validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please specify your Password.';
                }
                return null;
              }),
              const SizedBox(height: 16.0),
              OutlinedButton(
                  onPressed: () {
                    _handleLogin(context);
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      fixedSize: const Size(200, 54),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      foregroundColor: Colors.black87,
                      shadowColor: Colors.yellow,
                      shape: const StadiumBorder()
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(' Login '),
                        Icon(Icons.login)
                      ]
                  )
              ),
              const SizedBox(height: 16.0),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(' or ',
                  style: TextStyle(
                    // Additional style properties
                    fontSize: 30.0,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      fixedSize: const Size(200, 54),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      foregroundColor: Colors.black87,
                      shadowColor: Colors.yellow,
                      shape: const StadiumBorder()
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(' Register '),
                        Icon(Icons.login)
                      ]
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  int currentScreen = 1;
  Map<String, dynamic> formData = {};
  Map<String, dynamic> requestData = {};
  Map<String, dynamic> _requestData = {};

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
  late List<Widget> widgets = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool isDisabled = false;
  bool anyError = false;
  bool anyMessage = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    loadToken();
  }

  Future<void> loadToken() async {

  }

  void moveToNextScreen() {
    if (_formKey.currentState!.validate()) {
      if (currentScreen < 3) {
        setState(() {
          currentScreen++;
        });
      }
    }
  }

  void moveToPreviousScreen() {
    if (currentScreen > 1) {
      setState(() {
        currentScreen--;
      });
    }
  }

  void updateFormData(String field, dynamic value) {
    setState(() {
      formData[field] = value;
    });
  }

  DateTime parseDate(String dateString) {
    // Define the month names to convert abbreviated month names to numeric values.
    final monthNames = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };

    final parts = dateString.split(' ');
    final day = int.parse(parts[1]);
    final month = monthNames[parts[2]];
    final year = int.parse(parts[3]);
    final timeParts = parts[4].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = int.parse(timeParts[2]);

    final timeZoneOffset = parts[5];

    return DateTime(year, month!, day, hour, minute, second).toLocal();
  }

  String? getFormData(String field) {
     return formData[field];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Register'),
      ),
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

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                    children: [ Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Register and Get Started in minutes',
                            style: TextStyle(fontSize: 22),),
                          const SizedBox(height: 16),
                          AllComponents().getTopBoxes(
                              currentScreen, tabletScreen),
                          const SizedBox(height: 32),
                          if (currentScreen == 1)
                            RegistrationScreenOne(
                                updateFormData: updateFormData,
                                getFormData: getFormData),
                          if (currentScreen == 2)
                            RegistrationScreenTwo(
                                updateFormData: updateFormData,
                                getFormData: getFormData),
                          if (currentScreen == 3)
                            RegistrationScreenThree(
                                updateFormData: updateFormData,
                                getFormData: getFormData),
                          const SizedBox(height: 16),
                          if((anyError || anyMessage) && !isLoading)
                            Container(
                                decoration: BoxDecoration(
                                  color: (anyError ? const Color.fromRGBO(246, 75, 60, 1) : const Color.fromRGBO(11, 113, 65, 1)),
                                  border: Border.all(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                // Set the background color of the entire column
                                child:
                                Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: widgets,
                                    )
                                )
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (currentScreen > 1)
                                OutlinedButton(
                                    onPressed: moveToPreviousScreen,
                                    style: ElevatedButton.styleFrom(
                                        padding: buttonPadding,
                                        fixedSize: buttonSize,
                                        textStyle: buttonTextStyle,
                                        foregroundColor: Colors.black87,
                                        shadowColor: Colors.yellow,
                                        shape: const StadiumBorder()
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          buttonPrevIcon,
                                          const Text('Previous '),
                                        ]
                                    )
                                ),
                              if (currentScreen < 3)
                                OutlinedButton(
                                    onPressed: isLoading || isDisabled
                                        ? null
                                        : moveToNextScreen,
                                    style: ElevatedButton.styleFrom(
                                        padding: buttonPadding,
                                        fixedSize: buttonSize,
                                        textStyle: buttonTextStyle,
                                        foregroundColor: Colors.black87,
                                        shadowColor: Colors.yellow,
                                        shape: const StadiumBorder()
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          const Text('Next '),
                                          isLoading
                                              ? circularProgressIndicator
                                              : buttonNextIcon
                                        ]
                                    )
                                ),
                              if (currentScreen == 3)
                                OutlinedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {

                                        widgets = [];

                                        String serverError = "We encountered an error and we've notified our engineering team about it. Sorry for the inconvenience caused.";

                                        setState(() {
                                          isLoading = true;
                                        });

                                        try {

                                          _requestData = await getToken();

                                          Map<String, dynamic> jsonData = json.decode(_requestData['body']);
                                          // print(jsonData);
                                          if (jsonData['success'] == true && jsonData.containsKey('token') && jsonData['token'].toString().isNotEmpty) {
                                            requestData['token'] = jsonData['token'];
                                          }else{

                                            setState(() {
                                              anyError = true;
                                            });

                                            widgets.add(AllComponents().getBulletPoint(serverError, tabletScreen));

                                            setState(() {
                                              isLoading = false;
                                            });

                                            return;
                                          }
                                        } catch (error, stackTrace) {
                                          // print('error :  $error');
                                          // FlutterErrorDetails errorDetails = FlutterErrorDetails(
                                          //   exception: error,
                                          //   stack: stackTrace,
                                          // );
                                          // BuildContext? context = _scaffoldKey.currentContext;
                                          // // Navigator.push(context!,MaterialPageRoute(builder: (context) => CustomError(errorDetails: errorDetails)));
                                          //
                                          // Navigator.of(context!).push(MaterialPageRoute(builder: (context) {
                                          //   return CustomError(errorDetails: errorDetails);
                                          // })).then((result) {
                                          //   if (result == "comingBack") {
                                          //     setState(() {
                                          //       isDisabled = true;
                                          //     });
                                          //     print("Coming back to this screen");
                                          //   }
                                          // });

                                          setState(() {
                                            anyError = true;
                                          });

                                          widgets.add(AllComponents().getBulletPoint(serverError, tabletScreen));

                                          setState(() {
                                            isLoading = false;
                                          });

                                          return;
                                        }


                                        String jsonFormData = jsonEncode(formData);
                                        requestData['data'] = jsonFormData;

                                        widgets = [];

                                        Map<String, dynamic> response = await sendFormData(requestData,_requestData['cookies']);

                                        if (response.containsKey('success')) {

                                            if (response['success']) {

                                              // widgets.add(AllComponents().getBulletPoint(response['msg'], tabletScreen));

                                              setState(() {
                                                isLoading = false;
                                                anyError = false;
                                                anyMessage = false;
                                              });

                                              Navigator.push(context,MaterialPageRoute(builder: (context) => MyScreen()));

                                            } else {
                                              if (response.containsKey(
                                                  'errors')) {
                                                Map<String,
                                                    dynamic> errors = response['errors'];

                                                if (errors != null) {
                                                  // Loop through error messages
                                                  errors.forEach((field,
                                                      messages) {
                                                    // print('Field: $field');
                                                    messages.forEach((message) {
                                                      widgets.add(
                                                          AllComponents()
                                                              .getBulletPoint(
                                                              message, tabletScreen));
                                                      // print('Error: $message');
                                                    });
                                                  });
                                                }

                                                setState(() {
                                                  anyError = true;
                                                });
                                              }
                                            }
                                        }else {
                                          setState(() {
                                            anyError = true;
                                          });

                                          widgets.add(AllComponents().getBulletPoint(serverError, tabletScreen));
                                        }

                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: buttonPadding,
                                        fixedSize: buttonSize,
                                        textStyle: buttonTextStyle,
                                        foregroundColor: Colors.black87,
                                        shadowColor: Colors.yellow,
                                        shape: const StadiumBorder()
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          const Text(' Submit '),
                                          (isLoading
                                              ? circularProgressIndicator
                                              : buttonSubmitIcon)
                                        ]
                                    )
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    ]),
              ),
            );
          }),
    );
  }
}

class AllComponents {
  TextFormField buildTextFormField({
    Key? key,
    TextEditingController? controller,
    String labelText = '',
    bool isPassword = false,
    bool isReadOnly = false,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    void Function()? onTap,
    Icon? suffixIcon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool filled = false,
    Color? fillColor,
    int? maxLines
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        filled: filled,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
      ),
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      readOnly: isReadOnly,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  Widget buildCLFormField({
    TextEditingController? controller,
    void Function(String)? onTBChanged,
    void Function(String)? onDPChanged,
    void Function(int?)? onDDChanged,
    String? Function(String?)? validator,
    void Function()? onDPTap,
    void Function()? onTBTap,
    dynamic dataObj
  }) {

    if (dataObj["label_data"]["type"] == "dropdown") {

      String input = dataObj["label_data"]["dropdown_options"];

      List<String> result = input.split("\r\n");
      int selectedVal = 0;
      try {
        selectedVal = int.parse(dataObj["label_data"]['value'] ?? "0");
      }catch(e){}

      return DropdownButtonFormField<int>(
          value: selectedVal,
          decoration: InputDecoration(
            labelText: dataObj["label_text"],
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius
                        .circular(4.0)
                )
            ),
          ),
          items: List.generate(result.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(result[index]),
            );
          }).toList(),
          onChanged: onDDChanged
      );

    }

    if (dataObj["label_data"]["type"] == "date") {

      return AllComponents().buildTextFormField(
          labelText: 'Start Date',
          isReadOnly: true,
          controller: controller,
          suffixIcon: const Icon(
              Icons.calendar_month, size: 40),
          onChanged: onDPChanged,
          onTap: onDPTap
      );

    }

    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder()
      ),
      onChanged: onTBChanged,
      validator: validator,
      onTap: onTBTap,
    );

  }

  TextFormField buildTextFormFieldForPassword({
    Key? key,
    TextEditingController? controller,
    String labelText = '',
    bool isPassword = false,
    bool isReadOnly = false,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    void Function()? onTap,
    Icon? suffixIcon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool filled = false,
    Color? fillColor,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        filled: filled,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      readOnly: isReadOnly,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  Widget getTopBox(int currentScreen, int boxIndex, String text){
    return Container(
      width: 266,
      height: 60,
      decoration: BoxDecoration(
        color: (currentScreen == boxIndex ? const Color.fromRGBO(33, 132, 190, 1) : const Color.fromRGBO(200, 200, 200, 1)),
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 15, right: 0, bottom: 15),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18,color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget getTopBoxes(int currentScreen, bool isTablet) {
    if (isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getTopBox(currentScreen, 1, "1. Business"),
          const SizedBox(width: 16),
          getTopBox(currentScreen, 2, "2. Business Settings"),
          const SizedBox(width: 16),
          getTopBox(currentScreen, 3, "3. Owner")
        ],
      );
    }else {
      return Column(
        children: [
          if(currentScreen == 1)
            getTopBox(currentScreen, 1, "1. Business"),
          if(currentScreen == 2)
            getTopBox(currentScreen, 2, "2. Business Settings"),
          if (currentScreen == 3)
            getTopBox(currentScreen, 3, "3. Owner")
        ],
      );
    }
  }

  List<Widget> getWidgets(bool tabletScreen, List<Widget> widgets, BuildContext context){
    List<Widget> widgetsList = [];

    for (int i = 0; i < widgets.length; i++) {
      widgetsList.add(
          tabletScreen ?
          Flexible(
            flex: 1,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: widgets[i],
            ),
          ): widgets[i]
      );

      if (i < widgets.length - 1) {
        widgetsList.add( tabletScreen ? const SizedBox(width: 16) : const SizedBox(height: 16));
      }
    }

    return widgetsList;
  }

  Widget buildResponsiveWidget(Widget widget, BuildContext context) {
    bool tabletScreen = MediaQuery.of(context).size.shortestSide > 600;
    List<Widget> widgets = getWidgets(tabletScreen, (widget as Column).children, context);

    if (tabletScreen) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widgets,
      );
    } else {
      return Column(
        children: widgets,
      );
    }
  }

  @override
  Widget getBulletPoint(String text, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 10.0,
          height: 10.0,
          margin: (isTablet ? const EdgeInsets.only(top: 9.0) : const EdgeInsets.only(top: 6.0)),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10.0),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: (isTablet ? const TextStyle(fontSize: 20.0, color: Colors.white) : const TextStyle(color: Colors.white)),
                // overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

}

List<Currency> currencyLabels = [
  Currency('Afghanistan - Afghanis(AF) ', '3'),
  Currency('Albania - Leke(ALL) ', '1'),
  Currency('Algerie - Algerian dinar(DZD) ', '135'),
  Currency('America - Dollars(USD) ', '2')
];

List<Currency> newCurrencyLabels = [
  Currency('Afghanistan - Afghanis(AF) ', '3'),
];

List<Timezone> timezoneLabel = [
  Timezone('Africa/Abidjan', 'Africa/Abidjan'),
  Timezone('Africa/Accra', 'Africa/Accra'),
  Timezone('Africa/Addis_Ababa', 'Africa/Addis_Ababa'),
  Timezone('Africa/Algiers', 'Africa/Algiers')
];

enum AccountingMethod {
  fifo('FIFO (First In First Out)', 'fifo'),
  lifo('LIFO (Last In First Out)', 'lifo');

  const AccountingMethod(this.label, this.value);
  final String label;
  final String value;
}

enum FinancialYearMonth {
  jan('January', '1'),
  feb('February', '2'),
  mar('March', '3'),
  apr('April', '4'),
  may('May', '5'),
  jun('June', '6'),
  jul('July', '7'),
  aug('August', '8'),
  sep('September', '9'),
  oct('October', '10'),
  nov('November', '11'),
  dec('December', '12');

  const FinancialYearMonth(this.label, this.value);
  final String label;
  final String value;
}

class RegistrationScreenOne extends StatefulWidget {
  final Function updateFormData;
  final Function getFormData;

  const RegistrationScreenOne({super.key, required this.updateFormData, required this.getFormData});

  @override
  RegistrationScreenOneState createState() => RegistrationScreenOneState();
}

class RegistrationScreenOneState extends State<RegistrationScreenOne> {

  final TextEditingController currencyController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessWebsiteController = TextEditingController();
  TextEditingController businessStartdateController = TextEditingController();
  Currency? selectedCurrency;
  TextEditingController businessContactController = TextEditingController();
  TextEditingController businessAltContactController = TextEditingController();
  TextEditingController businessCountryController = TextEditingController();
  TextEditingController businessStateController = TextEditingController();
  TextEditingController businessCityController = TextEditingController();
  TextEditingController businessZipcodeController = TextEditingController();
  TextEditingController businessLandmarkController = TextEditingController();
  Timezone? selectedTimezone;
  late AllComponents allComponents;
  List<Currency> currencies = [];
  List<Timezone> timezones = [];

  @override
  void initState() {
    super.initState();
    businessNameController.text = widget.getFormData('name') ?? '';
    businessWebsiteController.text = widget.getFormData('website') ?? '';
    businessStartdateController.text = widget.getFormData('start_date') ?? '';
    selectedCurrency = findItemByValue(
        currencyLabels, widget.getFormData('currency_id') ?? '', (
        Currency currency) => currency.value);
    businessContactController.text = widget.getFormData('mobile') ?? '';
    businessAltContactController.text =
        widget.getFormData('alternate_number') ?? '';
    businessCountryController.text = widget.getFormData('country') ?? '';
    businessStateController.text = widget.getFormData('state') ?? '';
    businessCityController.text = widget.getFormData('city') ?? '';
    businessZipcodeController.text = widget.getFormData('zip_code') ?? '';
    businessLandmarkController.text = widget.getFormData('landmark') ?? '';
    selectedTimezone = findItemByValue(
        timezoneLabel, widget.getFormData('time_zone') ?? '', (
        Timezone timezone) => timezone.value);
    allComponents = AllComponents();
    getAllCurrencies();
    getAllTimezones();
  }

  getAllCurrencies() async{
    dynamic response = await RestSerice().getData("/currencies");
    List<dynamic> currencieslist = (response['data'] as List).cast<dynamic>();
    for (dynamic currency in currencieslist) {
      currencies.add(Currency(currency['country'] + ' - ' + currency['currency'] + '(' + currency['code'] + ')', currency['id'].toString()));
    }
  }

  getAllTimezones() async{
    dynamic response = await RestSerice().getData("/timezones");
    Map<String, dynamic> timezonesList = response['data'];

    for(var entry in timezonesList.entries){
      timezones.add(Timezone(entry.key, entry.value.toString()));
      print("key : ${entry.key} , value : ${entry.value}");
    }
    // timezonesList.entries.map((entry) {
    //   print("key : ${entry.key} , value : ${entry.value}");
    //   // timezones.add(Timezone(entry.key, entry.value));
    // });
    // for (dynamic timezone in timezones) {
    //   print(timezone);
    //   // Timezones.add(Timezone(timezone['country'] + ' - ' + timezone['currency'] + '(' + timezone['code'] + ')', timezone['id'].toString()));
    // }
  }

  T? findItemByValue<T>(List<T> items, String value, Function(T) extractValue) {
    if (value.isNotEmpty) {
      for (var item in items) {
        if (extractValue(item) == value) {
          return item;
        }
      }
    }
    return null;
  }

  Future<void> selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      String formattedDate = '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.year.toString()}';
      businessStartdateController.text = formattedDate;
      widget.updateFormData('start_date', formattedDate);
    }
  }

  File? _image;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double imagePickerSize = isTablet ? 200 : 120;
          return Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: GestureDetector(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            width: imagePickerSize,
                            height: imagePickerSize,
                            // color: Colors.grey[300],
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 2.0, // 20-pixel border
                              ),
                            ),
                            child: _image != null
                                ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.file(
                                    _image!, width: imagePickerSize,
                                    height: imagePickerSize,
                                    fit: BoxFit.cover)
                            )
                                : const Text(''),
                          ),
                          if (_image == null)
                            Positioned(
                              top: isTablet ? 70 : 27,
                              right: isTablet ? 65 : 23,
                              child: InkWell(
                                onTap: _pickImage,
                                child: const Column(
                                    children: <Widget>[
                                      Icon(Icons.add_a_photo,
                                          color: Colors.green,
                                          size: 45),
                                      Text('Pick a Logo')
                                    ]
                                ),
                              ),
                            ),
                          // if (_image != null)
                          //   Positioned(
                          //     top: 70,
                          //     left: -20,
                          //     child: InkWell(
                          //       onTap: _removeImage,
                          //       child: const Icon(
                          //         Icons.delete,
                          //         color: Colors.red,
                          //         size: 45,
                          //       ),
                          //     ),
                          //   ),
                          if (_image != null)
                            Positioned(
                              left: isTablet ? 69 : 40,
                              bottom: 5,
                              child: InkWell(
                                onTap: _pickImage,
                                child: Container(
                                    alignment: Alignment.center,
                                    width: isTablet ? 60 : 40,
                                    height: isTablet ? 60 : 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromRGBO(
                                          19, 144, 245, 1),
                                      border: Border.all(
                                          color: const Color.fromRGBO(
                                              19, 144, 245, 1)
                                      ),
                                    ),
                                    child: isTablet ? const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 38,
                                    ) : const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 23,
                                    )
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  allComponents.buildResponsiveWidget(
                      Column(
                          children: [
                            allComponents.buildTextFormField(
                                labelText: 'Business Name',
                                controller: businessNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please specify your business name.';
                                  }
                                  return null;
                                },
                                onChanged: (value) =>
                                    widget.updateFormData('name', value)
                            ),
                            allComponents.buildTextFormField(
                                labelText: 'Website',
                                onChanged: (value) =>
                                    widget.updateFormData('website', value),
                                controller: businessWebsiteController
                            )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16),
                  allComponents.buildResponsiveWidget(
                      Column(
                          children: [
                            allComponents.buildTextFormField(
                                labelText: 'Start Date',
                                isReadOnly: true,
                                controller: businessStartdateController,
                                suffixIcon: const Icon(
                                    Icons.calendar_month, size: 40),
                                onChanged: (value) =>
                                    widget.updateFormData('start_date', value),
                                onTap: selectStartDate),
                            DropdownSearch<Currency>(
                              popupProps: const PopupProps.menu(
                                  showSearchBox: true
                              ),
                              selectedItem: selectedCurrency,
                              items: currencies,
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  hintText: 'Select a currency',
                                  labelText: 'Currencies',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              4.0))
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'Select a currency';
                                }
                                return null; // No error
                              },
                              onChanged: (e) {
                                setState(() {
                                  widget.updateFormData(
                                      'currency_id', e?.value);
                                });
                              },
                            )
                            // DropdownButtonFormField<Currency>(
                            //   value: selectedCurrency,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Select a currency',
                            //     border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.all(
                            //             Radius.circular(
                            //                 4.0))
                            //     ),
                            //   ),
                            //   validator: (value) {
                            //     if (value == null) {
                            //       return 'Select a currency';
                            //     }
                            //     return null; // No error
                            //   },
                            //   items: currencyLabels.map((item) {
                            //     return DropdownMenuItem<Currency>(
                            //       value: item,
                            //       child: Text(item.label),
                            //     );
                            //   }).toList(),
                            //   onChanged: (Currency? value) {
                            //     setState(() {
                            //       widget.updateFormData(
                            //           'currency_id', value?.value);
                            //     });
                            //   },
                            // )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  allComponents.buildResponsiveWidget(
                      Column(
                          children: [
                            allComponents.buildTextFormField(
                                labelText: 'Business Contact Number',
                                onChanged: (value) =>
                                    widget.updateFormData('mobile', value),
                                controller: businessContactController),
                            allComponents.buildTextFormField(
                                labelText: 'Alternate Contact Number',
                                onChanged: (value) =>
                                    widget.updateFormData(
                                        'alternate_number', value),
                                controller: businessAltContactController)
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  allComponents.buildResponsiveWidget(
                      Column(
                          children: [
                            allComponents.buildTextFormField(
                                labelText: 'Country',
                                onChanged: (value) =>
                                    widget.updateFormData('country', value),
                                controller: businessCountryController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required.';
                                  }
                                  return null;
                                }),
                            allComponents.buildTextFormField(
                                labelText: 'State',
                                onChanged: (value) =>
                                    widget.updateFormData('state', value),
                                controller: businessStateController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required.';
                                  }
                                  return null;
                                })
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  allComponents.buildResponsiveWidget(
                      Column(
                          children: [
                            allComponents.buildTextFormField(
                                labelText: 'City',
                                onChanged: (value) =>
                                    widget.updateFormData('city', value),
                                controller: businessCityController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required.';
                                  }
                                  return null;
                                }),
                            allComponents.buildTextFormField(
                                labelText: 'Zip Code',
                                onChanged: (value) =>
                                    widget.updateFormData('zip_code', value),
                                controller: businessZipcodeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required.';
                                  }
                                  return null;
                                })
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  allComponents.buildResponsiveWidget(
                      Column(
                          children: [
                            allComponents.buildTextFormField(
                                labelText: 'Landmark',
                                onChanged: (value) =>
                                    widget.updateFormData('landmark', value),
                                controller: businessLandmarkController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required.';
                                  }
                                  return null;
                                }),
                            DropdownSearch<Timezone>(
                              popupProps: const PopupProps.menu(
                                  showSearchBox: true
                              ),
                              selectedItem: selectedTimezone,
                              items: timezones,
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  hintText: 'Select a Time Zone',
                                  labelText: 'Time Zones',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              4.0))
                                  ),
                                ),
                              ),
                              onChanged: (e) {
                                setState(() {
                                  widget.updateFormData(
                                      'time_zone', e?.value);
                                });
                              },
                            )
                            // DropdownButtonFormField<Timezone>(
                            //     value: selectedTimezone,
                            //     decoration: const InputDecoration(
                            //       labelText: 'Select a Time zone',
                            //       border: OutlineInputBorder(
                            //           borderRadius: BorderRadius.all(
                            //               Radius.circular(
                            //                   4.0))
                            //       ),
                            //     ),
                            //     items: timezoneLabel.map((item) {
                            //       return DropdownMenuItem<Timezone>(
                            //         value: item,
                            //         child: Text(item.name),
                            //       );
                            //     }).toList(),
                            //     onChanged: (Timezone? value) {
                            //       setState(() {
                            //         widget.updateFormData(
                            //             'time_zone', value?.value);
                            //       }
                            //       );
                            //     }
                            // )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
    );
  }
}


class RegistrationScreenTwo extends StatefulWidget {
  final Function updateFormData;
  final Function getFormData;

  const RegistrationScreenTwo({super.key, required this.updateFormData, required this.getFormData});

  @override
  RegistrationScreenTwoState createState() => RegistrationScreenTwoState();
}

class RegistrationScreenTwoState extends State<RegistrationScreenTwo> {

  final TextEditingController businessTaxOneName = TextEditingController();
  final TextEditingController businessTaxOneVal = TextEditingController();
  final TextEditingController businessTaxTwoName = TextEditingController();
  final TextEditingController businessTaxTwoVal = TextEditingController();
  FinancialYearMonth? selectedMonth;
  AccountingMethod? selectedMethod;
  late AllComponents allComponents;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    businessTaxOneName.text = widget.getFormData('tax_label_1') ?? '';
    businessTaxOneVal.text = widget.getFormData('tax_number_1') ?? '';
    businessTaxTwoName.text = widget.getFormData('tax_label_2') ?? '';
    businessTaxTwoVal.text = widget.getFormData('tax_number_2') ?? '';
    selectedMonth = getFinancialMonth(widget.getFormData('fy_start_month') ?? '');
    selectedMethod = getAccountingMethod(widget.getFormData('accounting_method') ?? '');
    allComponents = AllComponents();
  }

  FinancialYearMonth? getFinancialMonth(String stringValue) {
    if(stringValue.isNotEmpty) {
      for (var month in FinancialYearMonth.values) {
        if (month.value.contains(stringValue)) {
          return month;
        }
      }
    }
    return null;
  }

  AccountingMethod? getAccountingMethod(String stringValue) {
    if(stringValue.isNotEmpty) {
      for (var method in AccountingMethod.values) {
        if (method.value.contains(stringValue)) {
          return method;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<AccountingMethod>> accountingMethodEntries = <
        DropdownMenuEntry<AccountingMethod>>[];
    for (final AccountingMethod label in AccountingMethod.values) {
      accountingMethodEntries.add(DropdownMenuEntry<AccountingMethod>(
          value: label, label: label.label));
    }

    final List<
        DropdownMenuEntry<FinancialYearMonth>> financialYearMonthEntries = <
        DropdownMenuEntry<FinancialYearMonth>>[];
    for (final FinancialYearMonth label in FinancialYearMonth.values) {
      financialYearMonthEntries.add(DropdownMenuEntry<FinancialYearMonth>(
          value: label, label: label.label));
    }

    return Padding(
      padding: const EdgeInsets.all(0),
      child: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              allComponents.buildResponsiveWidget(
                  Column(
                      children: [
                        allComponents.buildTextFormField(
                            labelText: 'Tax 1 Name',
                            onChanged: (value) =>
                                widget.updateFormData('tax_label_1', value),
                            controller: businessTaxOneName),
                        allComponents.buildTextFormField(
                            labelText: 'Tax 1 Percentage(%)',
                            onChanged: (value) =>
                                widget.updateFormData('tax_number_1', value),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            controller: businessTaxOneVal)
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              allComponents.buildResponsiveWidget(
                  Column(
                      children: [
                        allComponents.buildTextFormField(
                            labelText: 'Tax 2 Name',
                            onChanged: (value) =>
                                widget.updateFormData('tax_label_2', value),
                            controller: businessTaxTwoName),
                        allComponents.buildTextFormField(
                            labelText: 'Tax 2 Percentage(%)',
                            onChanged: (value) =>
                                widget.updateFormData('tax_number_2', value),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            controller: businessTaxTwoVal)
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              allComponents.buildResponsiveWidget(
                  Column(
                      children: [
                        DropdownButtonFormField<FinancialYearMonth>(
                            value: selectedMonth,
                            decoration: const InputDecoration(
                              labelText: 'Financial year start month',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius
                                      .circular(
                                      4.0))
                              ),
                            ),
                            items: FinancialYearMonth.values.map((
                                financialyearmonth) {
                              return DropdownMenuItem<FinancialYearMonth>(
                                value: financialyearmonth,
                                child: Text(financialyearmonth.label),
                              );
                            }).toList(),
                            onChanged: (FinancialYearMonth? value) {
                              setState(() {
                                widget.updateFormData(
                                    'fy_start_month', value?.value);
                              });
                            }
                        ),
                        DropdownButtonFormField<AccountingMethod>(
                            value: selectedMethod,
                            decoration: const InputDecoration(
                              labelText: 'Stock Accounting Method',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius
                                      .circular(
                                      4.0))
                              ),
                            ),
                            items: AccountingMethod.values.map((
                                accountingmonth) {
                              return DropdownMenuItem<AccountingMethod>(
                                value: accountingmonth,
                                child: Text(accountingmonth.label),
                              );
                            }).toList(),
                            onChanged: (AccountingMethod? value) {
                              setState(() {
                                widget.updateFormData(
                                    'accounting_method', value?.value);
                              });
                            }
                        )
                      ]
                  ),
                  context
              )
            ]),
      ),
    );
  }
}

class RegistrationScreenThree extends StatefulWidget {
  final Function updateFormData;
  final Function getFormData;

  const RegistrationScreenThree({super.key, required this.updateFormData, required this.getFormData});

  @override
  RegistrationScreenThreeState createState() => RegistrationScreenThreeState();
}

class RegistrationScreenThreeState extends State<RegistrationScreenThree> {

  final TextEditingController surname = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController userName = TextEditingController();
  final TextEditingController userEmail = TextEditingController();
  final TextEditingController userPassword = TextEditingController();
  final TextEditingController userConfirmPassword = TextEditingController();
  late AllComponents allComponents;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    surname.text = widget.getFormData('surname') ?? '';
    firstName.text = widget.getFormData('first_name') ?? '';
    lastName.text = widget.getFormData('last_name') ?? '';
    userName.text = widget.getFormData('username') ?? '';
    userEmail.text = widget.getFormData('email') ?? '';
    userPassword.text = widget.getFormData('password') ?? '';
    userConfirmPassword.text = widget.getFormData('password_again') ?? '';
    allComponents = AllComponents();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              allComponents.buildResponsiveWidget(
                  Column(
                      children: [
                        allComponents.buildTextFormField(
                            labelText: 'Prefix (Mr / Mrs / Miss)',
                            onChanged: (value) =>
                                widget.updateFormData('surname', value),
                            controller: surname),
                        allComponents.buildTextFormField(
                            labelText: 'First Name',
                            onChanged: (value) =>
                                widget.updateFormData('first_name', value),
                            controller: firstName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            }),
                        allComponents.buildTextFormField(
                            labelText: 'Last Name',
                            onChanged: (value) =>
                                widget.updateFormData('last_name', value),
                            controller: lastName)
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              allComponents.buildResponsiveWidget(
                  Column(
                      children: [
                        allComponents.buildTextFormField(
                            labelText: 'Username',
                            onChanged: (value) =>
                                widget.updateFormData('username', value),
                            controller: userName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            }),
                        allComponents.buildTextFormField(
                            labelText: 'Email',
                            onChanged: (value) =>
                                widget.updateFormData('email', value),
                            controller: userEmail,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            })
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              allComponents.buildResponsiveWidget(
                  Column(
                      children: [
                        allComponents.buildTextFormFieldForPassword(
                            labelText: 'Password',
                            onChanged: (value) =>
                                widget.updateFormData('password', value),
                            controller: userPassword,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            }),
                        allComponents.buildTextFormFieldForPassword(
                            labelText: 'Confirm Password',
                            onChanged: (value) =>
                                widget.updateFormData('password_again', value),
                            controller: userConfirmPassword,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }else if (userPassword.text != userConfirmPassword.text) {
                                return 'Password Mismatched.';
                              }
                              return null;
                            })
                      ]
                  ),
                  context
              )
            ]),
      ),
    );
  }
}