import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/services/http.service.dart';

import 'main.dart';
import 'models/Category.dart';


class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {

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

  late List<ProductCategory> categories = [];

  bool showCategoriesList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllCategories();
  }

  getAllCategories() async {
    categories = [];
    dynamic response = await RestSerice().getData('/taxonomy');
    List<dynamic> categoryList = (response['data'] as List).cast<dynamic>();

    for(var category in categoryList){
      categories.add(ProductCategory(id: category['id'], name: category['name'], shortCode: category['short_code'], description: category['description']));
    }

    setState(() {
      showCategoriesList = true;
    });

  }

  addCategory() async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return const AlertDialog(
        title: Text('Add New Category'),
        content: CategoryForm(),
      );
    });
    await getAllCategories();
  }

  deleteCategory(int id) async {

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
                dynamic response = await RestSerice().delData('/taxonomy/$id');
                await getAllCategories();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editCategory(int id) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Edit Category'),
        content: CategoryForm(id: id),
      );
    });
    await getAllCategories();
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
                        Text('Categories',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text('Manage your categories', style: TextStyle(
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
                              addCategory();
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
                  if(showCategoriesList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
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
                                title: Text(categories[index].name),
                                subtitle: Row(
                                  children: [
                                    Text(categories[index].description ?? "", style: const TextStyle(
                                        fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value.toLowerCase()) {
                                      case 'edit':
                                        editCategory(categories[index].id);
                                        break;
                                      case 'delete':
                                        deleteCategory(categories[index].id);
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

class CategoryForm extends StatefulWidget {
  final int? id;
  const CategoryForm({Key? key, this.id}) : super(key: key);

  @override
  CategoryFormState createState()=> CategoryFormState();
}

class CategoryFormState extends State<CategoryForm>{

  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController categoryShortCodeController = TextEditingController();
  final TextEditingController categoryDescriptionController = TextEditingController();
  bool allowAddAsSubCategory = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late List<ProductCategory> categories = [];
  late String categoryName = "";
  late int baseCategoryId = 0;
  late bool success = false;
  late String successMsg = "";
  late bool error = false;
  late String errorMsg = "";
  late int categoryId = 0;
  late ProductCategory selectedSubCategory = ProductCategory(id: 0, name: 'Select parent category');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryId = widget.id ?? 0;
    getCategories();
    if(categoryId > 0){
      getCategory(categoryId);
    }
  }

  getCategories() async{
    dynamic response = await RestSerice().getData("/taxonomy");
    List<dynamic> categoryList = (response['data'] as List).cast<dynamic>();
    if(categoryId > 0) {
      for (dynamic category in categoryList) {
        if (categoryId != category['id']) {
          categories.add(ProductCategory(name: category['name'], id: category['id']));
        }
      }
    }else{
      for (dynamic category in categoryList) {
        categories.add(ProductCategory(name: category['name'], id: category['id']));
      }
    }
  }

  getCategory(int id) async{
    dynamic response = await RestSerice().getData("/taxonomy/$id");
    List<dynamic> categoryList = (response['data'] as List).cast<dynamic>();
    dynamic category = categoryList.isNotEmpty ? categoryList[0] : null;

    categoryNameController.text = category['name'];
    categoryShortCodeController.text = category['short_code'];
    setState(() {
      allowAddAsSubCategory = category['allow_decimal'] == 1 ? true : false;
    });

    categoryDescriptionController.text = category['description'];
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
                    controller: categoryNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please specify category name.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        categoryName = value;
                      });
                    }
                ),
                const SizedBox(height: 16.0),
                AllComponents().buildTextFormField(
                  labelText: 'Short Code',
                  controller: categoryShortCodeController
                ),
                const SizedBox(height: 16.0),
                AllComponents().buildTextFormField(
                    labelText: 'Description',
                    controller: categoryDescriptionController,
                    // keyboardType: TextInputType.multiline,
                    // maxLines: 3
                ),
                const SizedBox(height: 16.0),
                CheckboxListTile(
                  value: allowAddAsSubCategory,
                  controlAffinity: ListTileControlAffinity
                      .leading,
                  tristate: false,
                  title: const Text('Add as sub category'),
                  onChanged: (value) {
                    setState(() {
                      allowAddAsSubCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                if(allowAddAsSubCategory)
                  Column(
                    children: [
                      const SizedBox(height: 16.0),
                      DropdownSearch<ProductCategory>(
                        selectedItem: selectedSubCategory,
                        popupProps: const PopupProps.menu(
                            showSearchBox: true
                        ),
                        items: categories,
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
                            baseCategoryId = e!.id;
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

                      payload["category_type"] = "product";
                      payload["name"] = categoryNameController.text;
                      payload["short_code"] = categoryShortCodeController.text;
                      payload["description"] = categoryDescriptionController.text;

                      if(baseCategoryId > 0 && allowAddAsSubCategory) {
                        payload["add_as_sub_cat"] = "1";
                        payload["parent_id"] = baseCategoryId.toString();
                      }

                      dynamic response = categoryId > 0 ? await RestSerice().putData(
                          "/taxonomy/$categoryId", payload) : await RestSerice().postData(
                          "/taxonomy", payload);

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