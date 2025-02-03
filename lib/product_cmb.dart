import 'package:flutter/material.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/BusinessLocation.dart';
import 'package:gs_erp/models/Product.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'main.dart';
import 'models/Category.dart';
import 'models/Currency.dart';
import 'models/Global.dart';
import 'models/ProductCombo.dart';
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

class ProductCmb extends StatefulWidget {
  final Function(ProductCombo p) addProd;
  const ProductCmb({super.key, required this.addProd});

  @override
  State<ProductCmb> createState() => ProductCmbState();
}

class ProductCmbState extends State<ProductCmb> {

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

  late ProductCombo singleProduct;

  late int prodId = 0;
  late String prodName = "";
  late double prodQty = 0;
  late String unitName = "";
  late int unitId = 0;
  late double defaultPurchasePriceExcTax = 0;
  late double totalPurchasePriceExcTax = 0;
  late double defaultPurchasePriceIncTax = 0;
  late double defaultSellingPriceExcTax = 0;
  late double defaultSellingPriceIncTax = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allComponents = AllComponents();
    checkBox = true;
    alertQuantity = false;
    selectedMonth = FinancialYearMonth.values[0];
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
        prodId = response['data'][0]['id'];
        prodName = '${response['data'][0]['name']} - ${response['data'][0]['sku']}';
        qtyController.text = "1";
        prodQty = 1;
        unitName = '${response['data'][0]['unit']['actual_name']}';
        unitId = response['data'][0]['unit']['id'];
        defaultPurchasePriceExcTax = double.parse(response['data'][0]['product_variations'][0]['variations'][0]['default_purchase_price']);
        // totalPurchasePriceExcTax = defaultPurchasePriceExcTax;
        defaultPurchasePriceIncTax = double.parse(response['data'][0]['product_variations'][0]['variations'][0]['dpp_inc_tax']);
        defaultSellingPriceExcTax = double.parse(response['data'][0]['product_variations'][0]['variations'][0]['default_sell_price']);
        defaultSellingPriceIncTax = double.parse(response['data'][0]['product_variations'][0]['variations'][0]['sell_price_inc_tax']);
      });

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

                            Autocomplete<Product>(
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController controller,
                                    FocusNode focusNode,
                                    VoidCallback onFieldSubmitted) {
                                  return allComponents.buildTextFormField(
                                      labelText: 'Enter Product name / SKU / Scan bar code to search',
                                      controller: controller,
                                      focusNode: focusNode,
                                      maxLines: 1
                                  );
                                },
                                optionsBuilder: (
                                    TextEditingValue textEditingValue) async {
                                  await getSearchedProducts(
                                      textEditingValue.text);
                                  return searchProducts;
                                },
                                onSelected: (Product selection) async {
                                  await getSingleProduct(selection.productId);
                                }
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      SelectionContainer.disabled(
                                        child: Row(
                                            children: [
                                              const Text('Product Name:',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold),),
                                              Text(' $prodName',
                                                  style: const TextStyle(
                                                      fontSize: 22))
                                            ]),
                                      ),
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
                                          onChanged: (String value) {
                                            setState(() {
                                              prodQty = double.parse(
                                                  value.isNotEmpty
                                                      ? value
                                                      : "0");
                                              // totalPurchasePriceExcTax = prodQty * defaultPurchasePriceExcTax;
                                            });
                                          }
                                      ),
                                      SelectionContainer.disabled(child: Row(
                                          children: [
                                            const Text('Unit :',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            Text(' $unitName',
                                                style: const TextStyle(
                                                    fontSize: 22))
                                          ]
                                      )
                                      ),
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      SelectionContainer.disabled(child: Row(
                                          children: [
                                            const Text(
                                                'Purchase Price (Excluding Tax):',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            Text(
                                                ' ${erpGlobals['currency']['symbol']} $defaultPurchasePriceExcTax',
                                                style: const TextStyle(
                                                    fontSize: 22))
                                          ])
                                      ),
                                      SelectionContainer.disabled(child: Row(
                                          children: [
                                            const Text(
                                                'Total Amount (Exc. Tax):',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            Text(
                                                ' ${erpGlobals['currency']['symbol']} ${(prodQty *
                                                    defaultPurchasePriceExcTax)}',
                                                style: const TextStyle(
                                                    fontSize: 22))
                                          ])
                                      )
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                  onPressed: () {
                                    if (prodId > 0 && prodName.isNotEmpty) {
                                      singleProduct = ProductCombo(
                                          prodId,
                                          prodName,
                                          prodQty,
                                          unitName,
                                          unitId,
                                          defaultPurchasePriceExcTax,
                                          totalPurchasePriceExcTax,
                                          defaultPurchasePriceIncTax,
                                          defaultSellingPriceExcTax,
                                          defaultSellingPriceIncTax);
                                      this.widget.addProd(singleProduct);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(10),
                                      fixedSize: const Size(200, 54),
                                      textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      foregroundColor: Colors.black87,
                                      shadowColor: Colors.yellow,
                                      shape: const StadiumBorder()
                                  ),
                                  child: const Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Text(' Add '),
                                        Icon(Icons.add)
                                      ]
                                  )
                              ),

                            ]),

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
