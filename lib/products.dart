import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/BusinessLocation.dart';
import 'package:gs_erp/models/Product.dart';
import 'package:gs_erp/product_var.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'common/button_widget.dart';
import 'main.dart';
import 'models/Category.dart';
import 'models/Currency.dart';
import 'models/Tax.dart';
import 'models/Unit.dart';

class PhotoItem {
  final String image;
  final String name;
  PhotoItem(this.image, this.name);
}

class BarcodeType {
  final String name;
  final String value;
  BarcodeType(this.name, this.value);

  @override
  String toString() {
    return name;
  }
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {

  bool? checkBox;
  late bool alertQuantity;
  late AllComponents allComponents;
  Currency? selectedCurrency;
  final QuillController _controller = QuillController.basic();
  FinancialYearMonth? selectedMonth;
  File? productImage;
  File? productBrochureImage;
  List<XFile> images = <XFile>[];
  late List<Unit> units = [];
  late List<Brand> brands = [];
  final List<BarcodeType> barcodeTypes = [BarcodeType("name 1", "value 1"),BarcodeType("name 2", "value 2")];
  late List<ProductCategory> categories = [];
  late List<ProductCategory> subCategories = [];
  late List<BusinessLocation> businessLocations = [];
  late List<Tax> taxes = [];
  late int categoryId;
  late int subCategoryId;
  final List<String> sellingPriceTaxType = ["Inclusive", "Exclusive"];
  final List<String> productType = ["Single", "Variable", "Combo"];
  late String selectedSellingPriceTaxType = "Inclusive";
  late String selectedProductType = "Single";
  late List<Product> searchProducts = [];

  late List<Product> comboProducts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allComponents = AllComponents();
    checkBox = true;
    alertQuantity = false;
    selectedMonth = FinancialYearMonth.values[0];
    getUnits();
    getBrands();
    getCategories();
    getBusinessLocations();
    getTaxes();
  }

  getUnits() async{
    dynamic response = await RestSerice().getData("/unit");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    for (dynamic unit in unitList) {
      units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')', id: unit['id']));
    }
  }

  getBrands() async{
    dynamic response = await RestSerice().getData("/brand");
    List<dynamic> brandList = (response['data'] as List).cast<dynamic>();
    for (dynamic brand in brandList) {
      brands.add(Brand(name: brand['name'], id: brand['id']));
    }
  }

  getCategories() async{
    dynamic response = await RestSerice().getData("/taxonomy");
    List<dynamic> categoryList = (response['data'] as List).cast<dynamic>();
    for (dynamic category in categoryList) {
      categories.add(ProductCategory(name: category['name'], id: category['id']));
    }
  }

  getSubCategories(int categoryId) async{
    dynamic response = await RestSerice().getData("/taxonomy/$categoryId");
    List<dynamic> subCategoryList = (response['data'][0]['sub_categories'] as List).cast<dynamic>();
    for (dynamic subCategory in subCategoryList) {
      subCategories.add(ProductCategory(name: subCategory['name'], id: subCategory['id']));
    }
  }

  getBusinessLocations() async{
    dynamic response = await RestSerice().getData("/business-location");
    List<dynamic> businessLocationList = (response['data'] as List).cast<dynamic>();
    for (dynamic businessLocation in businessLocationList) {
      businessLocations.add(BusinessLocation(id: businessLocation['id'], name: businessLocation['name']));
    }
  }

  getTaxes() async{
    dynamic response = await RestSerice().getData("/tax");
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();
    for (dynamic tax in taxList) {
      taxes.add(Tax(id: tax['id'], name: tax['name']));
    }
  }

  getSearchedProducts(String searchTerm) async {
    if(searchTerm.length > 1) {
      dynamic response = await RestSerice().getData(
          "/get-products?check_enable_stock=false&term=$searchTerm");
      List<dynamic> productList = (response['data'] as List).cast<dynamic>();
      for (dynamic product in productList) {
        searchProducts.add(Product(
            productId: product['product_id'], productName: product['text']));
      }
    }
  }

  Future<void> pickProductImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        productImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickBrochureImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        productBrochureImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final List<XFile> medias = await picker.pickMultiImage();
    if (medias != null) {
      setState(() {
        for(XFile image in medias) {
          images.add(image);
        }
      });
    }
  }

  void addComboProduct(Product p){
    comboProducts.add(p);
  }

  void removeProductImage() {
    setState(() {
      productImage = null;
    });
  }

  void removeBrochureImage() {
    setState(() {
      productBrochureImage = null;
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PhotoItem> _items = [
      PhotoItem(
          "https://images.pexels.com/photos/1772973/pexels-photo-1772973.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
          "Stephan Seeber")
    ];

    return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double imagePickerSize = isTablet ? 200 : 120;
          double bottom = MediaQuery.of(context).viewInsets.bottom;
          return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('Add New Product'),
              ),
              body: SingleChildScrollView(
                reverse: true,
                  child: Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: bottom),
                      child: Column(
                          children: <Widget>[
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      allComponents.buildTextFormField(
                                        labelText: 'Product Name:*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please specify your product name.';
                                          }
                                          return null;
                                        },
                                      ),
                                      allComponents.buildTextFormField(
                                        labelText: 'SKU:',
                                      )
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      DropdownSearch<BarcodeType>(
                                        popupProps: const PopupProps.menu(
                                            showSearchBox: true
                                        ),
                                        items: barcodeTypes,
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            hintText: 'Please select a barcode type',
                                            labelText: 'Barcode Type:*',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        4.0))
                                            ),
                                          ),
                                        ),
                                        onChanged: (e) {
                                          print(e?.value);
                                        },
                                      ),
                                      DropdownSearch<Unit>(
                                        popupProps: const PopupProps.menu(
                                            showSearchBox: true
                                        ),
                                        items: units,
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            hintText: 'Please select a unit',
                                            labelText: 'Unit:*',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        4.0))
                                            ),
                                          ),
                                        ),
                                        onChanged: (e) {
                                          print(e?.id);
                                        },
                                      )
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16.0),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      DropdownSearch<Brand>(
                                        popupProps: const PopupProps.menu(
                                            showSearchBox: true
                                        ),
                                        items: brands,
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            hintText: 'Please select a brand',
                                            labelText: 'Brand:',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        4.0))
                                            ),
                                          ),
                                        ),
                                        onChanged: (e) {
                                          print(e?.id);
                                        },
                                      ),
                                      DropdownSearch<ProductCategory>(
                                        popupProps: const PopupProps.menu(
                                            showSearchBox: true
                                        ),
                                        items: categories,
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            hintText: 'Please select a category for product',
                                            labelText: 'Category:',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        4.0))
                                            ),
                                          ),
                                        ),
                                        onChanged: (e) {
                                          setState(() {
                                            categoryId = e!.id;
                                            getSubCategories(e!.id);
                                          });
                                        },
                                      )
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16.0),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      DropdownSearch<ProductCategory>(
                                        popupProps: const PopupProps.menu(
                                            showSearchBox: true
                                        ),
                                        items: subCategories,
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            hintText: 'Please select a sub category for product',
                                            labelText: 'Sub category:',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        4.0))
                                            ),
                                          ),
                                        ),
                                        onChanged: (e) {
                                          print(e?.id);
                                        },
                                      ),
                                      DropdownSearch<
                                          BusinessLocation>.multiSelection(
                                        // popupProps: PopupProps.menu(
                                        //     showSearchBox: true
                                        // ),
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
                                          // print(e?.value);
                                        },
                                      ),
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16.0),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      CheckboxListTile(
                                        value: checkBox,
                                        controlAffinity: ListTileControlAffinity
                                            .leading,
                                        tristate: false,
                                        title: const Text('Manage Stock ?'),
                                        subtitle: const Text(
                                            'Enable stock management at product level'),
                                        onChanged: (value) {
                                          setState(() {
                                            checkBox =
                                            checkBox == true ? false : true;
                                            alertQuantity =
                                            checkBox == true ? false : true;
                                          });
                                        },
                                      ),
                                      allComponents.buildTextFormField(
                                        labelText: 'Alert quantity:',
                                        isReadOnly: alertQuantity,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*')),
                                        ],
                                      ),
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xffa1a0a1)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: SafeArea(
                                child: QuillProvider(
                                  configurations: QuillConfigurations(
                                    controller: _controller,
                                    sharedConfigurations: const QuillSharedConfigurations(
                                      locale: Locale('de'),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const QuillToolbar(),
                                      Expanded(
                                        child: QuillEditor.basic(
                                          configurations: const QuillEditorConfigurations(
                                              readOnly: false,
                                              placeholder: 'Type product description here ...',
                                              scrollable: true,
                                              padding: EdgeInsets.all(16)
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      Column(
                                          children: [
                                            ButtonWidget(
                                                text: 'Select a product image',
                                                icon: Icons.attach_file,
                                                color: Colors.white,
                                                onClicked: () {
                                                  pickProductImage();
                                                }
                                            ),
                                            if (productImage != null)
                                              Stack(
                                                  children: [
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 16),
                                                        alignment: Alignment
                                                            .center,
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width,
                                                        height: imagePickerSize,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: const Color(
                                                                0xffa1a0a1),
                                                            width: 1, // 20-pixel border
                                                          ),
                                                          borderRadius: BorderRadius
                                                              .circular(5),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .all(16),
                                                          child: productImage !=
                                                              null
                                                              ? Image.file(
                                                              productImage!,
                                                              fit: BoxFit.cover)
                                                              : const Text(''),
                                                        )
                                                    ),
                                                    Positioned(
                                                      top: 26,
                                                      right: 10,
                                                      child: InkWell(
                                                        onTap: removeProductImage,
                                                        child: const Column(
                                                            children: <Widget>[
                                                              Icon(Icons.cancel,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 45)
                                                            ]
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 76,
                                                      right: 10,
                                                      child: InkWell(
                                                        onTap: pickProductImage,
                                                        child: const Column(
                                                            children: <Widget>[
                                                              Icon(Icons
                                                                  .border_color,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  size: 45)
                                                            ]
                                                        ),
                                                      ),
                                                    )
                                                  ]
                                              )
                                          ]
                                      ),
                                      Column(
                                          children: [
                                            ButtonWidget(
                                                text: 'Select a product brochure',
                                                icon: Icons.attach_file,
                                                color: Colors.white,
                                                onClicked: () {
                                                  pickBrochureImage();
                                                }
                                            ),
                                            if (productBrochureImage != null)
                                              Stack(
                                                  children: [
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 16),
                                                        alignment: Alignment
                                                            .center,
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width,
                                                        height: imagePickerSize,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: const Color(
                                                                0xffa1a0a1),
                                                            width: 1, // 20-pixel border
                                                          ),
                                                          borderRadius: BorderRadius
                                                              .circular(5),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .all(16),
                                                          child: productBrochureImage !=
                                                              null
                                                              ? Image.file(
                                                              productBrochureImage!,
                                                              fit: BoxFit.cover)
                                                              : const Text(''),
                                                        )
                                                    ),
                                                    Positioned(
                                                      top: 26,
                                                      right: 10,
                                                      child: InkWell(
                                                        onTap: removeBrochureImage,
                                                        child: const Column(
                                                            children: <Widget>[
                                                              Icon(Icons.cancel,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 45)
                                                            ]
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 76,
                                                      right: 10,
                                                      child: InkWell(
                                                        onTap: pickBrochureImage,
                                                        child: const Column(
                                                            children: <Widget>[
                                                              Icon(Icons
                                                                  .border_color,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  size: 45)
                                                            ]
                                                        ),
                                                      ),
                                                    )
                                                  ]
                                              )
                                          ]
                                      )
                                    ]), context),
                            const SizedBox(height: 16.0),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      CheckboxListTile(
                                        value: checkBox,
                                        controlAffinity: ListTileControlAffinity
                                            .leading,
                                        tristate: false,
                                        title: const Text(
                                            'Enable Product description, IMEI or Serial Number'),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                      CheckboxListTile(
                                        value: checkBox,
                                        controlAffinity: ListTileControlAffinity
                                            .leading,
                                        tristate: false,
                                        title: const Text('Not for selling'),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16.0),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      allComponents.buildTextFormField(
                                        labelText: 'Weight:',
                                      ),
                                      allComponents.buildTextFormField(
                                        labelText: 'Service staff timer/Preparation time (In minutes):',
                                      )
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16.0),
                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      DropdownSearch<Tax>(
                                        popupProps: const PopupProps.menu(
                                            showSearchBox: true
                                        ),
                                        items: taxes,
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            hintText: 'Please select an applicable tax',
                                            labelText: 'Applicable Tax:',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        4.0))
                                            ),
                                          ),
                                        ),
                                        onChanged: (e) {
                                          print(e?.id);
                                        },
                                      ),
                                      DropdownButtonFormField<String>(
                                          value: selectedSellingPriceTaxType
                                              .toLowerCase(),
                                          decoration: const InputDecoration(
                                            labelText: 'Selling Price Tax Type:*',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius
                                                        .circular(
                                                        4.0))
                                            ),
                                          ),
                                          items: sellingPriceTaxType.map((
                                              taxType) {
                                            return DropdownMenuItem<
                                                String>(
                                              value: taxType.toLowerCase(),
                                              child: Text(taxType),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            // setState(() {
                                            //
                                            //   // widget.updateFormData(
                                            //   //     'fy_start_month', value?.value);
                                            // });
                                          }
                                      ),
                                      DropdownButtonFormField<String>(
                                          value: selectedProductType
                                              .toLowerCase(),
                                          decoration: const InputDecoration(
                                            labelText: 'Product Type:*',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius
                                                        .circular(
                                                        4.0))
                                            ),
                                          ),
                                          items: productType.map((prodType) {
                                            return DropdownMenuItem<String>(
                                              value: prodType.toLowerCase(),
                                              child: Text(prodType),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedProductType =
                                                  value.toString();
                                            });
                                          }
                                      ),
                                    ]
                                ),
                                context
                            ),
                            const SizedBox(height: 16.0),
                            if(selectedProductType.toLowerCase() == 'single')
                              Column(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color(0xffa1a0a1)),
                                            borderRadius: BorderRadius.circular(
                                                5),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 12,
                                                      top: 5,
                                                      right: 5,
                                                      bottom: 5),
                                                  child: Text(
                                                    'Default Purchase Price',
                                                    style: TextStyle(
                                                        color: Color(
                                                            0xffffffff),
                                                        fontSize: 20),),
                                                ),
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets.all(
                                                      16),
                                                  child: allComponents
                                                      .buildResponsiveWidget(
                                                      Column(
                                                          children: [
                                                            allComponents
                                                                .buildTextFormField(
                                                              labelText: 'Exc. tax:*',
                                                            ),
                                                            allComponents
                                                                .buildTextFormField(
                                                              labelText: 'Inc. tax:*',
                                                            )
                                                          ]), context)
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    allComponents
                                        .buildResponsiveWidget(
                                        Column(
                                          children: [
                                            Container(
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xffa1a0a1)),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                    5),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12,
                                                          top: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text('x Margin(%)',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffffffff),
                                                            fontSize: 20),),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .all(
                                                          16),
                                                      child: allComponents
                                                          .buildTextFormField(
                                                        labelText: '',
                                                      )
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xffa1a0a1)),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                    5),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12,
                                                          top: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        'Default Selling Price',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffffffff),
                                                            fontSize: 20),),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .all(
                                                          16),
                                                      child: allComponents
                                                          .buildTextFormField(
                                                        labelText: 'Exc. Tax',
                                                      )
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ), context),
                                    const SizedBox(height: 16.0),
                                    allComponents
                                        .buildResponsiveWidget(
                                        Column(
                                          children: [
                                            Container(
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xffa1a0a1)),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                    5),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12,
                                                          top: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        'Product image',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffffffff),
                                                            fontSize: 20),),
                                                    ),
                                                  ),
                                                  if(images.isNotEmpty)
                                                    SingleChildScrollView(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          top: 11),
                                                      child: Column(
                                                        children: <Widget>[
                                                          // Other widgets...
                                                          GridView.builder(
                                                            shrinkWrap: true,
                                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisSpacing: 0,
                                                              mainAxisSpacing: 0,
                                                              crossAxisCount: 3,
                                                            ),
                                                            itemCount: images
                                                                .length,
                                                            itemBuilder: (
                                                                context,
                                                                index) {
                                                              return GestureDetector(
                                                                onTap: () {

                                                                },
                                                                child: Container(
                                                                  margin: const EdgeInsets
                                                                      .all(5),
                                                                  decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: FileImage(
                                                                          File(
                                                                              images[index]
                                                                                  .path)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .all(
                                                          16),
                                                      child: GestureDetector(
                                                          onTap: pickImage,
                                                          child: Container(
                                                              width: 200,
                                                              height: 200,
                                                              decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xffeeeeee),
                                                                border: Border
                                                                    .all(
                                                                  color: const Color(
                                                                      0xffa1a0a1),
                                                                  width: 1,
                                                                ),
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    5),
                                                              ),
                                                              child: const Column(
                                                                  mainAxisAlignment: MainAxisAlignment
                                                                      .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .add_photo_alternate,
                                                                      size: 100,
                                                                      color: Color(
                                                                          0xff9e9e9e),
                                                                    ),
                                                                    Text(
                                                                        'Select product images',
                                                                        style: TextStyle(
                                                                            fontSize: 16,
                                                                            color: Color(
                                                                                0xff797676),
                                                                            fontWeight: FontWeight
                                                                                .bold))
                                                                  ]
                                                              )
                                                          )
                                                      )
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ), context)
                                  ]
                              ),
                            const SizedBox(height: 16.0),
                            Column(
                              children: [
                                ButtonWidget(
                                    text: '',
                                    icon: Icons.add,
                                    color: Colors.white,
                                    onClicked: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (
                                              context) => ProductVar(addProd: addComboProduct)));
                                    }
                                )
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            // Autocomplete<Product>(
                            //     fieldViewBuilder: (BuildContext context,
                            //         TextEditingController controller,
                            //         FocusNode focusNode,
                            //         VoidCallback onFieldSubmitted) {
                            //       return allComponents.buildTextFormField(
                            //           labelText: 'Enter Product name / SKU / Scan bar code',
                            //           controller: controller,
                            //           focusNode: focusNode,
                            //           maxLines: 1
                            //       );
                            //       // return TextFormField(
                            //       //   // decoration: InputDecoration(
                            //       //   //   errorText: _networkError ? 'Network error, please try again.' : null,
                            //       //   // ),
                            //       //   controller: controller,
                            //       //   focusNode: focusNode,
                            //       //   onFieldSubmitted: (String value) {
                            //       //     onFieldSubmitted();
                            //       //   },
                            //       // );
                            //     },
                            //     optionsBuilder: (
                            //         TextEditingValue textEditingValue) async {
                            //       // setState(() {
                            //       //   // _networkError = false;
                            //       // });
                            //       // final Iterable<String>? options =
                            //       // await _debouncedSearch(textEditingValue.text);
                            //       // if (options == null) {
                            //       //   return _lastOptions;
                            //       // }
                            //       // _lastOptions = options;
                            //       // return options;
                            //       await getSearchedProducts(
                            //           textEditingValue.text);
                            //       return searchProducts;
                            //     },
                            //     onSelected: (Product selection) {
                            //       debugPrint(
                            //           'You just selected ${selection
                            //               .productId}');
                            //     }
                            // ),
                          ]
                      )
                  )
              )
          );
        }
    );
  }
}
