import 'package:flutter/material.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/PriceGroup.dart';

class PriceGroupScreen extends StatefulWidget {
  const PriceGroupScreen({super.key});

  @override
  PriceGroupScreenState createState() => PriceGroupScreenState();
}

class PriceGroupScreenState extends State<PriceGroupScreen> {

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

  late List<PriceGroup> pricegroups = [];

  bool showPriceGroupsList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllPriceGroups();
  }

  getAllPriceGroups() async {
    pricegroups = [];
    dynamic response = await RestSerice().getData('/selling-price-group');
    List<dynamic> pgList = (response['data'] as List).cast<dynamic>();

    for(var priceGroup in pgList){
      pricegroups.add(PriceGroup(id: priceGroup['id'], name: priceGroup['name'], description: priceGroup['description'], isActive: priceGroup['is_active'] == 1));
    }

    setState(() {
      showPriceGroupsList = true;
    });

  }

  addPriceGroup() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Price Group'),
        content: PriceGroupForm(),
      );
    });
    await getAllPriceGroups();
  }

  deletePriceGroup(int id) async {

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
                dynamic response = await RestSerice().delData('/selling-price-group/$id');
                await getAllPriceGroups();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  deactivatePriceGroup(int id, bool cond) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        var status = (cond ? "Deactivate" : "Activate");
        return AlertDialog(
          title: Text("Confirm $status"),
          content: Text("Are you sure you want to ${status.toLowerCase()} this Record?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await RestSerice().getData('/selling-price-group/activate-deactivate/$id');
                print(response);
                await getAllPriceGroups();
                Navigator.pop(context);
              },
              child: Text(status),
            ),
          ],
        );
      },
    );
  }

  editPriceGroup(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Price Group'),
        content: PriceGroupForm(id: id),
      );
    });
    await getAllPriceGroups();
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
                        Text('Selling Price Group',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text('Manage your selling price group', style: TextStyle(
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
                              addPriceGroup();
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
                  if(showPriceGroupsList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pricegroups.length,
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
                                title: Text('${pricegroups[index].name} ${(pricegroups[index].isActive! ? '(Active)' : '(Inactive)')}'),
                                subtitle: Row(
                                  children: [
                                    Text(pricegroups[index].description ?? ""),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editPriceGroup(pricegroups[index].id);
                                        break;
                                      case 'delete':
                                        deletePriceGroup(pricegroups[index].id);
                                        break;
                                      case 'deactivate':
                                        deactivatePriceGroup(
                                            pricegroups[index].id, pricegroups[index].isActive!);
                                        break;
                                      case 'activate':
                                        deactivatePriceGroup(
                                            pricegroups[index].id, pricegroups[index].isActive!);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ['Edit', 'Delete', (pricegroups[index].isActive! ? 'Deactivate' : 'Activate')].map((String e) {
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

class PriceGroupForm extends StatefulWidget {
  final int? id;
  const PriceGroupForm({Key? key, this.id}) : super(key: key);

  @override
  PriceGroupFormState createState()=> PriceGroupFormState();
}

class PriceGroupFormState extends State<PriceGroupForm>{

  final TextEditingController pgNameController = TextEditingController();
  final TextEditingController pgDescriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int pgId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pgId = widget.id ?? 0;
    if(pgId > 0){
      getPriceGroup(pgId);
    }
  }

  getPriceGroup(int id) async{
    dynamic response = await RestSerice().getData("/selling-price-group/$id");
    List<dynamic> pgList = (response['data'] as List).cast<dynamic>();
    dynamic priceGroup = pgList.isNotEmpty ? pgList[0] : null;

    pgNameController.text = priceGroup['name'];
    pgDescriptionController.text = priceGroup['description'];
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
                        controller: pgNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please specify price group name.';
                          }
                          return null;
                        },
                        maxLines: 1
                    ),
                    const SizedBox(height: 16.0),
                    AllComponents().buildTextFormField(
                      labelText: 'Description',
                      controller: pgDescriptionController,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please specify price group description.';
                        }
                        return null;
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

                          payload["name"] = pgNameController.text;
                          payload["description"] =
                              pgDescriptionController.text;

                          dynamic response = pgId > 0
                              ? await RestSerice()
                              .putData(
                              "/selling-price-group/$pgId", payload)
                              : await RestSerice()
                              .postData(
                              "/selling-price-group", payload);

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