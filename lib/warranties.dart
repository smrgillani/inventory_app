import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/Warranty.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/Unit.dart';

class WarrantiesScreen extends StatefulWidget {
  const WarrantiesScreen({super.key});

  @override
  WarrantiesScreenState createState() => WarrantiesScreenState();
}

class WarrantiesScreenState extends State<WarrantiesScreen> {

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

  late List<Warranty> warranties = [];

  bool showWarrantiesList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllWarranties();
  }

  getAllWarranties() async {
    warranties = [];
    dynamic response = await RestSerice().getData('/warranty');
    List<dynamic> warrantyList = (response['data'] as List).cast<dynamic>();
    final Map<String, String> durationTypes = {"days": "Days", "months": "Months", "years":"Years"};

    for(var warranty in warrantyList){
      final String? drtnType = durationTypes[warranty['duration_type'].toString()];
      warranties.add(Warranty(id: warranty['id'], name: warranty['name'], description: warranty['description'], duration: double.parse(warranty['duration'].toString()), durationType: drtnType ?? ""));
    }

    setState(() {
      showWarrantiesList = true;
    });

  }

  addWarranty() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Warranty'),
        content: WarrantyForm(),
      );
    });
    await getAllWarranties();
  }

  deleteWarranty(int id) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this Record?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await RestSerice().delData('/warranty/$id');
                await getAllWarranties();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editWarranty(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Warranty'),
        content: WarrantyForm(id: id),
      );
    });
    await getAllWarranties();
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
                        Text('Warranties',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text('Manage your warranties', style: TextStyle(
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
                              addWarranty();
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
                  if(showWarrantiesList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: warranties.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.white,
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  child: Text((index + 1).toString()),
                                ),
                                title: Text(warranties[index].name),
                                subtitle: Row(
                                  children: [
                                    const Text('Duration:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(' ${(warranties[index].duration ?? 0)} ${warranties[index].durationType}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editWarranty(warranties[index].id);
                                        break;
                                      case 'delete':
                                        deleteWarranty(warranties[index].id);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ['Edit', 'Delete'].map((String e) {
                                      return PopupMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList();
                                  },
                                ),
                                children: <Widget>[
                                  Row(
                                    children: [
                                      const Text('Description: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(warranties[index].description!)
                                    ],
                                  ),
                                ],
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

class WarrantyForm extends StatefulWidget {
  final int? id;
  const WarrantyForm({Key? key, this.id}) : super(key: key);

  @override
  WarrantyFormState createState()=> WarrantyFormState();
}

class WarrantyFormState extends State<WarrantyForm>{

  final TextEditingController warrantyNameController = TextEditingController();
  final TextEditingController warrantyDescriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int warrantyId = 0;
  final List<String> durationTypes = ["Days", "Months", "Years"];
  late String durationType = "Days";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    warrantyId = widget.id ?? 0;
    if(warrantyId > 0){
      getWarranty(warrantyId);
    }
  }

  getWarranty(int id) async{
    dynamic response = await RestSerice().getData("/warranty/$id");
    List<dynamic> warrantyList = (response['data'] as List).cast<dynamic>();
    dynamic warranty = warrantyList.isNotEmpty ? warrantyList[0] : null;

    warrantyNameController.text = warranty['name'];
    warrantyDescriptionController.text = warranty['description'];
    durationController.text = warranty['duration'].toString();

    setState(() {
      durationType = warranty['duration_type'];
    });
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
                    style: const TextStyle(color: Colors.red, fontSize: 18)),
              if(success)
                Text(successMsg,
                    style: const TextStyle(color: Colors.green, fontSize: 18)),
              const SizedBox(height: 16.0),
              if(!success)
                Column(
                  children: [
                    AllComponents().buildTextFormField(
                        labelText: 'Name',
                        controller: warrantyNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please specify warranty name.';
                          }
                          return null;
                        },
                        maxLines: 1
                    ),
                    const SizedBox(height: 16.0),
                    AllComponents().buildTextFormField(
                      labelText: 'Description',
                      controller: warrantyDescriptionController,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please specify warranty description.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    AllComponents().buildTextFormField(
                      labelText: 'Duration',
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'\d')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please specify duration.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                        value: durationType
                            .toLowerCase(),
                        decoration: const InputDecoration(
                          labelText: 'Duration Type:*',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(4.0)
                              )
                          ),
                        ),
                        items: durationTypes.map((
                            taxType) {
                          return DropdownMenuItem<
                              String>(
                            value: taxType.toLowerCase(),
                            child: Text(taxType),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            durationType = value!;
                          });
                        }
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

                          payload["name"] = warrantyNameController.text;
                          payload["description"] =
                              warrantyDescriptionController.text;
                          payload["duration"] =
                              durationController.text;
                          payload["duration_type"] =
                              durationType;


                          dynamic response = warrantyId > 0
                              ? await RestSerice()
                              .putData(
                              "/warranty/$warrantyId", payload)
                              : await RestSerice()
                              .postData(
                              "/warranty", payload);

                          print(response);

                          if (response.containsKey('success')) {
                            if (response['success']) {
                              // Navigator.pop(context);

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
        ),
      ),
    );
  }
}