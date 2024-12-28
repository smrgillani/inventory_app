import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/BusinessLocation.dart';
import 'package:gs_erp/models/Product.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'common/button_widget.dart';
import 'main.dart';
import 'models/Category.dart';
import 'models/Currency.dart';
import 'models/Global.dart';
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

class ProductVar extends StatefulWidget {
  final Function(Product p) addProd;
  const ProductVar({super.key, required this.addProd});

  @override
  State<ProductVar> createState() => ProductVarState();
}

class ProductVarState extends State<ProductVar> {

  bool? checkBox;
  late bool alertQuantity;
  late AllComponents allComponents;
  Currency? selectedCurrency;
  final TextEditingController qtyController = TextEditingController();
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

  late Product singleProduct = Product(productId: 0, productName: "", productUnit: "", productPurchasePriceExcTax: 0, productPurchasePriceIncTax: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allComponents = AllComponents();
    checkBox = true;
    alertQuantity = false;
    selectedMonth = FinancialYearMonth.values[0];
    getUnits();
  }

  getUnits() async{
    dynamic response = await RestSerice().getData("/unit");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    for (dynamic unit in unitList) {
      units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')', id: unit['id']));
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

  getSingleProduct(int productId) async {
    if(productId > 0) {
      dynamic response = await RestSerice().getData(
          "/product/$productId");

      setState(() {
        singleProduct = Product(productId: response['data'][0]['id'], productName: '${response['data'][0]['name']} - ${response['data'][0]['sku']}', productUnit: '${response['data'][0]['unit']['actual_name']} (${response['data'][0]['unit']['short_name']})', productPurchasePriceExcTax: double.parse(response['data'][0]['product_variations'][0]['variations'][0]['default_purchase_price']));
        qtyController.text = "1";
      });


      // Map<String, dynamic> data = resp['data'];
      // for(var entry in erpGlobals.entries){
      //   print('${entry.key}: ${entry.value}');
      // }

      // List<dynamic> productList = (response['data'] as List).cast<dynamic>();
      // for (dynamic product in productList) {
      //   searchProducts.add(Product(
      //       productId: product['product_id'], productName: product['text']));
      // }
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
          double bottom = MediaQuery
              .of(context)
              .viewInsets
              .bottom;
          return Scaffold(
              appBar: AppBar(
                title: const Text('Add Combo Product'),
              ),
              body: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 16.0, top: 16.0, right: 16.0, bottom: bottom),
                      child: Column(
                          children: <Widget>[

                            const SizedBox(height: 16),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
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
                                            // categoryId = e!.id;
                                            // getSubCategories(e!.id);
                                          });
                                        },
                                      ),
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      SelectionContainer.disabled(child: Text(
                                          'Product Name: ${singleProduct.productName}')),
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      allComponents.buildTextFormField(
                                        controller: qtyController,
                                        labelText: 'Quantity:*',
                                      ),
                                      SelectionContainer.disabled(child: Text(
                                          'Unit : ${singleProduct.productUnit}')),
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      SelectionContainer.disabled(child: Text(
                                          'Purchase Price (Excluding Tax): ${erpGlobals['currency']['symbol']} ${singleProduct.productPurchasePriceExcTax}')),
                                      SelectionContainer.disabled(child: Text(
                                          'Total Amount (Exc. Tax): ${erpGlobals['currency']['symbol']} ${singleProduct.productPurchasePriceExcTax}'))
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            OutlinedButton(
                                onPressed: () {
                                  // _handleLogin(context);
                                  if(singleProduct.productName.length > 0) {
                                    this.widget.addProd(singleProduct);
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(10),
                                    fixedSize: const Size(200, 54),
                                    textStyle: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                    foregroundColor: Colors.black87,
                                    shadowColor: Colors.yellow,
                                    shape: const StadiumBorder()
                                ),
                                child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(' Add '),
                                      Icon(Icons.add)
                                    ]
                                )
                            ),

                            const SizedBox(height: 16.0),

                          ]
                      )
                  )
              )
          );
        }
    );
  }
}
