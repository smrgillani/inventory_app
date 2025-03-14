import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';
import 'package:gs_erp/models/Product.dart';
import 'package:gs_erp/services/http.service.dart';

import 'manage_product.dart';


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {

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

  late QuillController _controller = QuillController.basic();

  final List<String> items = List<String>.generate(100, (i) => '$i');

  final List<ProductType> productTypes = [
    ProductType("Single", "single"),
    ProductType("Variable", "variable"),
    ProductType("Combo", "combo")
  ];

  late List<Product> products = [];

  bool showProductsList = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllProducts();
  }

  getAllProducts() async {
    products = [];
    dynamic response = await RestSerice().getData('/product?order_by=molestias&per_page=10');
    List<dynamic> productsList = (response['data'] as List).cast<dynamic>();

    for(var product in productsList){

      double totalQtys = 0;

      for(var vld in product['product_variations'][0]['variations'][0]['variation_location_details']){
        totalQtys += double.parse(vld['qty_available'] ?? "0");
      }

      ProductType prodType = productTypes.firstWhere((prodType) => prodType.value ==
          (product['type'] ?? ""),
          orElse: () => ProductType("", ""));

      String prodDescp = product['product_description'] ?? "";

      try {

        var delta = HtmlToDelta().convert(prodDescp);

        _controller = QuillController(
            document: Document.fromJson(delta.toJson()),
            selection: const TextSelection(baseOffset: 0, extentOffset: 0)
        );

      }catch(e){ print("Error: $e"); }

      prodDescp = _controller.document.toPlainText().replaceAll('\n', '');

      products.add(
          Product(
            productId: product['id'],
            productName: product['name'],
            productPurchasePriceIncTax: double.parse(product['product_variations'][0]['variations'][0]['dpp_inc_tax'].toString() ?? "0"),
            productSellPriceIncTax: double.parse(product['product_variations'][0]['variations'][0]['sell_price_inc_tax'].toString() ?? "0"),
            productStock: totalQtys,
            productType: prodType.name,
            productBusinessLocation : product['product_locations_short_details'].map((item)=> item['name']).join(', '),
            productDescription: prodDescp.isNotEmpty ? _controller.document.toPlainText().replaceAll('\n', ' ') : "",
            productUnit: "${(product['unit']['actual_name'] ?? "")}(${(product['unit']['short_name'] ?? "")})",
            productCategory: (product['category'] != null ? product['category']['name'] : ""),
            productBrand: (product['brand'] != null? product['brand']['name'] : ""),
            productWarranty: (product['warranty'] != null ? product['warranty']['name'] : ""),
            productTax: (product['product_tax'] != null ? "${product['product_tax']['name']}@${product['product_tax']['amount']}%" : ""),
          )
      );
    }

    setState(() {
      showProductsList = true;
    });

  }

  addProduct() async {
    Navigator.push(context,MaterialPageRoute(builder: (context) => const ManageProduct()));
  }

  deleteProduct(int id) async {

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
                dynamic response = await RestSerice().delData('/product/$id');
                await getAllProducts();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  editProduct(int id) async {
    Navigator.push(context,MaterialPageRoute(builder: (context) => ManageProduct(productId: id)));
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
                        Text('Products',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5, top: 7),
                            child: Text('Manage your products', style: TextStyle(
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
                              addProduct();
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
                  if(showProductsList)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (context, index) {
                            return getListItem(products[index]);
                            // return Container(
                            //   color: Colors.white,
                            //   child: ListTile(
                            //     leading: CircleAvatar(
                            //       backgroundColor: Colors.black,
                            //       foregroundColor: Colors.white,
                            //       child: Text((index + 1).toString()),
                            //     ),
                            //     title: Text(products[index].productName),
                            //     subtitle: Row(
                            //       children: [
                            //         const Text('Values : ', style: TextStyle(
                            //             fontWeight: FontWeight.bold)),
                            //         Text(products[index].productDescription ?? "")
                            //       ],
                            //     ),
                            //     trailing: PopupMenuButton<String>(
                            //       onSelected: (value) {
                            //         switch (value.toLowerCase()) {
                            //           case 'edit':
                            //             editProduct(products[index].productId);
                            //             break;
                            //           case 'delete':
                            //             deleteProduct(products[index].productId);
                            //             break;
                            //         }
                            //       },
                            //       itemBuilder: (BuildContext context) {
                            //         return ['Edit', 'Delete'].map((String e) {
                            //           return PopupMenuItem<String>(
                            //             value: e,
                            //             child: Text(e),
                            //           );
                            //         }).toList();
                            //       },
                            //     ),
                            //   ),
                            // );
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

  Widget getListItem(Product product){
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.productName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.blue),
                const SizedBox(width: 8),
                Text("Purchase: ${product.productPurchasePriceIncTax} - Sell: ${product.productSellPriceIncTax}")
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.inventory, color: Colors.blue),
                const SizedBox(width: 8),
                Text("Stock: ${product.productStock}")
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                Text("Product Type: ${product.productType}"),
                const SizedBox(width: 8),
                const Icon(Icons.business, color: Colors.blue),
                const SizedBox(width: 8),
                Text("Locations: ${product.productBusinessLocation}")
              ],
            ),
            const SizedBox(height: 8),
            if(product.productDescription!.isNotEmpty)
              Column(
                children: [
                  Text("${product.productDescription}"),
                  const SizedBox(height: 12),
                ],
              ),
            Wrap(
              spacing: 8,
              children: [
                if(product.productUnit!.isNotEmpty)
                  FilledButton(onPressed: (){}, child: Text("${product.productUnit}")),
                if(product.productCategory!.isNotEmpty)
                  FilledButton(onPressed: (){}, child: Text("${product.productCategory}")),
                if(product.productBrand!.isNotEmpty)
                  FilledButton(onPressed: (){}, child: Text("${product.productBrand}")),
                if(product.productWarranty!.isNotEmpty)
                  FilledButton(onPressed: (){}, child: Text("${product.productWarranty}")),
                if(product.productTax!.isNotEmpty)
                  FilledButton(onPressed: (){}, child: Text("${product.productTax}")),
              ],
            )
          ],
        )
    );
  }
}