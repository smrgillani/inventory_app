import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/BusinessLocation.dart';
import 'models/Tables.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  TableScreenState createState() => TableScreenState();
}

class TableScreenState extends State<TableScreen> {

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

  late List<Tables> tables = [];

  bool showTablesList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTables();
  }

  getAllTables() async {
    tables = [];
    dynamic response = await RestSerice().getData('/table');
    List<dynamic> tableList = (response['data'] as List).cast<dynamic>();

    for(var table in tableList){
      tables.add(Tables(id: table['id'], name: table['name'], blName: table['location'], description: table['description'] ?? ""));
    }

    setState(() {
      showTablesList = true;
    });

  }

  addTable() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Table'),
        content: TableForm(),
      );
    });
    await getAllTables();
  }

  deleteTable(int id) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Table"),
          content: const Text("Are you sure you want to delete this Table?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await RestSerice().delData('/table/$id');
                await getAllTables();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editTable(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Table'),
        content: TableForm(id: id),
      );
    });
    await getAllTables();
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
                        Text('Tables',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text(
                                'Manage product tables', style: TextStyle(
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
                              addTable();
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
                  if(showTablesList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tables.length,
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
                                title: Text(tables[index].name),
                                subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Business Location: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(tables[index].blName!)
                                        ],
                                      ),
                                    ]
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editTable(tables[index].id);
                                        break;
                                      case 'delete':
                                        deleteTable(tables[index].id);
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
                                      Text(tables[index].description!)
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

class TableForm extends StatefulWidget {
  final int? id;
  const TableForm({Key? key, this.id}) : super(key: key);

  @override
  TableFormState createState()=> TableFormState();
}

class TableFormState extends State<TableForm>{

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  final TextEditingController tableNameController = TextEditingController();
  final TextEditingController tableDescController = TextEditingController();
  late List<BusinessLocation> businessLocations = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int tableId = 0;
  late int blId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tableId = widget.id ?? 0;

    if(tableId > 0) {
      getTable(tableId);
    }else {
      getBusinessLocations();
    }
  }

  getTable(int id) async{

    dynamic response = await RestSerice().getData("/table/$id");
    List<dynamic> tableList = (response['data'] as List).cast<dynamic>();
    dynamic table = tableList.isNotEmpty ? tableList[0] : null;

    tableNameController.text = table['name'];
    tableDescController.text = table['description'];

    setState(() {
      tableId = table['id'];
      blId = table['location_id'];
    });

  }

  getBusinessLocations() async{
    dynamic response = await RestSerice().getData("/business-location");
    List<dynamic> businessLocationList = (response['data'] as List).cast<dynamic>();
    for (dynamic businessLocation in businessLocationList) {
      businessLocations.add(BusinessLocation(id: businessLocation['id'], name: businessLocation['name']));
    }
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
                        if(tableId == 0)
                          Column(
                              children: [
                                DropdownSearch<BusinessLocation>(
                                  popupProps: const PopupProps.menu(
                                      showSearchBox: true
                                  ),
                                  items: businessLocations,
                                  dropdownDecoratorProps: const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      hintText: 'Please select a business location',
                                      labelText: 'Business Locations:',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  4.0))
                                      ),
                                    ),
                                  ),
                                  onChanged: (e) {
                                    setState(() {
                                      blId = e!.id;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16.0)
                              ]
                          ),
                        AllComponents().buildTextFormField(
                          labelText: 'Name',
                          controller: tableNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify table name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        AllComponents().buildTextFormField(
                          labelText: 'Short Description',
                          controller: tableDescController,
                        ),
                        const SizedBox(height: 16.0),
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

                              payload["location_id"] = blId;
                              payload["name"] = tableNameController.text;
                              payload["description"] = tableDescController.text;


                              dynamic response = tableId > 0
                                  ? await RestSerice().putData(
                                  "/table/$tableId", payload)
                                  : await RestSerice().postData(
                                  "/table", payload);

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