import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/BusinessLocation.dart';
import 'models/Tax.dart';

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

  late List<Tax> taxrategroups = [];

  bool showTaxGroupsList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTaxGroups();
  }

  getAllTaxGroups() async {
    taxrategroups = [];
    dynamic response = await RestSerice().getData('/tax');
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();

    for(var tax in taxList){
      taxrategroups.add(Tax(id: tax['id'], name: tax['name'], amount: double.parse(tax['amount'].toString()), isTaxGroup: tax['is_tax_group'] == 1, forTaxGroup: tax['for_tax_group'] == 1));
    }

    setState(() {
      showTaxGroupsList = true;
    });

  }

  addTaxRate() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Tax Rate'),
        content: TaxRateForm(),
      );
    });
    await getAllTaxes();
  }

  deleteTaxRate(int id) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Tax rate"),
          content: const Text("Are you sure you want to delete this Tax Rate?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await RestSerice().delData('/tax/$id');
                await getAllTaxes();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editTaxRate(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Tax Rate'),
        content: TaxRateForm(id: id),
      );
    });
    await getAllTaxes();
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
                        Text('Tax Rates',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text(
                                'Manage your tax rates', style: TextStyle(
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
                              addTaxRate();
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
                  if(showTaxesList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: taxrates.length,
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
                                title: Text('${taxrates[index].name} ${(taxrates[index].forTaxGroup! ? '(For tax group only)':'')} '),
                                subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Amount: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text('${taxrates[index].amount}%')
                                        ],
                                      ),
                                    ]
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editTaxRate(taxrates[index].id);
                                        break;
                                      case 'delete':
                                        deleteTaxRate(taxrates[index].id);
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

class TaxRateForm extends StatefulWidget {
  final int? id;
  const TaxRateForm({Key? key, this.id}) : super(key: key);

  @override
  TaxRateFormState createState()=> TaxRateFormState();
}

class TaxRateFormState extends State<TaxRateForm>{

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  final TextEditingController taxNameController = TextEditingController();
  final TextEditingController taxAmountController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int taxId = 0;
  late bool forTaxGroupOnly = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    taxId = widget.id ?? 0;

    if(taxId > 0) {
      getTable(taxId);
    }
  }

  getTable(int id) async{

    dynamic response = await RestSerice().getData("/tax/$id");
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();
    dynamic tax = taxList.isNotEmpty ? taxList[0] : null;

    taxNameController.text = tax['name'];
    taxAmountController.text = tax['amount'].toString();

    setState(() {
      taxId = tax['id'];
      forTaxGroupOnly = tax['for_tax_group'] == 1;
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
                          controller: taxNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify tax name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        AllComponents().buildTextFormField(
                          labelText: 'Tax Rate %',
                          controller: taxAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        CheckboxListTile(
                          value: forTaxGroupOnly,
                          controlAffinity: ListTileControlAffinity
                              .leading,
                          tristate: false,
                          title: const Text('For tax group only'),
                          onChanged: (value) {
                            setState(() {
                              forTaxGroupOnly = value!;
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

                              payload["name"] = taxNameController.text;
                              payload["amount"] = taxAmountController.text;
                              payload["for_tax_group"] = forTaxGroupOnly?1:0;

                              dynamic response = taxId > 0
                                  ? await RestSerice().putData(
                                  "/tax/$taxId", payload)
                                  : await RestSerice().postData(
                                  "/tax", payload);

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