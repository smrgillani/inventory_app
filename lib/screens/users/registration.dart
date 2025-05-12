
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gs_erp/components/ComponentUtil.dart';
import 'package:gs_erp/screens/users/registration_business.dart';
import 'package:gs_erp/screens/users/registration_business_settings.dart';
import 'package:gs_erp/screens/users/registration_owner.dart';

import '../../http.service.dart';
import '../../success.dart';


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

  final String publicUrl = "192.168.40.12";

  late TextStyle buttonTextStyle = const TextStyle(fontSize: 15,fontWeight: FontWeight.bold);
  late Size buttonSize = const Size(150, 40.5);
  late EdgeInsets buttonPadding = const EdgeInsets.all(7);
  late double? buttonIconSize =  22.5;
  late Icon buttonPrevIcon = const Icon(Icons.arrow_back, size: 22.5);
  late Icon buttonNextIcon = const Icon(Icons.arrow_forward, size: 22.5);
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
  final FocusNode nbFocus = FocusNode();

  bool isLoading = false;
  bool isDisabled = false;
  bool anyError = false;
  bool anyMessage = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late ComponentUtil componentUtil;

  @override
  void initState() {
    super.initState();
    componentUtil = ComponentUtil();
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

  dynamic getFormData(String field) {
    return formData[field];
  }

  void updateLoading(bool state){
    setState(() {
      isLoading = state;
    });
  }

  void focusNexButton(){
    FocusScope.of(context).requestFocus(nbFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Register'),
      ),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
          builder: (context, constraints) {
            bool tabletScreen = constraints.maxWidth > 650;

            if (tabletScreen) {
              buttonTextStyle =
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
              buttonSize = const Size(200, 54);
              buttonPadding = const EdgeInsets.all(10);
              buttonPrevIcon = const Icon(Icons.navigate_before, size: 30);
              buttonNextIcon = const Icon(Icons.navigate_next, size: 30);
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Register and Get Started in minutes',
                              style: TextStyle(fontSize: 22),),
                            const SizedBox(height: 16),
                            ComponentUtil().getTopBoxes(
                                currentScreen, tabletScreen),
                            const SizedBox(height: 32),
                            if (currentScreen == 1)
                              RegistrationScreenOne(
                                  updateFormData: updateFormData,
                                  getFormData: getFormData,
                                  updateLoading: updateLoading,
                                  focusNexButton: focusNexButton),
                            if (currentScreen == 2)
                              RegistrationScreenTwo(
                                  updateFormData: updateFormData,
                                  getFormData: getFormData,
                                  updateLoading: updateLoading),
                            if (currentScreen == 3)
                              RegistrationScreenThree(
                                  updateFormData: updateFormData,
                                  getFormData: getFormData,
                                  updateLoading: updateLoading),
                            const SizedBox(height: 16),
                            if((anyError || anyMessage) && !isLoading)
                              Container(
                                  decoration: BoxDecoration(
                                    color: (anyError ? const Color.fromRGBO(
                                        246, 75, 60, 1) : const Color.fromRGBO(
                                        11, 113, 65, 1)),
                                    border: Border.all(
                                        color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  // Set the background color of the entire column
                                  child:
                                  Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child:
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: widgets,
                                      )
                                  )
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (currentScreen > 1)
                                  componentUtil.buildOutlinedButton(
                                      onPressed: moveToPreviousScreen,
                                      fixedSize: const Size(111, 36),
                                      foregroundColor: Colors.black87,
                                      backgroundColor: Colors.transparent,
                                      buttonContent: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            buttonPrevIcon,
                                            const Text('Previous '),
                                          ]
                                      )
                                  ),
                                const SizedBox(width: 16),
                                if (currentScreen < 3)
                                  componentUtil.buildOutlinedButton(
                                      onPressed: isLoading || isDisabled
                                          ? null
                                          : moveToNextScreen,
                                      fixedSize: const Size(84, 36),
                                      buttonContent: Row(
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
                                  componentUtil.buildOutlinedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          widgets = [];

                                          String serverError = "We encountered an error and we've notified our engineering team about it. Sorry for the inconvenience caused.";

                                          setState(() {
                                            isLoading = true;
                                          });

                                          try {
                                            _requestData = await getToken();

                                            Map<String, dynamic> jsonData = json
                                                .decode(_requestData['body']);
                                            // print(jsonData);
                                            if (jsonData['success'] == true &&
                                                jsonData.containsKey('token') &&
                                                jsonData['token']
                                                    .toString()
                                                    .isNotEmpty) {
                                              requestData['token'] =
                                              jsonData['token'];
                                            } else {
                                              setState(() {
                                                anyError = true;
                                              });

                                              widgets.add(ComponentUtil()
                                                  .getBulletPoint(
                                                  serverError, tabletScreen));

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

                                            widgets.add(
                                                ComponentUtil().getBulletPoint(
                                                    serverError, tabletScreen));

                                            setState(() {
                                              isLoading = false;
                                            });

                                            return;
                                          }

                                          List<http.MultipartFile> files = [];

                                          if(getFormData('business_logo') != null && getFormData('business_logo').toString().isNotEmpty) {
                                            files.add(await http.MultipartFile.fromPath('business_logo', getFormData('business_logo')));
                                          }

                                          String jsonFormData = jsonEncode(
                                              formData);
                                          requestData['data'] = jsonFormData;

                                          widgets = [];

                                          Map<String,
                                              dynamic> response = await sendFormData(
                                              requestData,
                                              _requestData['cookies'], files);

                                          if (response.containsKey('success')) {
                                            if (response['success']) {
                                              // widgets.add(AllComponents().getBulletPoint(response['msg'], tabletScreen));

                                              setState(() {
                                                isLoading = false;
                                                anyError = false;
                                                anyMessage = false;
                                              });

                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SuccessScreen()));
                                            } else {
                                              if (response.containsKey('errors')) {
                                                Map<String,
                                                    dynamic> errors = response['errors'];

                                                if (errors != null) {
                                                  // Loop through error messages
                                                  errors.forEach((field,
                                                      messages) {
                                                    // print('Field: $field');
                                                    messages.forEach((message) {
                                                      widgets.add(
                                                          ComponentUtil()
                                                              .getBulletPoint(
                                                              message,
                                                              tabletScreen));
                                                      // print('Error: $message');
                                                    });
                                                  });
                                                }

                                                setState(() {
                                                  anyError = true;
                                                });
                                              }else if(response.containsKey('msg')) {
                                                widgets.add(ComponentUtil().getBulletPoint(response['msg'], tabletScreen));
                                                setState(() {
                                                  anyError = true;
                                                });
                                              }else{
                                                widgets.add(ComponentUtil().getBulletPoint('Something went wrong, please try again later', tabletScreen));
                                                setState(() {
                                                  anyError = true;
                                                });
                                              }
                                            }
                                          } else {
                                            setState(() {
                                              anyError = true;
                                            });

                                            widgets.add(
                                                ComponentUtil().getBulletPoint(
                                                    serverError, tabletScreen));
                                          }

                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                      fixedSize: const Size(109, 36),
                                      focusNode: nbFocus,
                                      buttonContent: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            const Text(' Register '),
                                            (isLoading
                                                ? circularProgressIndicator
                                                : buttonNextIcon)
                                          ]
                                      )
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ]
                ),
              ),
            );
          }
          ),
    );
  }
}
