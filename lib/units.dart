import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/Unit.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  UnitsScreenState createState() => UnitsScreenState();
}

class UnitsScreenState extends State<UnitsScreen> {

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

  late List<Unit> units = [];

  bool showUnitsList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUnits();
  }

  getAllUnits() async {
    units = [];
    dynamic response = await RestSerice().getData('/unit');
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();

    for(var unit in unitList){

      dynamic subUnit = {};

      if(unit.containsKey('base_unit') && unit['base_unit'] != 'null'){
        subUnit = unit['base_unit'];
      }else{
        subUnit['short_name'] = "";
      }

      String baseUnitMultiplier = "";

      try{
        baseUnitMultiplier = double.parse(unit['base_unit_multiplier']).toString();
      }catch(e){}

      bool allowDecimal = (unit['allow_decimal'] == 1 ? true: false);

      units.add(Unit(id: unit['id'], name: unit['actual_name'], allowDecimal:allowDecimal, baseUnitMultiplier: baseUnitMultiplier, shortName: unit['short_name'], baseUnitId: unit['base_unit_id'], baseUnitShortName: subUnit != null ? subUnit['short_name'] : ""));

    }

    setState(() {
      showUnitsList = true;
    });

  }

  addUnit() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Unit'),
        content: UnitForm(),
      );
    });
    await getAllUnits();
  }

  deleteUnit(int id) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this Unit?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await RestSerice().delData('/unit/$id');
                await getAllUnits();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editUnit(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Unit'),
        content: UnitForm(id: id),
      );
    });
    await getAllUnits();
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
                        Text('Units',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text('Manage your units', style: TextStyle(
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
                              addUnit();
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
                  if(showUnitsList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: units.length,
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
                                title: Text(units[index].name +
                                    (units[index].baseUnitId?.isNaN == false &&
                                        units[index].baseUnitId!.toInt() > 0
                                        ? '(${units[index]
                                        .baseUnitMultiplier}${units[index]
                                        .baseUnitShortName})'
                                        : '')
                                ),
                                subtitle: Row(
                                  children: [
                                    const Text('Short Name: ', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                    Text("${units[index].shortName!},  "),
                                    Expanded(
                                      child: CheckboxListTile(
                                        value: units[index].allowDecimal,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        tristate: false,
                                        title: const Text('Decimal value input'),
                                        onChanged: (bool? value) {},
                                      ),
                                    )
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editUnit(units[index].id);
                                        break;
                                      case 'delete':
                                        deleteUnit(units[index].id);
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

class UnitForm extends StatefulWidget {
  final int? id;
  const UnitForm({Key? key, this.id}) : super(key: key);

  @override
  UnitFormState createState()=> UnitFormState();
}

class UnitFormState extends State<UnitForm>{

  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController unitShortNameController = TextEditingController();
  final TextEditingController unitTimesBaseUnitController = TextEditingController();
  bool allowDecimal = false;
  bool allowMultiOfOtherUnit = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late List<Unit> units = [];
  late String unitName = "";
  late int baseUnitId = 0;
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int unitId = 0;
  late Unit selectedSubUnit = Unit(id: 0, name: 'Select base unit');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    unitTimesBaseUnitController.text = "0";
    unitId = widget.id ?? 0;
    getUnits();
    if(unitId > 0){
      getUnit(unitId);
    }
  }

  getUnits() async{
    dynamic response = await RestSerice().getData("/unit");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    for (dynamic unit in unitList) {
      units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')', id: unit['id']));
    }
  }

  getUnit(int id) async{
    dynamic response = await RestSerice().getData("/unit/$id");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    dynamic unit = unitList.isNotEmpty ? unitList[0] : null;

    double baseUnitMultiplierVal = 0;

    try{
      baseUnitMultiplierVal = double.parse(unit['base_unit_multiplier']);
    }catch(e){}

    unitNameController.text = unit['actual_name'];
    unitShortNameController.text = unit['short_name'];
    setState(() {
      allowDecimal = unit['allow_decimal'] == 1 ? true : false;
      allowMultiOfOtherUnit = (baseUnitMultiplierVal > 0 && unit['base_unit_id'] != 'null' && unit['base_unit'] != 'null' ? true : false);
      if(baseUnitMultiplierVal > 0 && unit['base_unit_id'] != 'null' && unit['base_unit'] != 'null'){
        dynamic subUnit = unit['base_unit'];
        selectedSubUnit = Unit(id: unit['base_unit_id'], name: subUnit['actual_name'] + '(' + subUnit['short_name'] + ')');
        baseUnitId = unit['base_unit_id'];
      }

    });

    unitTimesBaseUnitController.text = baseUnitMultiplierVal.toString();

  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
                    controller: unitNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please specify unit name.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        unitName = value;
                      });
                    }
                ),
                const SizedBox(height: 16.0),
                AllComponents().buildTextFormField(
                  labelText: 'Short Name',
                  controller: unitShortNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please specify unit short name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                CheckboxListTile(
                  value: allowDecimal,
                  controlAffinity: ListTileControlAffinity
                      .leading,
                  tristate: false,
                  title: const Text('Allow decimal ?'),
                  subtitle: const Text(
                      'Enable decimal units value input'),
                  onChanged: (value) {
                    setState(() {
                      allowDecimal = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  value: allowMultiOfOtherUnit,
                  controlAffinity: ListTileControlAffinity
                      .leading,
                  tristate: false,
                  title: const Text('Add as multiple of other unit'),
                  subtitle: const Column(
                    children: [
                      Text(
                          'Define this unit as the multiple of other units '),
                      Text('Ex: 1 dozen = 12 pieces',
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                  onChanged: (value) {
                    setState(() {
                      allowMultiOfOtherUnit = value!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                if(allowMultiOfOtherUnit)
                  Column(
                    children: [
                      Text('1 ${(unitName.isNotEmpty ? unitName : 'Unit')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8.0),
                      const Text('=', style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      AllComponents().buildTextFormField(
                        labelText: 'times base unit',
                        controller: unitTimesBaseUnitController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      DropdownSearch<Unit>(
                        selectedItem: selectedSubUnit,
                        popupProps: const PopupProps.menu(
                            showSearchBox: true
                        ),
                        items: units,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Please select a unit',
                            labelText: 'Select base unit',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        4.0))
                            ),
                          ),
                        ),
                        onChanged: (e) {
                          setState(() {
                            baseUnitId = e!.id;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
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

                      payload["actual_name"] = unitNameController.text;
                      payload["short_name"] = unitShortNameController.text;
                      payload["allow_decimal"] = allowDecimal ? "1" : "0";

                      double unitTimeBaseUnit = 0;

                      try {
                        unitTimeBaseUnit = double.parse(unitTimesBaseUnitController.text);
                      }catch(e){}

                      if(baseUnitId > 0 && unitTimeBaseUnit > 0 && allowMultiOfOtherUnit) {
                        payload["define_base_unit"] =
                        allowMultiOfOtherUnit ? "1" : "0";
                        payload["base_unit_multiplier"] =
                        unitTimesBaseUnitController
                            .text
                            .isNotEmpty
                            ? unitTimesBaseUnitController.text
                            : "0";
                        payload["base_unit_id"] = baseUnitId.toString();
                      }
                      // print(payload);
                      // return;

                      dynamic response = unitId > 0 ? await RestSerice().putData(
                          "/unit/$unitId", payload) : await RestSerice().postData(
                          "/unit", payload);

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
    );
  }
}