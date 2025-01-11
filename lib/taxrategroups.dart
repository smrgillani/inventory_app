import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/BusinessLocation.dart';
import 'models/Tax.dart';
import 'models/TaxGroup.dart';

class TaxGroupScreen extends StatefulWidget {
  const TaxGroupScreen({super.key});

  @override
  TaxGroupScreenState createState() => TaxGroupScreenState();
}

class TaxGroupScreenState extends State<TaxGroupScreen> {

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

  late List<TaxGroup> taxrategroups = [];

  bool showTaxGroupsList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTaxGroups();
  }

  getAllTaxGroups() async {
    taxrategroups = [];
    dynamic response = await RestSerice().getData('/group-tax');
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();

    for(var tax in taxList){
      taxrategroups.add(TaxGroup(id: tax['id'], name: tax['name'], amount: double.parse(tax['amount'].toString()), subTaxesName: tax['sub_taxes'].map((varVal) => varVal["name"].toString()).join(', ')));
    }

    setState(() {
      showTaxGroupsList = true;
    });

  }

  addTaxGroup() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Tax Group'),
        content: TaxGroupForm(),
      );
    });
    await getAllTaxGroups();
  }

  deleteTaxGroup(int id) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Tax Group"),
          content: const Text("Are you sure you want to delete this Tax Group?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await RestSerice().delData('/group-tax/$id');
                await getAllTaxGroups();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editTaxGroup(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Tax Group'),
        content: TaxGroupForm(id: id),
      );
    });
    await getAllTaxGroups();
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
                        Text('Tax Groups',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text(
                                'Combination of multiple taxes', style: TextStyle(
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
                              addTaxGroup();
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
                  if(showTaxGroupsList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: taxrategroups.length,
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
                                title: Text(taxrategroups[index].name),
                                subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Amount: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text('${taxrategroups[index].amount}% '),
                                          const Text(' - '),
                                          const Text(' Sub Taxes: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(taxrategroups[index].subTaxesName!)
                                        ],
                                      ),
                                    ]
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editTaxGroup(taxrategroups[index].id);
                                        break;
                                      case 'delete':
                                        deleteTaxGroup(taxrategroups[index].id);
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

class TaxGroupForm extends StatefulWidget {
  final int? id;
  const TaxGroupForm({Key? key, this.id}) : super(key: key);

  @override
  TaxGroupFormState createState()=> TaxGroupFormState();
}

class TaxGroupFormState extends State<TaxGroupForm>{

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  final TextEditingController groupNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int taxGroupId = 0;
  late List<Tax> taxrates = [];
  late List<Tax> selectedTaxrates = [];
  late List<int> taxIds = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    taxGroupId = widget.id ?? 0;
    if(taxGroupId > 0) {
      getTable(taxGroupId);
    }

    getTaxes();
  }

  getTable(int id) async{

    dynamic response = await RestSerice().getData("/group-tax/$id");
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();
    dynamic tax = taxList.isNotEmpty ? taxList[0] : null;

    groupNameController.text = tax['name'];

    for(var subTax in tax['sub_taxes']){
      taxIds.add(subTax['id']);
      selectedTaxrates.add(Tax(id: subTax['id'], name: subTax['name']));
    }

    setState(() {
      taxGroupId = tax['id'];
      taxIds = taxIds;
      selectedTaxrates = selectedTaxrates;
    });

  }

  getTaxes() async{
    dynamic response = await RestSerice().getData("/tax");
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();
    for (dynamic tax in taxList) {
      taxrates.add(Tax(id: tax['id'], name: tax['name']));
    }
    setState(() {
      taxrates = taxrates;
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
                          controller: groupNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify tax name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        if(taxrates.isNotEmpty || selectedTaxrates.isNotEmpty)
                          DropdownSearch<Tax>.multiSelection(
                            // popupProps: PopupProps.menu(
                            //     showSearchBox: true
                            // ),
                            items: taxrates,
                            selectedItems: selectedTaxrates,
                            dropdownDecoratorProps: const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                hintText: 'Please select a tax',
                                labelText: 'Sub Taxes:',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            4.0))
                                ),
                              ),
                            ),
                            onChanged: (List<Tax> taxes) {
                              setState(() {
                                taxIds = taxes.map((e) => e.id).toList();
                              });
                            },
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

                              payload["name"] = groupNameController.text;
                              payload["taxes"] = taxIds;

                              dynamic response = taxGroupId > 0
                                  ? await RestSerice().putData(
                                  "/group-tax/$taxGroupId", payload)
                                  : await RestSerice().postData(
                                  "/group-tax", payload);

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