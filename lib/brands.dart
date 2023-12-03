import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/Unit.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  BrandsScreenState createState() => BrandsScreenState();
}

class BrandsScreenState extends State<BrandsScreen> {

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

  late List<Brand> brands = [];

  bool showBrandsList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllBrands();
  }

  getAllBrands() async {
    brands = [];
    dynamic response = await RestSerice().getData('/brand');
    List<dynamic> brandList = (response['data'] as List).cast<dynamic>();

    for(var brand in brandList){

      brands.add(Brand(id: brand['id'], name: brand['name'], description: brand['description']));

    }

    setState(() {
      showBrandsList = true;
    });

  }

  addBrand() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Brand'),
        content: BrandForm(),
      );
    });
    await getAllBrands();
  }

  deleteBrand(int id) async {

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
                dynamic response = await RestSerice().delData('/brand/$id');
                await getAllBrands();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editBrand(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Brand'),
        content: BrandForm(id: id),
      );
    });
    await getAllBrands();
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
                        Text('Brands',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text('Manage your brands', style: TextStyle(
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
                              addBrand();
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
                  if(showBrandsList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: brands.length,
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
                                title: Text(brands[index].name),
                                subtitle: Row(
                                  children: [
                                    Text(brands[index].description ?? ""),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editBrand(brands[index].id);
                                        break;
                                      case 'delete':
                                        deleteBrand(brands[index].id);
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

class BrandForm extends StatefulWidget {
  final int? id;
  const BrandForm({Key? key, this.id}) : super(key: key);

  @override
  BrandFormState createState()=> BrandFormState();
}

class BrandFormState extends State<BrandForm>{

  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController brandDescriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late List<Brand> brands = [];
  late String brandName = "";
  late int baseBrandId = 0;
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int brandId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    brandId = widget.id ?? 0;
    if(brandId > 0){
      getBrand(brandId);
    }
  }

  getBrand(int id) async{
    dynamic response = await RestSerice().getData("/brand/$id");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    dynamic unit = unitList.isNotEmpty ? unitList[0] : null;

    brandNameController.text = unit['name'];
    brandDescriptionController.text = unit['description'];

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
                    controller: brandNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please specify brand name.';
                      }
                      return null;
                    },
                    maxLines: 1
                ),
                const SizedBox(height: 16.0),
                AllComponents().buildTextFormField(
                  labelText: 'Short Description',
                  controller: brandDescriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please specify brand short description.';
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

                      payload["name"] = brandNameController.text;
                      payload["description"] = brandDescriptionController.text;

                      dynamic response = brandId > 0 ? await RestSerice()
                          .putData(
                          "/brand/$brandId", payload) : await RestSerice()
                          .postData(
                          "/brand", payload);

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
    );
  }
}