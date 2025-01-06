import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/models/Variation.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/Unit.dart';

class VariationScreen extends StatefulWidget {
  const VariationScreen({super.key});

  @override
  VariationScreenState createState() => VariationScreenState();
}

class VariationScreenState extends State<VariationScreen> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  late Size buttonSize = const Size(150, 45);
  late EdgeInsets buttonPadding = const EdgeInsets.all(7);
  late double? buttonIconSize = 22.5;
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

  final List<String> items = List<String>.generate(100, (i) => '$i');

  late List<Variation> variations = [];

  bool showVariationsList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllVariations();
  }

  getAllVariations() async {
    variations = [];
    dynamic response = await RestSerice().getData('/variations');
    List<dynamic> variationList = (response['data'] as List).cast<dynamic>();

    for(var variation in variationList){

      String varValues = variation['values'].map((varVal) => varVal["name"].toString()).join(',');

      bool isDel = !(variation['total_pv'] > 0);

      variations.add(Variation(id: variation['id'], name: variation['name'], values: varValues, isDelete: isDel));

    }

    setState(() {
      showVariationsList = true;
    });

  }

  addVariation() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Variation'),
        content: VariationForm(),
      );
    });
    await getAllVariations();
  }

  deleteVariation(int id) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this Variation?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await RestSerice().delData('/variations/$id');
                await getAllVariations();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editVariation(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Variation'),
        content: VariationForm(id: id),
      );
    });
    await getAllVariations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (context, constraints) {
            bool tabletScreen = constraints.maxWidth > 600;

            if (tabletScreen) {
              buttonTextStyle =
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
              buttonSize = const Size(200, 64);
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
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 32, left: 16),
                    child: Row(
                      children: [
                        Text('Variations',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text('Manage product variations', style: TextStyle(
                                fontSize: 18))
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: const Color(0xffE0E3E7))
                              ),
                              child: const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.search, color: Colors.grey,
                                            size: 20),
                                        SizedBox(width: 10),
                                        Expanded(
                                            child: TextField(
                                              cursorColor: Colors.red,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black
                                              ),
                                              decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey
                                                  ),
                                                  hintText: 'Search',
                                                  border: InputBorder.none
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(width: 16),
                        OutlinedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              textStyle: buttonTextStyle,
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.yellow,
                              side: const BorderSide(color: Color(0xffE0E3E7)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 10, right: 10),
                                      child: Icon(
                                        Icons.import_export,
                                        color: Color(0xff57636C),
                                        size: 50,)
                                  )
                                ]
                            ) // Set a tooltip for long-press
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              textStyle: buttonTextStyle,
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.yellow,
                              side: const BorderSide(color: Color(0xffE0E3E7)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 10, right: 10),
                                      child: Icon(
                                        Icons.print, color: Color(0xff57636C),
                                        size: 50,)
                                  )
                                ]
                            ) // Set a tooltip for long-press
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                            onPressed: () {
                              addVariation();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              textStyle: buttonTextStyle,
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.yellow,
                              side: const BorderSide(color: Color(0xffE0E3E7)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 10, right: 10),
                                      child: Icon(
                                        Icons.add_circle_outline,
                                        color: Color(0xff57636C),
                                        size: 50,)
                                  )
                                ]
                            ) // Set a tooltip for long-press
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  if(showVariationsList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: variations.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  child: Text((index + 1).toString()),
                                ),
                                title: Text(variations[index].name),
                                subtitle: Row(
                                  children: [
                                    const Text('Values : ', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                    Text(variations[index].values!)
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editVariation(variations[index].id);
                                        break;
                                      case 'delete':
                                        deleteVariation(variations[index].id);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    if(variations[index].isDelete) {
                                      return ['Edit', 'Delete'].map((String e) {
                                        return PopupMenuItem<String>(
                                          value: e,
                                          child: Text(e),
                                        );
                                      }).toList();
                                    }else{
                                      return ['Edit'].map((String e) {
                                        return PopupMenuItem<String>(
                                          value: e,
                                          child: Text(e),
                                        );
                                      }).toList();
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                ],
              ),
            );
          }
      ),
    );
  }
}

class VariationForm extends StatefulWidget {
  final int? id;
  const VariationForm({Key? key, this.id}) : super(key: key);

  @override
  VariationFormState createState()=> VariationFormState();
}

class VariationFormState extends State<VariationForm>{

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  final TextEditingController variationNameController = TextEditingController();
  late List<Map<int,TextEditingController>> variationValueControllers = [];
  late List<FocusNode> variationValueFocusNodes = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late List<Variation> variations = [];
  late String variationName = "";
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int variationId = 0;
  late List<String> variationValues = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    variationId = widget.id ?? 0;
    // getVariations();
    if(variationId > 0){
      getVariation(variationId);
    }else{
      getVariationVals();
    }
  }

  getVariation(int id) async {
    dynamic response = await RestSerice().getData("/variations/$id");
    List<dynamic> variationList = (response['data'] as List).cast<dynamic>();
    dynamic variation = variationList.isNotEmpty ? variationList[0] : null;

    variationNameController.text = variation['name'];

    for (var varVal in variation['values']) {
      TextEditingController variationValueController = TextEditingController();
      variationValueController.text = varVal['name'];
      Map<int, TextEditingController> contrlr = {};
      contrlr[varVal['id']] = variationValueController;
      variationValueControllers.add(contrlr);
      variationValueFocusNodes.add(FocusNode());
    }

    setState(() {
      variationId = id;
      variationValueFocusNodes = variationValueFocusNodes;
      variationValueControllers = variationValueControllers;
    });

    variationValueFocusNodes[variationValueFocusNodes.length - 1]
        .requestFocus();
  }

  getVariationVals() async {
    Map<int, TextEditingController> contrlr = {};
    contrlr[0] = TextEditingController();
    variationValueControllers.add(contrlr);
    variationValueFocusNodes.add(FocusNode());

    setState(() {
      variationValueControllers = variationValueControllers;
      variationValueFocusNodes = variationValueFocusNodes;
    });

    variationValueFocusNodes[variationValueFocusNodes.length - 1]
        .requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(error)
                    Text(errorMsg,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 18)),
                  if(success)
                    Text(successMsg,
                        style: const TextStyle(
                            color: Colors.green, fontSize: 18)),
                  const SizedBox(height: 16.0),
                  if(!success)
                    Column(
                      children: [
                        AllComponents().buildTextFormField(
                            labelText: 'Name',
                            controller: variationNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please specify variation name.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                variationName = value;
                              });
                            }
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: variationValueControllers.length,
                                  itemBuilder: (context, index) {

                                    if(index == 0) {
                                      return Container(
                                          height: 85,
                                          padding: const EdgeInsets.all(4),
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                if(variationId == 0)
                                                  Flexible(
                                                    child: AllComponents()
                                                        .buildTextFormField(
                                                      labelText: 'Variation Value',
                                                      controller: variationValueControllers[index].values.first,
                                                      focusNode: variationValueFocusNodes[index],
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please specify variation value.';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                if(variationId > 0)
                                                  Flexible(
                                                    child: AllComponents()
                                                        .buildTextFormField(
                                                      labelText: 'Variation Value',
                                                      controller: variationValueControllers[index].values.first,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please specify variation value.';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                const SizedBox(width: 16),
                                                OutlinedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        variationValueFocusNodes
                                                            .add(FocusNode());
                                                        // variationValueControllers
                                                        //     .add(
                                                        //     TextEditingController());
                                                        Map<int, TextEditingController> newContrlr = {};
                                                        newContrlr[0] = TextEditingController();
                                                        variationValueControllers.add(newContrlr);
                                                      });

                                                      variationValueFocusNodes[variationValueFocusNodes
                                                          .length - 1]
                                                          .requestFocus();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: const EdgeInsets
                                                          .all(0),
                                                      textStyle: buttonTextStyle,
                                                      foregroundColor: Colors
                                                          .white,
                                                      backgroundColor: const Color(
                                                          0xff1572e8),
                                                      shadowColor: Colors
                                                          .yellow,
                                                      side: const BorderSide(
                                                          color: Color(
                                                              0xffE0E3E7)),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(12),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                  top: 9,
                                                                  bottom: 9,
                                                                  left: 10,
                                                                  right: 10),
                                                              child: Icon(
                                                                Icons
                                                                    .add,
                                                                color: Colors
                                                                    .white,
                                                                size: 50,)
                                                          )
                                                        ]
                                                    ) // Set a tooltip for long-press
                                                ),
                                              ]
                                          )
                                      );
                                    }
                                    if(variationId == 0) {
                                      return Container(
                                          height: 85,
                                          padding: const EdgeInsets.all(4),
                                          child: AllComponents()
                                              .buildTextFormField(
                                            labelText: 'Variation Value',
                                            controller: variationValueControllers[index].values.first,
                                            focusNode: variationValueFocusNodes[index],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please specify variation value.';
                                              }
                                              return null;
                                            },
                                          )
                                      );
                                    }

                                    return Container(
                                        height: 85,
                                        padding: const EdgeInsets.all(4),
                                        child: AllComponents()
                                            .buildTextFormField(
                                          labelText: 'Variation Value',
                                          controller: variationValueControllers[index].values.first,
                                          focusNode: variationValueFocusNodes[index],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please specify variation value.';
                                            }
                                            return null;
                                          },
                                        )
                                    );

                                  },
                                )
                            )
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if(!success)
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              Map<String, dynamic> payload = {};

                              payload["name"] = variationNameController.text;

                              var varVals = [];

                              Map<String, dynamic> updatesVals = {};

                              for(var tec in variationValueControllers){
                                if(tec.keys.first > 0){
                                  updatesVals[tec.keys.first.toString()] = tec.values.first.text;
                                }else {
                                  varVals.add(tec.values.first.text);
                                }
                              }

                              payload["variation_values"] = varVals;
                              payload["edit_variation_values"] = jsonEncode(updatesVals);

                              dynamic response = variationId > 0
                                  ? await RestSerice().putData(
                                  "/variations/$variationId", payload)
                                  : await RestSerice().postData(
                                  "/variations", payload);

                              if (response.containsKey('success')) {
                                if (response['success']) {
                                  setState(() {
                                    successMsg = response['msg'];
                                    success = true;
                                  });
                                } else {
                                  setState(() {
                                    errorMsg = response['msg'];
                                    error = true;
                                  });
                                }
                              } else {
                                setState(() {
                                  errorMsg =
                                  "Something went wrong, please try again later";
                                  error = true;
                                });
                              }
                            }
                          },
                          child: const Text('Save'),
                        ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the popup
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  )
                ],
              ),
            )
        )
    );
  }
}