import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/BusinessLocation.dart';
import 'package:gs_erp/models/Product.dart';
import 'package:gs_erp/models/ProductCombo.dart';
import 'package:gs_erp/models/ProductVariations.dart';
import 'package:gs_erp/product_cmb.dart';
import 'package:gs_erp/product_var.dart';
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

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  bool? checkBox;
  late bool alertQuantity;
  late bool prodDIS;
  late bool prodNFS;
  late AllComponents allComponents;
  Currency? selectedCurrency;
  final QuillController _controller = QuillController.basic();
  FinancialYearMonth? selectedMonth;
  File? productImage;
  File? productBrochureImage;
  List<XFile> images = <XFile>[];
  late List<Unit> units = [];
  late List<Brand> brands = [];
  final List<BarcodeType> barcodeTypes = [
    BarcodeType("Code 128 (C128)", "C128"),
    BarcodeType("Code 39 (C39)", "C39"),
    BarcodeType("EAN-13", "EAN13"),
    BarcodeType("EAN-13", "EAN13"),
    BarcodeType("EAN-8", "EAN8"),
    BarcodeType("UPC-A", "UPCA"),
    BarcodeType("UPC-E", "UPCE")
  ];
  late List<ProductCategory> categories = [];
  late List<ProductCategory> subCategories = [];
  late List<BusinessLocation> businessLocations = [];
  late List<Tax> taxes = [];
  late int categoryId;
  late int subCategoryId;
  late int selectedTaxId;
  late double selectedTaxValue = 0;
  final List<String> sellingPriceTaxType = ["Inclusive", "Exclusive"];
  final List<String> productType = ["Single", "Variable", "Combo"];
  late String selectedSellingPriceTaxType = "inclusive";
  late String selectedProductType = "Single";
  late List<Product> searchProducts = [];
  late List<dynamic> customLabels = [];
  late List<dynamic> customLabelsLocations = [];

  late String selectBarCodeType = "";
  late int selectedUnitId = 0;
  late int selectedBrandId = 0;
  late int selectedCategoryId = 0;
  late int selectedSubCategoryId = 0;
  late List<BusinessLocation> selectedBusinessLocations = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  late List<ProductCombo> comboProducts = [];
  late List<ProductVariation> varsProducts = [];

  late TextEditingController comboDSP = TextEditingController();
  late double comboILPPTotalExcTax = 0;
  late double comboILPPTotalIncTax = 0;
  late TextEditingController comboMrgn = TextEditingController(text:erpGlobals['default_profit_percent'].toString());

  late TextEditingController productName = TextEditingController();
  late TextEditingController productSku = TextEditingController();
  late TextEditingController productAlertQty = TextEditingController();
  late TextEditingController productDescp = TextEditingController();
  late TextEditingController productWeight = TextEditingController();
  late TextEditingController productPrepTime = TextEditingController();

  late TextEditingController productSinglePPExcTax = TextEditingController();
  late TextEditingController productSinglePPIncTax = TextEditingController();
  late TextEditingController productSingleMargin = TextEditingController(text:erpGlobals['default_profit_percent'].toString());
  late TextEditingController productSingleSPExcTax = TextEditingController();
  late TextEditingController productSingleSPIncTax = TextEditingController();


  late FocusNode productNameFocus = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allComponents = AllComponents();
    checkBox = true;
    alertQuantity = false;
    prodDIS = true;
    prodNFS = true;
    selectedMonth = FinancialYearMonth.values[0];
    getUnits();
    getBrands();
    getCategories();
    getBusinessLocations();
    getTaxes();
    getProductCL();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // productNameFocus.requestFocus();
      FocusScope.of(context).unfocus();
      scrollController.jumpTo(0.0);
    });
  }

  getProductCL() async {
    dynamic response = await RestSerice().getData("/get-products-lncl");

    for (dynamic customLabel in response['data']['custom_labels']) {
      customLabels.add(customLabel);
    }

    for (dynamic customLabelsLocation in response['data']['locations']) {
      customLabelsLocations.add(customLabelsLocation);
    }

    setState(() {
      customLabels = customLabels.toList();
      customLabelsLocations = customLabelsLocations.toList();
    });
  }

  getUnits() async {
    dynamic response = await RestSerice().getData("/unit");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    for (dynamic unit in unitList) {
      units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')',
          id: unit['id']));
    }
  }

  getBrands() async {
    dynamic response = await RestSerice().getData("/brand");
    List<dynamic> brandList = (response['data'] as List).cast<dynamic>();
    for (dynamic brand in brandList) {
      brands.add(Brand(name: brand['name'], id: brand['id']));
    }
  }

  getCategories() async {
    dynamic response = await RestSerice().getData("/taxonomy");
    List<dynamic> categoryList = (response['data'] as List).cast<dynamic>();
    for (dynamic category in categoryList) {
      categories.add(ProductCategory(name: category['name'], id: category['id']));
    }
  }

  getSubCategories(int categoryId) async {
    dynamic response = await RestSerice().getData("/taxonomy/$categoryId");
    List<
        dynamic> subCategoryList = (response['data'][0]['sub_categories'] as List)
        .cast<dynamic>();
    for (dynamic subCategory in subCategoryList) {
      subCategories.add(ProductCategory(name: subCategory['name'], id: subCategory['id']));
    }
  }

  getBusinessLocations() async {
    dynamic response = await RestSerice().getData("/business-location");
    List<dynamic> businessLocationList = (response['data'] as List).cast<dynamic>();

    for (dynamic businessLocation in businessLocationList) {
      businessLocations.add(BusinessLocation(id: businessLocation['id'], name: businessLocation['name']));
    }
  }

  getTaxes() async {
    dynamic response = await RestSerice().getData("/tax");
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();
    for (dynamic tax in taxList) {
      taxes.add(Tax(id: tax['id'], name: tax['name'], amount: double.parse(tax['amount'].toString())));
    }
  }

  getSearchedProducts(String searchTerm) async {
    if (searchTerm.length > 1) {
      dynamic response = await RestSerice().getData("/get-products?check_enable_stock=false&term=$searchTerm");
      List<dynamic> productList = (response['data'] as List).cast<dynamic>();
      for (dynamic product in productList) {
        searchProducts.add(Product(productId: product['product_id'], productName: product['text']));
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
    if(pickedFile != null) {
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
        for (XFile image in medias) {
          images.add(image);
        }
      });
    }
  }

  void addComboProduct(ProductCombo p) {
    setState(() {
      comboProducts.add(p);
      sumComboDSP();
    });
  }

  void removeComboProduct(int index) {
    setState(() {
      comboProducts.removeAt(index);
      sumComboDSP();
    });
  }

  void updateComboProd(ProductCombo p, int index) {
    setState(() {
      comboProducts[index] = p;
      sumComboDSP();
    });
  }

  void sumComboDSP(){
    if(comboProducts.isNotEmpty) {
      comboDSP.text = (comboProducts.map((e) => (e.defaultSellingPriceExcTax * e.qty)).reduce((a, b) => a + b)).toString();
      comboILPPTotalExcTax = (comboProducts.map((e) => (e.defaultPurchasePriceExcTax * e.qty)).reduce((a, b) => a + b));
    }
  }

  void addVarsProduct(int mainVarId, String mainVarName, List<ProductVariations> products) {
    setState(() {
      varsProducts.add(ProductVariation(mainVarId, mainVarName, products));
    });
  }

  void addSubVarsProduct(int mainIndex, ProductVariations products) {
    setState(() {
      varsProducts[mainIndex].productVariations.add(products);
    });
  }

  void updateSubVarsProduct(int mainIndex, int subIndex, ProductVariations products) {
    setState(() {
      varsProducts[mainIndex].productVariations[subIndex] = products;
    });
  }

  void removeProductImage() {
    setState(() {
      productImage = null;
    });
  }

  void removeBrochureImage() async {
    setState(() {
      productBrochureImage = null;
    });
  }

  void removeProductImages(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  updateProductImages(int index) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        images[index] = pickedFile;
      });
    }
  }


  onCLTBChanged(String value) {

  }

  onCLDDChanged(String? value) {

  }

  onCLDPChanged(String value) {

  }

  getRate({double principal = 0, double amount = 0}) {
    double interest = amount - principal;
    double div = interest/ principal;
    return div * 100;
  }

  addPercent({double amount = 0, double percentage = 0}) {
    var div = percentage / 100;
    var mul = div * amount;
    return amount + mul;
  }

  onCLDPTap() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      String formattedDate = '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.year.toString()}';
      // businessStartdateController.text = formattedDate;
      // widget.updateFormData('start_date', formattedDate);
    }
  }

  deleteVarItem(int mainIndex, int index) {
    setState(() {
      varsProducts[mainIndex].productVariations.removeAt(index);
      if(varsProducts[mainIndex].productVariations.isEmpty){
        varsProducts.removeAt(mainIndex);
      }
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

          //this bottom variable used to bring extra spacing between keyboard and input widget
          double bottom = MediaQuery
              .of(context)
              .viewInsets
              .bottom;


          return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('Add New Product'),
              ),
              body: SingleChildScrollView(
                  controller: scrollController,
                  // reverse: true,
                  child: Form(
                      key: formKey,
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 16.0,
                              top: 16.0,
                              right: 16.0,
                              bottom: bottom),
                          child: Column(
                              children: <Widget>[
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          allComponents.buildTextFormField(
                                            controller: productName,
                                            // focusNode: productNameFocus,
                                            labelText: 'Product Name:*',
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please specify your product name.';
                                              }
                                              return null;
                                            },
                                          ),
                                          allComponents.buildTextFormField(
                                            controller: productSku,
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
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedProductType = e!.value;
                                              });
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
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Please select a unit of your product.';
                                              }
                                              return null;
                                            },
                                            onChanged: (e) {
                                              setState(() {
                                                selectedUnitId = e!.id;
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
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedBrandId = e!.id;
                                              });
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
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedCategoryId = e!.id;
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
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedSubCategoryId = e!.id;
                                              });
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
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (List<
                                                BusinessLocation> locations) {
                                              for (var location in locations) {
                                                selectedBusinessLocations = [];
                                                setState(() {
                                                  selectedBusinessLocations.add(
                                                      location);
                                                });
                                              }
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
                                            controller: productAlertQty,
                                            isReadOnly: alertQuantity,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
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
                                                FormField<bool>(
                                                    builder: (state) {
                                                      return Column(children: [
                                                        ButtonWidget(
                                                            text: 'Select a product image',
                                                            icon: Icons
                                                                .attach_file,
                                                            color: Colors.white,
                                                            onClicked: () {
                                                              pickProductImage();
                                                            }
                                                        ),
                                                        if(state.errorText !=
                                                            null)
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 16),
                                                              child: Text(
                                                                state
                                                                    .errorText!,
                                                                style: TextStyle(
                                                                    color: Theme
                                                                        .of(
                                                                        context)
                                                                        .colorScheme
                                                                        .error
                                                                ),
                                                              )
                                                          )
                                                      ]);
                                                    },
                                                    validator: (value) {
                                                      if (productImage ==
                                                          null) {
                                                        return "Please select an image for your product.";
                                                      } else {
                                                        return null;
                                                      }
                                                    }),
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
                                                              border: Border
                                                                  .all(
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
                                                                  fit: BoxFit
                                                                      .cover)
                                                                  : const Text(
                                                                  ''),
                                                            )
                                                        ),
                                                        Positioned(
                                                          top: 26,
                                                          right: 10,
                                                          child: InkWell(
                                                            onTap: removeProductImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .cancel,
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
                                                                children: <
                                                                    Widget>[
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
                                                if (productBrochureImage !=
                                                    null)
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
                                                              border: Border
                                                                  .all(
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
                                                                  fit: BoxFit
                                                                      .cover)
                                                                  : const Text(
                                                                  ''),
                                                            )
                                                        ),
                                                        Positioned(
                                                          top: 26,
                                                          right: 10,
                                                          child: InkWell(
                                                            onTap: removeBrochureImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .cancel,
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
                                                                children: <
                                                                    Widget>[
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
                                        ]),
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
                                            title: const Text(
                                                'Enable Product description, IMEI or Serial Number'),
                                            onChanged: (value) {
                                              setState(() {
                                                prodDIS = value!;
                                              });
                                            },
                                          ),
                                          CheckboxListTile(
                                            value: checkBox,
                                            controlAffinity: ListTileControlAffinity
                                                .leading,
                                            tristate: false,
                                            title: const Text(
                                                'Not for selling'),
                                            onChanged: (value) {
                                              setState(() {
                                                prodNFS = value!;
                                              });
                                            },
                                          ),
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),

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
                                                'Custom Labels',
                                                style: TextStyle(
                                                    color: Color(
                                                        0xffffffff),
                                                    fontSize: 20),),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, top: 16, right: 16),
                                            child: ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: customLabels.length,
                                                separatorBuilder: (
                                                    BuildContext context,
                                                    int index) {
                                                  return Container();
                                                },
                                                itemBuilder: (context, index) {
                                                  //left it here unfinished as the responsiveness will be taken care later

                                                  final displayIndex = index *
                                                      2;

                                                  if (displayIndex >=
                                                      customLabels.length) {
                                                    return Container();
                                                  } else {
                                                    return Column(
                                                        children: [
                                                          allComponents
                                                              .buildResponsiveWidget(
                                                              Column(
                                                                  children: [
                                                                    allComponents
                                                                        .buildCLFormField(
                                                                        dataObj: customLabels[displayIndex],
                                                                        onTBChanged: onCLTBChanged,
                                                                        onDPChanged: onCLDPChanged,
                                                                        onDDChanged: onCLDDChanged,
                                                                        onDPTap: onCLDPTap
                                                                    ),
                                                                    if((displayIndex +
                                                                        1) <
                                                                        customLabels
                                                                            .length)
                                                                      allComponents
                                                                          .buildCLFormField(
                                                                          dataObj: customLabels[displayIndex +
                                                                              1],
                                                                          onTBChanged: onCLTBChanged,
                                                                          onDPChanged: onCLDPChanged,
                                                                          onDDChanged: onCLDDChanged,
                                                                          onDPTap: onCLDPTap
                                                                      )
                                                                  ]
                                                              ),
                                                              context
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0),
                                                        ]
                                                    );
                                                  }
                                                }
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 16.0),

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
                                                'Rack/Row/Position Details',
                                                style: TextStyle(
                                                    color: Color(
                                                        0xffffffff),
                                                    fontSize: 20),),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, top: 16, right: 16),
                                            child: ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: customLabelsLocations
                                                    .length,
                                                separatorBuilder: (
                                                    BuildContext context,
                                                    int index) {
                                                  return Container();
                                                },
                                                itemBuilder: (context, index) {
                                                  //left it here unfinished as the responsiveness will be taken care later
                                                  final displayIndex = index *
                                                      2;
                                                  if (displayIndex >=
                                                      customLabelsLocations
                                                          .length) {
                                                    return Container();
                                                  } else {
                                                    return Column(
                                                        children: [
                                                          allComponents
                                                              .buildResponsiveWidget(
                                                              Column(
                                                                  children: [
                                                                    Column(
                                                                        children: [
                                                                          Text(
                                                                              '${customLabelsLocations[displayIndex]['name']} (${customLabelsLocations[displayIndex]['location_id']})',
                                                                              style: const TextStyle(
                                                                                  fontSize: 20)),
                                                                          const SizedBox(
                                                                              height: 8.0),
                                                                          allComponents
                                                                              .buildTextFormField(
                                                                            labelText: 'Rack',
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 8.0),
                                                                          allComponents
                                                                              .buildTextFormField(
                                                                            labelText: 'Row',
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 8.0),
                                                                          allComponents
                                                                              .buildTextFormField(
                                                                            labelText: 'Position',
                                                                          )
                                                                        ]
                                                                    ),
                                                                    if((displayIndex +
                                                                        1) <
                                                                        customLabelsLocations
                                                                            .length)
                                                                      Column(
                                                                          children: [
                                                                            Text(
                                                                                '${customLabelsLocations[displayIndex +
                                                                                    1]['name']} (${customLabelsLocations[displayIndex +
                                                                                    1]['location_id']})',
                                                                                style: const TextStyle(
                                                                                    fontSize: 20)),
                                                                            const SizedBox(
                                                                                height: 8.0),
                                                                            allComponents
                                                                                .buildTextFormField(
                                                                              labelText: 'Rack',
                                                                            ),
                                                                            const SizedBox(
                                                                                height: 8.0),
                                                                            allComponents
                                                                                .buildTextFormField(
                                                                              labelText: 'Row',
                                                                            ),
                                                                            const SizedBox(
                                                                                height: 8.0),
                                                                            allComponents
                                                                                .buildTextFormField(
                                                                              labelText: 'Position',
                                                                            )
                                                                          ]
                                                                      ),
                                                                  ]
                                                              ),
                                                              context
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0)
                                                        ]
                                                    );
                                                  }
                                                }
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 16.0),

                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          allComponents.buildTextFormField(
                                            controller: productWeight,
                                            labelText: 'Weight:',
                                          ),
                                          allComponents.buildTextFormField(
                                            controller: productPrepTime,
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
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedTaxId = e!.id;
                                                selectedTaxValue =
                                                    e!.amount ?? 0;
                                              });
                                            },
                                          ),
                                          DropdownButtonFormField<String>(
                                              value: selectedSellingPriceTaxType,
                                              decoration: const InputDecoration(
                                                labelText: 'Selling Price Tax Type:*',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
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
                                                setState(() {
                                                  selectedSellingPriceTaxType =
                                                      value!.toLowerCase();
                                                });
                                              }
                                          ),
                                          DropdownButtonFormField<String>(
                                              value: selectedProductType
                                                  .toLowerCase(),
                                              decoration: const InputDecoration(
                                                labelText: 'Product Type:*',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius
                                                            .circular(
                                                            4.0))
                                                ),
                                              ),
                                              items: productType.map((
                                                  prodType) {
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
                                if(selectedProductType.toLowerCase() ==
                                    'single')
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
                                                        'Default Purchase Price',
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
                                                          .buildResponsiveWidget(
                                                          Column(
                                                              children: [
                                                                allComponents
                                                                    .buildTextFormField(
                                                                    controller: productSinglePPExcTax,
                                                                    labelText: 'Exc. tax:*',
                                                                    validator: (
                                                                        value) {
                                                                      if (value ==
                                                                          null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return "Please enter purchase price (Exc. tax).";
                                                                      } else {
                                                                        return null;
                                                                      }
                                                                    }
                                                                ),
                                                                allComponents
                                                                    .buildTextFormField(
                                                                    controller: productSinglePPIncTax,
                                                                    labelText: 'Inc. tax:*',
                                                                    validator: (
                                                                        value) {
                                                                      if (value ==
                                                                          null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return "Please enter purchase price (Inc. tax).";
                                                                      } else {
                                                                        return null;
                                                                      }
                                                                    }
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
                                                          padding: EdgeInsets
                                                              .only(
                                                              left: 12,
                                                              top: 5,
                                                              right: 5,
                                                              bottom: 5),
                                                          child: Text(
                                                            'x Margin(%)',
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
                                                              controller: productSingleMargin,
                                                              labelText: '',
                                                              validator: (
                                                                  value) {
                                                                if (value ==
                                                                    null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return "Please enter margin value.";
                                                                } else {
                                                                  return null;
                                                                }
                                                              }
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
                                                          padding: EdgeInsets
                                                              .only(
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
                                                      if(selectedSellingPriceTaxType
                                                          .toLowerCase() ==
                                                          "exclusive")
                                                        Padding(
                                                            padding: const EdgeInsets
                                                                .all(16),
                                                            child: allComponents
                                                                .buildTextFormField(
                                                                controller: productSingleSPExcTax,
                                                                labelText: 'Exc. Tax',
                                                                validator: (
                                                                    value) {
                                                                  if (value ==
                                                                      null ||
                                                                      value
                                                                          .isEmpty) {
                                                                    return "Please enter product selling price (Exc. Tax).";
                                                                  } else {
                                                                    return null;
                                                                  }
                                                                }
                                                            )
                                                        ),
                                                      if(selectedSellingPriceTaxType
                                                          .toLowerCase() ==
                                                          "inclusive")
                                                        Padding(
                                                            padding: const EdgeInsets
                                                                .all(16),
                                                            child: allComponents
                                                                .buildTextFormField(
                                                                controller: productSingleSPIncTax,
                                                                labelText: 'Inc. Tax',
                                                                validator: (
                                                                    value) {
                                                                  if (value ==
                                                                      null ||
                                                                      value
                                                                          .isEmpty) {
                                                                    return "Please enter product selling price (Inc. Tax).";
                                                                  } else {
                                                                    return null;
                                                                  }
                                                                }
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
                                                          padding: EdgeInsets
                                                              .only(
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
                                                                  return Stack(
                                                                      children: [
                                                                        Container(
                                                                            margin: const EdgeInsets
                                                                                .only(
                                                                                top: 16),
                                                                            alignment: Alignment
                                                                                .center,
                                                                            width: MediaQuery
                                                                                .of(
                                                                                context)
                                                                                .size
                                                                                .width,
                                                                            height: imagePickerSize,
                                                                            decoration: BoxDecoration(
                                                                              border: Border
                                                                                  .all(
                                                                                color: const Color(
                                                                                    0xffa1a0a1),
                                                                                width: 1, // 20-pixel border
                                                                              ),
                                                                              borderRadius: BorderRadius
                                                                                  .circular(
                                                                                  5),
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets
                                                                                  .all(
                                                                                  16),
                                                                              child: Image
                                                                                  .file(
                                                                                  File(
                                                                                      images[index]
                                                                                          .path),
                                                                                  fit: BoxFit
                                                                                      .cover),
                                                                            )
                                                                        ),
                                                                        Positioned(
                                                                          top: 26,
                                                                          right: 10,
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              removeProductImages(
                                                                                  index);
                                                                            },
                                                                            child: const Column(
                                                                                children: <
                                                                                    Widget>[
                                                                                  Icon(
                                                                                      Icons
                                                                                          .cancel,
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
                                                                            onTap: () async {
                                                                              await updateProductImages(
                                                                                  index);
                                                                            },
                                                                            child: const Column(
                                                                                children: <
                                                                                    Widget>[
                                                                                  Icon(
                                                                                      Icons
                                                                                          .border_color,
                                                                                      color: Colors
                                                                                          .blueAccent,
                                                                                      size: 45)
                                                                                ]
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ]
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
                                if(selectedProductType.toLowerCase() == 'variable')
                                  Column(children: [
                                    allComponents.buildResponsiveWidget(
                                        Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    const Text(
                                                        'Add Variation:*',
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: FontWeight
                                                                .bold)
                                                    ),
                                                    const SizedBox(width: 16),
                                                    OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      ProductVar(
                                                                          addProd: addVarsProduct,
                                                                          taxVal: selectedTaxValue,
                                                                          taxType: selectedSellingPriceTaxType)));
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          padding: const EdgeInsets
                                                              .all(0),
                                                          textStyle: buttonTextStyle,
                                                          foregroundColor: Colors
                                                              .white,
                                                          backgroundColor: const Color(
                                                              0xff1572e8),
                                                          shadowColor: Colors
                                                              .yellow,
                                                          side: const BorderSide(
                                                              color: Color(
                                                                  0xffE0E3E7)),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(12),
                                                          ),
                                                        ),
                                                        child: const Row(
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .all(4),
                                                                  child: Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 50)
                                                              )
                                                            ]
                                                        ) // Set a tooltip for long-press
                                                    ),
                                                  ]
                                              )
                                            ]
                                        ),
                                        context
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          FormField<bool>(
                                              builder: (state) {
                                                return Column(
                                                  children: [
                                                    const SizedBox(),
                                                    if(state.errorText != null)
                                                      Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 24),
                                                          child: Text(
                                                              state.errorText!,
                                                              style: TextStyle(
                                                                  color: Theme
                                                                      .of(
                                                                      context)
                                                                      .colorScheme
                                                                      .error
                                                              )
                                                          )
                                                      )
                                                  ],
                                                );
                                              },
                                              validator: (value) {
                                                if (varsProducts.isEmpty) {
                                                  return "Please add variation for your product.";
                                                } else {
                                                  return null;
                                                }
                                              })
                                        ]),
                                    const SizedBox(height: 16.0),
                                    Table(
                                        border: TableBorder.all(),
                                        columnWidths: const <
                                            int,
                                            TableColumnWidth>{
                                          0: IntrinsicColumnWidth(),
                                          1: IntrinsicColumnWidth(),
                                          2: FlexColumnWidth(),
                                          3: IntrinsicColumnWidth(),
                                          4: IntrinsicColumnWidth(),
                                          5: IntrinsicColumnWidth(),
                                          6: IntrinsicColumnWidth(),
                                        },
                                        defaultVerticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        children: <TableRow>[
                                          TableRow(
                                            children: <Widget>[
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 28,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('SKU',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 28,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('Value',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 54,
                                                  child: Column(
                                                      children: [
                                                        const Center(
                                                            child: Text(
                                                                'Default Purchase Price',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .bold)
                                                            )),
                                                        const SizedBox(
                                                            height: 5.0),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              const Flexible(
                                                                  child: Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          left: 10),
                                                                      child: Text(
                                                                          ' Exc. tax',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold)
                                                                      )
                                                                  )
                                                              ),
                                                              Container(
                                                                width: 1,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              const Flexible(
                                                                  child: Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          right: 10),
                                                                      child: Text(
                                                                          'Inc. tax ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold)
                                                                      )
                                                                  )
                                                              )
                                                            ]
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 64,
                                                    width: 90,
                                                    child: Center(
                                                        child: Text(
                                                            'x Margin(%)',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 64,
                                                    width: 110,
                                                    child: Center(
                                                        child: Text(
                                                            ' Default Selling \n Price \n ${(selectedSellingPriceTaxType
                                                                .toLowerCase() ==
                                                                "inclusive"
                                                                ? "Inc."
                                                                : "Exc.")} Tax',
                                                            style: const TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 64,
                                                    width: 70,
                                                    child: Center(
                                                        child: Text('Images',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    width: 80,
                                                  )
                                              ),
                                            ],
                                          )
                                        ]),

                                    ...varsProducts
                                        .asMap()
                                        .entries
                                        .expand((entryVal) {
                                      int mainIndex = entryVal.key;
                                      List<
                                          ProductVariations> mainEntry = entryVal
                                          .value.productVariations;

                                      List<TableRow> rows = [];

                                      var mtr = TableRow(
                                          decoration: const BoxDecoration(
                                            // color: Colors.light,
                                          ),
                                          children: <Widget>[
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 60,
                                                child: Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        left: 16),
                                                    child: Text(
                                                      entryVal.value.name,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold),)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 60,
                                                width: 79,
                                                child: Center(
                                                    child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(left: 5,
                                                            top: 0,
                                                            right: 5,
                                                            bottom: 0),
                                                        child: OutlinedButton(
                                                            onPressed: () async {
                                                              await showDialog(
                                                                  context: context,
                                                                  barrierDismissible: false,
                                                                  builder: (
                                                                      BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Add Variation'),
                                                                      content: VariationItem(
                                                                          taxVal: selectedTaxValue,
                                                                          taxType: selectedSellingPriceTaxType,
                                                                          prodVarName: entryVal
                                                                              .value
                                                                              .name,
                                                                          mainIndex: mainIndex,
                                                                          subIndex: 0,
                                                                          isUpdate: false,
                                                                          addSubProd: addSubVarsProduct,
                                                                          isTablet: isTablet),
                                                                    );
                                                                  });
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              padding: const EdgeInsets
                                                                  .all(0),
                                                              textStyle: buttonTextStyle,
                                                              foregroundColor: Colors
                                                                  .white,
                                                              backgroundColor: const Color(
                                                                  0xff1572e8),
                                                              shadowColor: Colors
                                                                  .yellow,
                                                              side: const BorderSide(
                                                                  color: Color(
                                                                      0xffE0E3E7)),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    12),
                                                              ),
                                                            ),
                                                            child: const Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          top: 2,
                                                                          bottom: 2,
                                                                          left: 2,
                                                                          right: 2
                                                                      ),
                                                                      child: Icon(
                                                                          Icons
                                                                              .add,
                                                                          color: Colors
                                                                              .white,
                                                                          size: 45
                                                                      )
                                                                  )
                                                                ]
                                                            ) // Set a tooltip for long-press
                                                        )
                                                    )
                                                ),
                                              ),
                                            )
                                          ]
                                      );

                                      Table mainTable = Table(
                                          border: TableBorder.symmetric(
                                              inside: const BorderSide(
                                                  color: Colors.black)),
                                          columnWidths: const <int,
                                              TableColumnWidth>{
                                            0: FlexColumnWidth(),
                                            1: IntrinsicColumnWidth(),
                                          },
                                          defaultVerticalAlignment: TableCellVerticalAlignment
                                              .middle, children: [mtr]
                                      );

                                      Container mainContainer = Container(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                            )
                                        ),
                                        child: mainTable,
                                      );

                                      for (var subEntry in mainEntry
                                          .asMap()
                                          .entries) {
                                        int index = subEntry.key;
                                        ProductVariations entry = subEntry
                                            .value;

                                        var tr = TableRow(
                                          decoration: const BoxDecoration(
                                            // color: Colors.light,
                                          ),
                                          children: <Widget>[
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 90,
                                                width: 128,
                                                child: Center(
                                                    child: Text(entry.sku)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 32,
                                                width: 128,
                                                child: Center(
                                                    child: Text(entry.value)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                          child: Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                              child: Text(
                                                                  '${entry
                                                                      .defaultPurchasePriceExcTax}')
                                                          )
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        color: Colors.black,
                                                      ),
                                                      Flexible(
                                                          child: Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  right: 10),
                                                              child: Text(
                                                                  '${entry
                                                                      .defaultPurchasePriceIncTax}'
                                                              )
                                                          )
                                                      )
                                                    ]
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                width: 90,
                                                child: Center(child: Text(
                                                    '${entry.xMargin}')),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                width: 110,
                                                child: Center(
                                                    child: Text(
                                                        '${(selectedSellingPriceTaxType
                                                            .toLowerCase() ==
                                                            "inclusive"
                                                            ? entry
                                                            .defaultSellingPriceIncTax
                                                            : entry
                                                            .defaultSellingPriceExcTax)}')),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                width: 70,
                                                child: Center(
                                                    child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(left: 8,
                                                            top: 8,
                                                            right: 8,
                                                            bottom: 8),
                                                        child: OutlinedButton(
                                                            onPressed: () async {
                                                              await showDialog(
                                                                  context: context,
                                                                  barrierDismissible: false,
                                                                  builder: (
                                                                      BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Variation - (${entry
                                                                              .sku} - ${entry
                                                                              .value}) - Images'),
                                                                      content: VariationImgsGallery(
                                                                          images: entry
                                                                              .images,
                                                                          isTablet: isTablet),
                                                                    );
                                                                  });
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              padding: const EdgeInsets
                                                                  .all(0),
                                                              textStyle: buttonTextStyle,
                                                              foregroundColor: Colors
                                                                  .white,
                                                              backgroundColor: const Color(
                                                                  0xff1572e8),
                                                              shadowColor: Colors
                                                                  .yellow,
                                                              side: const BorderSide(
                                                                  color: Color(
                                                                      0xffE0E3E7)),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    12),
                                                              ),
                                                            ),
                                                            child: const Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          top: 7,
                                                                          bottom: 7,
                                                                          left: 2,
                                                                          right: 2
                                                                      ),
                                                                      child: Icon(
                                                                          Icons
                                                                              .image,
                                                                          color: Colors
                                                                              .white,
                                                                          size: 35
                                                                      )
                                                                  )
                                                                ]
                                                            ) // Set a tooltip for long-press
                                                        ))),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                  height: 95,
                                                  width: 80,
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                          height: 5.0),
                                                      InkWell(
                                                        onTap: () async {
                                                          await showDialog(
                                                              context: context,
                                                              barrierDismissible: false,
                                                              builder: (
                                                                  BuildContext context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Update Variation'),
                                                                  content: VariationItem(
                                                                      prodVar: entry,
                                                                      taxVal: selectedTaxValue,
                                                                      taxType: selectedSellingPriceTaxType,
                                                                      prodVarName: entryVal
                                                                          .value
                                                                          .name,
                                                                      mainIndex: mainIndex,
                                                                      subIndex: index,
                                                                      isUpdate: true,
                                                                      updateSubProd: updateSubVarsProduct,
                                                                      isTablet: isTablet
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        child: const Column(
                                                            children: <
                                                                Widget>[
                                                              Icon(
                                                                  Icons
                                                                      .border_color,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  size: 40)
                                                            ]
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      InkWell(
                                                        onTap: () {
                                                          deleteVarItem(
                                                              mainIndex, index);
                                                        },
                                                        child: const Column(
                                                            children: <
                                                                Widget>[
                                                              Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 40)
                                                            ]
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                    ],
                                                  )
                                              ),
                                            ),
                                          ],
                                        );

                                        rows.add(tr);
                                      }

                                      Table subTable = Table(
                                          border: TableBorder.all(),
                                          columnWidths: const <int,
                                              TableColumnWidth>{
                                            0: IntrinsicColumnWidth(),
                                            1: IntrinsicColumnWidth(),
                                            2: FlexColumnWidth(),
                                            3: IntrinsicColumnWidth(),
                                            4: IntrinsicColumnWidth(),
                                            5: IntrinsicColumnWidth(),
                                            6: IntrinsicColumnWidth(),
                                          },
                                          defaultVerticalAlignment: TableCellVerticalAlignment
                                              .middle,
                                          children: rows);

                                      return [mainContainer, subTable];
                                    },
                                    ),
                                  ],
                                  ),
                                if(selectedProductType.toLowerCase() == 'combo')
                                  Column(children: [
                                    allComponents.buildResponsiveWidget(
                                        Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    const Text(
                                                        'Add Combo Product:*',
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: FontWeight
                                                                .bold)
                                                    ),
                                                    const SizedBox(width: 16),
                                                    OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      ProductCmb(
                                                                          addProd: addComboProduct)));
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          padding: const EdgeInsets
                                                              .all(0),
                                                          textStyle: buttonTextStyle,
                                                          foregroundColor: Colors
                                                              .white,
                                                          backgroundColor: const Color(
                                                              0xff1572e8),
                                                          shadowColor: Colors
                                                              .yellow,
                                                          side: const BorderSide(
                                                              color: Color(
                                                                  0xffE0E3E7)),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(12),
                                                          ),
                                                        ),
                                                        child: const Row(
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .all(4),
                                                                  child: Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 50)
                                                              )
                                                            ]
                                                        ) // Set a tooltip for long-press
                                                    ),
                                                  ]
                                              )
                                            ]
                                        ),
                                        context
                                    ),
                                    const SizedBox(height: 16.0),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          FormField<bool>(
                                              builder: (state) {
                                                return Column(
                                                  children: [
                                                    const SizedBox(),
                                                    if(state.errorText != null)
                                                      Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 24),
                                                          child: Text(
                                                              state.errorText!,
                                                              style: TextStyle(
                                                                  color: Theme
                                                                      .of(
                                                                      context)
                                                                      .colorScheme
                                                                      .error
                                                              )
                                                          )
                                                      )
                                                  ],
                                                );
                                              },
                                              validator: (value) {
                                                if (comboProducts.isEmpty) {
                                                  return "Please add combo product for your product.";
                                                } else {
                                                  return null;
                                                }
                                              })
                                        ]),
                                    const SizedBox(height: 16.0),
                                    Table(
                                        border: TableBorder.all(),
                                        columnWidths: const <
                                            int,
                                            TableColumnWidth>{
                                          0: FlexColumnWidth(),
                                          1: IntrinsicColumnWidth(),
                                          2: IntrinsicColumnWidth(),
                                          3: IntrinsicColumnWidth(),
                                          4: IntrinsicColumnWidth(),
                                        },
                                        defaultVerticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        children: <TableRow>[
                                          const TableRow(
                                            children: <Widget>[
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 65,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text(
                                                            'Product Name',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 65,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('Quantity',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 65,
                                                  width: 120,
                                                  child: Center(
                                                      child: Text(
                                                          'Purchase Price \n(Excluding Tax)',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight
                                                                  .bold
                                                          )
                                                      )
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 65,
                                                    width: 90,
                                                    child: Center(
                                                        child: Text(
                                                            'Total Amount \n(Exc. Tax)',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 65,
                                                  width: 80,
                                                  child: Column(
                                                      children: [
                                                        SizedBox(height: 5),
                                                        Icon(
                                                            Icons.border_color,
                                                            color: Colors.grey,
                                                            size: 25
                                                        ),
                                                        SizedBox(height: 5),
                                                        Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.grey,
                                                            size: 25
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          ...comboProducts
                                              .asMap()
                                              .entries
                                              .map((entryVal) {
                                            int index = entryVal.key;
                                            var entry = entryVal.value;

                                            var tr = TableRow(
                                              decoration: const BoxDecoration(
                                                // color: Colors.light,
                                              ),
                                              children: <Widget>[
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text(
                                                            entry.prodName)),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('${entry
                                                            .qty} \n${entry
                                                            .unitName}')),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 120,
                                                    child: Center(
                                                        child: Text('${entry
                                                            .defaultPurchasePriceExcTax}')
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 110,
                                                    child: Center(
                                                        child: Text(
                                                            '${(entry.qty *
                                                                entry
                                                                    .defaultPurchasePriceExcTax)}')),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                      height: 95,
                                                      width: 80,
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 5.0),
                                                          InkWell(
                                                            onTap: () async {
                                                              await showDialog(
                                                                  context: context,
                                                                  barrierDismissible: false,
                                                                  builder: (
                                                                      BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Update Combo'),
                                                                      content: ComboItem(
                                                                          prodCombo: entry,
                                                                          index: index,
                                                                          updateComboProd: updateComboProd,
                                                                          isTablet: isTablet
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                      Icons
                                                                          .border_color,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 40)
                                                                ]
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5.0),
                                                          InkWell(
                                                            onTap: () {
                                                              removeComboProduct(
                                                                  index);
                                                            },
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 40)
                                                                ]
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5.0),
                                                        ],
                                                      )
                                                  ),
                                                ),
                                              ],
                                            );

                                            return tr;
                                          }),
                                          TableRow(
                                            decoration: const BoxDecoration(
                                              // color: Colors.light,
                                            ),
                                            children: <Widget>[
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(),
                                              ),
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 95,
                                                  width: 130,
                                                  child: Center(
                                                      child: Text(
                                                          'Net Total Amount :',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight
                                                                  .bold))),
                                                ),
                                              ),
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(),
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 95,
                                                  width: 110,
                                                  child: Center(
                                                      child: Text(
                                                          '$comboILPPTotalExcTax',
                                                          style: const TextStyle(
                                                              fontWeight: FontWeight
                                                                  .bold))),
                                                ),
                                              ),
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(),
                                              ),
                                            ],
                                          )
                                        ]
                                    ),
                                    const SizedBox(height: 16.0),
                                    allComponents.buildResponsiveWidget(
                                        Column(
                                            children: [
                                              allComponents.buildTextFormField(
                                                  controller: comboMrgn,
                                                  labelText: 'x Margin(%):',
                                                  onChanged: (String value) {
                                                    double itemLevelPurchasePriceTotal = 0;
                                                    double purchasePriceIncTax = 0;

                                                    itemLevelPurchasePriceTotal =
                                                        comboProducts.map((e) =>
                                                        (e
                                                            .defaultPurchasePriceExcTax *
                                                            e.qty)).reduce((a,
                                                            b) => (a + b));

                                                    purchasePriceIncTax =
                                                        addPercent(
                                                            amount: itemLevelPurchasePriceTotal,
                                                            percentage: selectedTaxValue);

                                                    // __currency_convert_recursively($(".combo_product_table_footer").find('tr'));

                                                    //Set selling price.
                                                    double margin = double
                                                        .parse(value.isNotEmpty
                                                        ? value
                                                        : "0");
                                                    var sellingPrice = addPercent(
                                                        amount: itemLevelPurchasePriceTotal,
                                                        percentage: margin);
                                                    var sellingPriceIncTax = addPercent(
                                                        amount: sellingPrice,
                                                        percentage: selectedTaxValue);

                                                    comboDSP.text =
                                                        sellingPrice.toString();
                                                    // __write_number($('input#selling_price_inc_tax'), selling_price_inc_tax);

                                                  }
                                              ),
                                              allComponents.buildTextFormField(
                                                  labelText: 'Default Selling Price:',
                                                  controller: comboDSP,
                                                  onChanged: (String value) {
                                                    var amount = double.parse(
                                                        value.isNotEmpty
                                                            ? value
                                                            : "0");

                                                    var margin = getRate(
                                                        principal: comboILPPTotalExcTax,
                                                        amount: amount);

                                                    comboMrgn.text =
                                                        margin.toString();

                                                    // var sellingPriceIncTax = addPercent(amount:amount, percentage:selectedTaxValue);

                                                  }
                                              )
                                            ]
                                        ),
                                        context
                                    ),
                                  ]),
                                const SizedBox(height: 16.0),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {

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
                                                Text(' Save ')
                                              ]
                                          )
                                      ),

                                    ]
                                ),
                                const SizedBox(height: 16.0),
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
              )
          );
        }
    );
  }
}

class VariationImgsGallery extends StatefulWidget {
  final List<XFile>? images;
  final bool? isTablet;

  const VariationImgsGallery({Key? key, this.images, this.isTablet})
      : super(key: key);

  @override
  VariationImgsGalleryState createState() => VariationImgsGalleryState();
}

class VariationImgsGalleryState extends State<VariationImgsGallery> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = widget.isTablet ?? false;
    double imagePickerSize = isTablet ? 200 : 120;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: 3,
              ),
              itemCount: widget.images?.length,
              itemBuilder: (context,
                  index) {
                return Stack(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 16),
                          alignment: Alignment.center,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: imagePickerSize,
                          decoration: BoxDecoration(
                            border: Border
                                .all(
                              color: const Color(
                                  0xffa1a0a1),
                              width: 1, // 20-pixel border
                            ),
                            borderRadius: BorderRadius
                                .circular(
                                5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets
                                .all(
                                16),
                            child: Image.file(
                                File(
                                    widget.images![index].path
                                ),
                                fit: BoxFit.cover
                            ),
                          )
                      )
                    ]
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
    );
  }
}

class VariationItem extends StatefulWidget {
  final ProductVariations? prodVar;
  final double taxVal;
  final String taxType;
  final String prodVarName;
  final int mainIndex;
  final int subIndex;
  final bool isUpdate;
  final bool? isTablet;
  final Function(int mainIndex, ProductVariations products)? addSubProd;
  final Function(int mainIndex, int subIndex, ProductVariations products)? updateSubProd;

  const VariationItem({Key? key, this.prodVar, required this.taxVal, required this.taxType, required this.prodVarName,required this.mainIndex, required this.subIndex, required this.isUpdate, this.addSubProd, this.updateSubProd, this.isTablet})
      : super(key: key);

  @override
  VariationItemState createState() => VariationItemState();
}

class VariationItemState extends State<VariationItem> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AllComponents allComponents = AllComponents();
  late ProductVariations? ssVars = widget.prodVar;

  late TextEditingController skusCntrlr = TextEditingController(text: ssVars?.sku ?? "");
  late TextEditingController skusValCntrlr = TextEditingController(text: ssVars?.value ?? "");
  late TextEditingController ppExcTaxValCntrlr = TextEditingController(text: ssVars?.defaultPurchasePriceExcTax.toString());
  late TextEditingController ppIncTaxValCntrlr = TextEditingController(text: ssVars?.defaultPurchasePriceIncTax.toString());
  late TextEditingController mrgnValCntrlr = TextEditingController(text: ssVars?.xMargin.toString());
  late TextEditingController spExcTaxValCntrlr = TextEditingController(text: ssVars?.defaultSellingPriceExcTax.toString());
  late TextEditingController spIncTaxValCntrlr = TextEditingController(text: ssVars?.defaultSellingPriceIncTax.toString());

  List<XFile> images = <XFile>[];

  late List<XFile> files;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    images = ssVars?.images ?? [];

    if(mrgnValCntrlr.text.isEmpty){
      mrgnValCntrlr.text = erpGlobals['default_profit_percent'].toString();
    }

  }

  void removeProductImages(int index) {
    setState(() {
      images.removeAt(index);
    });
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

  updateProductImages(int index) async {

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        images[index] = pickedFile;
      });
    }

  }

  getPrinciple({double amount = 0, double percentage = 0, bool minus = false}) {
    var mul = 100 * amount;
    double sum = 1;

    if (minus) {
      sum = 100 - percentage;
    } else {
      sum = 100 + percentage;
    }

    return mul / sum;
  }

  getRate({double principal = 0, double amount = 0}) {
    double interest = amount - principal;
    double div = interest/ principal;
    return div * 100;
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = widget.isTablet ?? false;
    double imagePickerSize = isTablet ? 200 : 120;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
                key: formKey,
                child: Column(children: [

                  Column(
                      children: [

                        const SizedBox(height: 24),

                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  Text(
                                      'Variation Name: ${widget.prodVarName}',
                                      style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight
                                              .bold))

                                ]
                            ),
                            context
                        ),


                        const SizedBox(height: 12),
                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  allComponents.buildTextFormField(
                                      labelText: 'SKU: (keep it blank to automatically generate SKU)',
                                      controller: skusCntrlr
                                  ),

                                  allComponents.buildTextFormField(
                                    labelText: 'Value:',
                                    controller: skusValCntrlr,
                                    isReadOnly: ssVars != null && ssVars!.value.isNotEmpty,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'This field is required.';
                                      }
                                      return null;
                                    },
                                  )

                                ]
                            ),
                            context
                        ),

                        const SizedBox(height: 24),

                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  allComponents
                                      .buildTextFormField(
                                      labelText: 'Default Purchase Price (Exc. tax):',
                                      controller: ppExcTaxValCntrlr,
                                      validator: (value) {
                                        if (value ==
                                            null ||
                                            value
                                                .isEmpty) {
                                          return 'This field is required.';
                                        }
                                        return null;
                                      },
                                      onChanged: (String value) {
                                        setState(() {
                                          double dppet = double
                                              .parse(
                                              value
                                                  .isNotEmpty
                                                  ? value
                                                  : "0");

                                          double taxValue = widget
                                              .taxVal /
                                              100;

                                          double ppit = (dppet *
                                              taxValue) +
                                              dppet;

                                          ppIncTaxValCntrlr
                                              .text = ppit
                                              .toString();

                                          String mrgnTxtVal = mrgnValCntrlr
                                              .text;

                                          double marginVal = (double.parse(
                                              mrgnTxtVal.isNotEmpty
                                                  ? mrgnTxtVal
                                                  : "0") / 100);

                                          double dspet = (dppet * marginVal) +
                                              dppet;

                                          spExcTaxValCntrlr.text =
                                              dspet.toString();

                                          double dspit = (dspet * taxValue) +
                                              dspet;

                                          spIncTaxValCntrlr.text =
                                              dspit.toString();
                                        });
                                      }
                                  ),

                                  allComponents
                                      .buildTextFormField(
                                    labelText: 'Default Purchase Price (Inc. tax):',
                                    controller: ppIncTaxValCntrlr,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'This field is required.';
                                      }
                                      return null;
                                    },
                                  )

                                ]
                            ),
                            context
                        ),

                        const SizedBox(height: 24),

                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  allComponents
                                      .buildTextFormField(
                                    labelText: 'x Margin(%):',
                                    controller: mrgnValCntrlr,
                                    onChanged: (String value) {
                                      setState(() {
                                        String dppetTxt = ppExcTaxValCntrlr
                                            .text;

                                        double dppet = double.parse(
                                            dppetTxt.isNotEmpty
                                                ? dppetTxt
                                                : "0");

                                        double marginVal = (double.parse(
                                            value.isNotEmpty ? value : "0") /
                                            100);

                                        double dspet = (dppet * marginVal) +
                                            dppet;

                                        spExcTaxValCntrlr.text =
                                            dspet.toString();

                                        double taxVal = widget.taxVal / 100;

                                        double dspit = (dspet * taxVal) + dspet;

                                        spIncTaxValCntrlr.text =
                                            dspit.toString();
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'This field is required.';
                                      }
                                      return null;
                                    },
                                  ),

                                  if(widget.taxType.toLowerCase() ==
                                      "inclusive")
                                    allComponents
                                        .buildTextFormField(
                                        labelText: 'Default Selling Price (Inc. Tax):',
                                        controller: spIncTaxValCntrlr,
                                        validator: (value) {
                                          if (value ==
                                              null ||
                                              value
                                                  .isEmpty) {
                                            return 'This field is required.';
                                          }
                                          return null;
                                        },
                                        onChanged: (String value) {
                                          double sellingPriceIncTax = double
                                              .parse(
                                              value.isNotEmpty ? value : "0");

                                          var sellingPrice = getPrinciple(
                                              amount: sellingPriceIncTax,
                                              percentage: widget.taxVal);

                                          String dppetTxt = ppExcTaxValCntrlr
                                              .text;

                                          double purchaseExcTax = double.parse(
                                              dppetTxt.isNotEmpty
                                                  ? dppetTxt
                                                  : "0");

                                          var ppTxt = mrgnValCntrlr.text;

                                          double profitPercent = double.parse(
                                              ppTxt.isNotEmpty ? ppTxt : "0");

                                          if (purchaseExcTax == 0) {
                                            profitPercent = 0;
                                          } else {
                                            profitPercent = getRate(
                                                principal: purchaseExcTax,
                                                amount: sellingPrice);
                                          }

                                          setState(() {
                                            mrgnValCntrlr.text =
                                                (profitPercent).toString();
                                          });
                                        }
                                    ),

                                  if(widget.taxType.toLowerCase() ==
                                      "exclusive")
                                    allComponents
                                        .buildTextFormField(
                                        labelText: 'Default Selling Price (Exc. Tax):',
                                        controller: spExcTaxValCntrlr,
                                        validator: (value) {
                                          if (value ==
                                              null ||
                                              value
                                                  .isEmpty) {
                                            return 'This field is required.';
                                          }
                                          return null;
                                        },
                                        onChanged: (String value) {
                                          double sellingPrice = double.parse(
                                              value.isNotEmpty ? value : "0");

                                          // var sellingPrice = getPrinciple(amount: sellingPriceIncTax, percentage: widget.taxVal);

                                          String dppetTxt = ppExcTaxValCntrlr
                                              .text;

                                          double purchaseExcTax = double.parse(
                                              dppetTxt.isNotEmpty
                                                  ? dppetTxt
                                                  : "0");

                                          var ppTxt = mrgnValCntrlr.text;

                                          double profitPercent = double.parse(
                                              ppTxt.isNotEmpty ? ppTxt : "0");

                                          if (purchaseExcTax == 0) {
                                            profitPercent = 0;
                                          } else {
                                            profitPercent = getRate(
                                                principal: purchaseExcTax,
                                                amount: sellingPrice);
                                          }

                                          double taxVal = widget.taxVal / 100;

                                          var sellingPriceIncTax = ((sellingPrice *
                                              taxVal) + sellingPrice);

                                          setState(() {
                                            mrgnValCntrlr.text =
                                                (profitPercent).toString();
                                            spIncTaxValCntrlr.text =
                                                (sellingPriceIncTax).toString();
                                          });
                                        }
                                    )

                                ]
                            ),
                            context
                        ),

                        const SizedBox(height: 24),

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
                                  itemCount: images.length,
                                  itemBuilder: (context,
                                      index) {
                                    return Stack(
                                        children: [
                                          Container(
                                              margin: const EdgeInsets
                                                  .only(
                                                  top: 16),
                                              alignment: Alignment
                                                  .center,
                                              width: MediaQuery
                                                  .of(
                                                  context)
                                                  .size
                                                  .width,
                                              height: imagePickerSize,
                                              decoration: BoxDecoration(
                                                border: Border
                                                    .all(
                                                  color: const Color(
                                                      0xffa1a0a1),
                                                  width: 1, // 20-pixel border
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                    5),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .all(
                                                    16),
                                                child: Image
                                                    .file(
                                                    File(
                                                        images[index]
                                                            .path),
                                                    fit: BoxFit
                                                        .cover),
                                              )
                                          ),
                                          Positioned(
                                            top: 26,
                                            right: 10,
                                            child: InkWell(
                                              onTap: () {
                                                removeProductImages(
                                                    index);
                                              },
                                              child: const Column(
                                                  children: <
                                                      Widget>[
                                                    Icon(
                                                        Icons
                                                            .cancel,
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
                                              onTap: () async {
                                                await updateProductImages(
                                                    index);
                                              },
                                              child: const Column(
                                                  children: <
                                                      Widget>[
                                                    Icon(
                                                        Icons
                                                            .border_color,
                                                        color: Colors
                                                            .blueAccent,
                                                        size: 45)
                                                  ]
                                              ),
                                            ),
                                          )
                                        ]
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
                        ),

                        const SizedBox(height: 24),

                      ]
                  ),


                  const SizedBox(height: 24),

                ]
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {

                        var prod = ProductVariations(
                            widget.isUpdate ? widget.prodVar!.id : 0,
                            skusCntrlr.text,
                            skusValCntrlr.text,
                            double.parse(ppExcTaxValCntrlr.text),
                            double.parse(ppIncTaxValCntrlr.text),
                            double.parse(mrgnValCntrlr.text),
                            double.parse(spExcTaxValCntrlr.text),
                            double.parse(spIncTaxValCntrlr.text),
                            images);

                        if(widget.isUpdate) {
                          widget.updateSubProd!(widget.mainIndex, widget.subIndex, prod);
                        }else{
                          widget.addSubProd!(widget.mainIndex, prod);
                        }

                        Navigator.pop(context);
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
    );
  }
}

class ComboItem extends StatefulWidget {
  final ProductCombo prodCombo;
  final int index;
  final bool? isTablet;
  final Function(ProductCombo products, int index)? updateComboProd;

  const ComboItem({Key? key, required this.prodCombo, required this.index, this.updateComboProd, this.isTablet})
      : super(key: key);

  @override
  ComboItemState createState() => ComboItemState();
}

class ComboItemState extends State<ComboItem> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AllComponents allComponents = AllComponents();

  final TextEditingController qtyController = TextEditingController();
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
    prodId = widget.prodCombo.id;
    prodName = widget.prodCombo.prodName;
    prodQty = widget.prodCombo.qty;
    unitName = widget.prodCombo.unitName;
    unitId = widget.prodCombo.unitId;
    defaultPurchasePriceExcTax = widget.prodCombo.defaultPurchasePriceExcTax;
    defaultPurchasePriceIncTax = widget.prodCombo.defaultPurchasePriceIncTax;
    defaultSellingPriceExcTax = widget.prodCombo.defaultSellingPriceExcTax;
    defaultSellingPriceIncTax = widget.prodCombo.defaultSellingPriceIncTax;
    qtyController.text = "$prodQty";
  }

  getPrinciple({double amount = 0, double percentage = 0, bool minus = false}) {
    var mul = 100 * amount;
    double sum = 1;

    if (minus) {
      sum = 100 - percentage;
    } else {
      sum = 100 + percentage;
    }

    return mul / sum;
  }

  getRate({double principal = 0, double amount = 0}) {
    double interest = amount - principal;
    double div = interest/ principal;
    return div * 100;
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
                key: formKey,
                child: Column(children: [

                  Column(
                      children: [

                        const SizedBox(height: 24),

                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  Text(
                                      'Variation Name: $prodName',
                                      style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight
                                              .bold))

                                ]
                            ),
                            context
                        ),


                        const SizedBox(height: 12),
                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  allComponents.buildTextFormField(
                                      controller: qtyController,
                                      labelText: 'Quantity:*',
                                      onChanged: (String value){
                                        setState(() {
                                          prodQty = double.parse(value.isNotEmpty ? value : "0");
                                          // totalPurchasePriceExcTax = prodQty * defaultPurchasePriceExcTax;
                                        });
                                      }
                                  ),
                                  SelectionContainer.disabled(child: Row(
                                      children: [
                                        const Text('Unit :', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Text(' $unitName', style: const TextStyle(fontSize: 22))
                                      ]
                                  )),
                                ]
                            ),
                            context
                        ),

                        const SizedBox(height: 24),

                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  SelectionContainer.disabled(child: Column(
                                      children: [
                                        const Text('Purchase Price (Excluding Tax)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Text(' ${erpGlobals['currency']['symbol']} $defaultPurchasePriceExcTax', style: const TextStyle(fontSize: 22))
                                      ])
                                  ),
                                  SelectionContainer.disabled(child: Column(
                                      children: [
                                        const Text('Total Amount (Exc. Tax)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Text(' ${erpGlobals['currency']['symbol']} ${(defaultPurchasePriceExcTax * prodQty)}', style: const TextStyle(fontSize: 22))
                                      ])
                                  )
                                ]
                            ),
                            context
                        ),
                        const SizedBox(height: 24),
                      ]
                  ),

                  const SizedBox(height: 24),

                ])
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  ElevatedButton(
                    onPressed: () {
                      if(prodId > 0 && prodName.isNotEmpty) {
                        singleProduct = ProductCombo(prodId, prodName, prodQty, unitName, unitId, defaultPurchasePriceExcTax, totalPurchasePriceExcTax, defaultPurchasePriceIncTax, defaultSellingPriceExcTax, defaultSellingPriceIncTax);
                        widget.updateComboProd!(singleProduct, widget.index);
                        Navigator.pop(context);
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
    );
  }
}
