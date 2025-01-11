
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gs_erp/brands.dart';
import 'package:gs_erp/categories.dart';
import 'package:gs_erp/main.dart';
import 'package:gs_erp/products.dart';
import 'package:gs_erp/sellingpricegroups.dart';
import 'package:gs_erp/tables.dart';
import 'package:gs_erp/taxrategroups.dart';
import 'package:gs_erp/taxrates.dart';
import 'package:gs_erp/units.dart';
import 'package:gs_erp/variations.dart';
import 'package:gs_erp/warranties.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/Global.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  // const Dashboard({super.key});

  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  late List<String> dates;

  bool showAvg = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchGlobalData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome User"),
          actions: [
            SizedBox(
                width: 40,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.zero,
                    fixedSize: const Size(20.0, 14.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.more_time, // Replace with your desired icon
                      size: 28.0, // Adjust icon size as needed
                      color: Colors.white, // Icon color
                    ),
                  ),
                )
            ),
            const SizedBox(width: 8.0),
            MenuAnchor(
              builder: (context, controller, child) {
                return SizedBox(
                    width: 40,
                    child: TextButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(20.0, 14.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_circle, // Replace with your desired icon
                          size: 28.0, // Adjust icon size as needed
                          color: Colors.white, // Icon color
                        ),
                      ),
                    )
                );
              },
              menuChildren: [
                MenuItemButton(
                  child: const Text('Add To Do'),
                  onPressed: () {},
                ),
                MenuItemButton(
                  child: const Text('Application Tour'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: () {
                // Handle button tap
              },
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.zero,
                  fixedSize: const Size(90.0, 30.0)
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.dashboard, // Replace with your desired icon
                      size: 25.0, // Adjust icon size as needed
                      color: Colors.white, // Icon color
                    ),
                    SizedBox(width: 8.0),
                    // Adjust the spacing between icon and text
                    Text(
                      'POS',
                      style: TextStyle(
                        fontSize: 18.0, // Adjust text size as needed
                        color: Colors.white, // Text color
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: () {
                // Handle button tap
              },
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.zero,
                  fixedSize: const Size(15.0, 14.0)
              ),
              child: const Center(
                child: Icon(
                  Icons.local_atm, // Replace with your desired icon
                  size: 35.0, // Adjust icon size as needed
                  color: Colors.white, // Icon color
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.notifications, size: 30),
              onPressed: () {
                // Handle search button press
              },
            ),
            const SizedBox(width: 16.0),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [

              CustomDrawerHeader(
                accountName: "John Doe",
                accountEmail: "johndoe@example.com",
                profileImagePath: "assets/profile_image.jpg",
                onLogout: () {
                  // Handle logout
                  print('Logging out...');
                },
              ),
              ListTile(
                title: const Text("Home"),
                onTap: () {
                  // Handle Home navigation
                },
              ),
              ExpansionTile(
                title: const Text("User Management"),
                children: <Widget>[
                  ListTile(
                    title: const Text("Users"),
                    onTap: () {
                      // Handle Sub-Menu Item 1 navigation
                    },
                  ),
                  ListTile(
                    title: const Text("Roles"),
                    onTap: () {
                      // Handle Sub-Menu Item 2 navigation
                    },
                  ),
                  // Add more sub-menu items as needed
                ],
              ),
              ExpansionTile(
                title: const Text("Contacts"),
                children: <Widget>[
                  ListTile(
                    title: const Text("Suppliers"),
                    onTap: () {
                      // Handle Sub-Menu Item 1 navigation
                    },
                  ),
                  ListTile(
                    title: const Text("Customers"),
                    onTap: () {
                      // Handle Sub-Menu Item 2 navigation
                    },
                  ),
                  // Add more sub-menu items as needed
                ],
              ),
              ExpansionTile(
                title: const Text("Products"),
                children: <Widget>[
                  ListTile(
                    title: const Text("Products"),
                    onTap: () {
                      // Handle Sub-Menu Item 1 navigation
                    },
                  ),
                  ListTile(
                    title: const Text("Add Product"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const AddProduct()));
                    },
                  ),
                  ListTile(
                    title: const Text("Variations"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const VariationScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Selling Price Group"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const PriceGroupScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Units"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const UnitsScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Categories"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const CategoriesScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Brands"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const BrandsScreen()));
                    },
                  ),ListTile(
                    title: const Text("Warranties"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const WarrantiesScreen()));
                    },
                  ),
                  // Add more sub-menu items as needed
                ],
              ),
              ExpansionTile(
                title: const Text("Purchases"),
                children: <Widget>[
                  ListTile(
                    title: const Text("Purchases"),
                    onTap: () {
                      // Handle Sub-Menu Item 1 navigation
                    },
                  ),
                  ListTile(
                    title: const Text("Add Purchase"),
                    onTap: () {
                      // Handle Sub-Menu Item 2 navigation
                    },
                  ),
                  ListTile(
                    title: const Text("Returned Purchases"),
                    onTap: () {
                      // Handle Sub-Menu Item 2 navigation
                    },
                  ),
                  // Add more sub-menu items as needed
                ],
              ),
              ExpansionTile(
                title: const Text("Settings"),
                children: <Widget>[
                  ListTile(
                    title: const Text("Tax Rates"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const TaxScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Tax Rates Groups"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const TaxGroupScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Tables"),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => const TableScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Returned Purchases"),
                    onTap: () {
                      // Handle Sub-Menu Item 2 navigation
                    },
                  ),
                  // Add more sub-menu items as needed
                ],
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Section("Welcome User"),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InfoBoxWidget(iconData: Icons.shopping_cart,
                              title: 'Total Sales',
                              value: '11,279.57'),
                          SizedBox(width: 16.0),
                          InfoBoxWidget(iconData: Icons.description,
                              title: 'Net Sales',
                              value: '8,642.39'),
                          SizedBox(width: 16.0),
                          InfoBoxWidget(iconData: Icons.pending,
                              title: 'Invoices Due',
                              value: '15,198.75'),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InfoBoxWidget(
                              iconData: Icons.swap_horizontal_circle_rounded,
                              title: 'Returned Sales',
                              value: '15,198.75'),
                          SizedBox(width: 16.0),
                          InfoBoxWidget(iconData: Icons.description,
                              title: 'Purchases',
                              value: '8,642.39'),
                          SizedBox(width: 16.0),
                          InfoBoxWidget(iconData: Icons.pending,
                              title: 'Purchases Due',
                              value: '15,198.75')
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InfoBoxWidget(
                              iconData: Icons.swap_horizontal_circle_rounded,
                              title: 'Returned Purchases',
                              value: '15,198.75'),
                          SizedBox(width: 16.0),
                          InfoBoxWidget(iconData: Icons.description,
                              title: 'Expenses',
                              value: '8,642.39'),
                        ],
                      ),
                    ]
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left:16, right: 16, bottom: 16),
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white, // Background color
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 0.5,
                            blurRadius: 20,
                            offset: const Offset(
                                0, 4), // Changes the shadow position
                          ),
                        ],
                      ),
                      child: Stack(
                        children: <Widget>[
                          const Padding(padding: EdgeInsets.all(12),
                            child: Text("Last 30 Days Sales", style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          AspectRatio(
                            aspectRatio: 1.70,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 18,
                                left: 12,
                                top: 60,
                                bottom: 25,
                              ),
                              child: LineChart(
                                mainData(),
                              ),
                            ),
                          )
                        ],
                      )
                  )
              ),
              Padding(
                  padding: const EdgeInsets.only(left:16, right: 16, bottom: 16),
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white, // Background color
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 0.5,
                            blurRadius: 20,
                            offset: const Offset(
                                0, 4), // Changes the shadow position
                          ),
                        ],
                      ),
                      child: Stack(
                        children: <Widget>[
                          const Padding(padding: EdgeInsets.all(12),
                            child: Text("Sales Current Financial Year", style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          AspectRatio(
                            aspectRatio: 1.70,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 40,
                                left: 12,
                                top: 60,
                                bottom: 25,
                              ),
                              child: LineChart(
                                financialYearData(),
                              ),
                            ),
                          )
                        ],
                      )
                  )
              )
            ],
          ),
        )
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    late Widget widget;

    widget = Center(
      child: Transform.rotate(
          angle: -45, // 45 degrees in radians
          child: Padding(
            padding: const EdgeInsets.only(right: 17),
            child: Text(
              '${value.toInt().toString()} Oct',
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
      ),
    );


    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: widget,
      // child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
      case 2000:
        text = '2K';
        break;
      case 4000:
        text = '4k';
        break;
      case 6000:
        text = '6k';
        break;
      case 8000:
        text = '8k';
        break;
      case 10000:
        text = '10k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget fyBottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    late Widget widget;

    widget = Text(
      '${value.toInt().toString()}-2023',
      style: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: widget,
      // child: text,
    );
  }

  Widget fyLeftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
      case 20:
        text = '20K';
        break;
      case 40:
        text = '40k';
        break;
      case 60:
        text = '60k';
        break;
      case 80:
        text = '80k';
        break;
      case 100:
        text = '100k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: 2000,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color.fromRGBO(230, 230, 230, 1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromRGBO(230, 230, 230, 1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: 30,
          axisNameWidget: const Text(
            'Total Sales (CAD)',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 29,
      minY: 0,
      maxY: 10001,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3000),
            FlSpot(1, 1500),
            FlSpot(2, 1400),
            FlSpot(3, 2000),
            FlSpot(4, 2100),
            FlSpot(5, 2200),
            FlSpot(6, 1900),
            FlSpot(7, 1800),
            FlSpot(8, 1700),
            FlSpot(9, 1600),
            FlSpot(10, 1700),
            FlSpot(11, 2500),
            FlSpot(12, 2300),
            FlSpot(13, 2800),
            FlSpot(14, 2900),
            FlSpot(15, 2850),
            FlSpot(16, 2750),
            FlSpot(17, 2460),
            FlSpot(18, 2410),
            FlSpot(19, 2490),
            FlSpot(20, 2390),
            FlSpot(21, 7000),
            FlSpot(22, 6390),
            FlSpot(23, 5390),
            FlSpot(24, 4390),
            FlSpot(25, 3390),
            FlSpot(26, 8390),
            FlSpot(27, 7390),
            FlSpot(28, 1390),
            FlSpot(29, 2390),
            // FlSpot(30, 2300),
            // FlSpot(8, 4),
            // FlSpot(9.5, 3),
            // FlSpot(11, 4),
          ],
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData financialYearData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color.fromRGBO(230, 230, 230, 1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromRGBO(230, 230, 230, 1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: fyBottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: 30,
          axisNameWidget: const Text(
            'Total Sales (CAD)',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: fyLeftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 101,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 81),
            FlSpot(1, 90),
            FlSpot(2, 75),
            FlSpot(3, 76),
            FlSpot(4, 65),
            FlSpot(5, 66),
            FlSpot(6, 56),
            FlSpot(7, 57),
            FlSpot(8, 48),
            FlSpot(9, 49),
            FlSpot(10, 40),
            FlSpot(11, 39),
          ],
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class InfoBoxWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData iconData;

  const InfoBoxWidget({super.key, required this.iconData, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white, // Background color
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0.5,
              blurRadius: 20,
              offset: const Offset(0, 4), // Changes the shadow position
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              padding: const EdgeInsets.all(10),
              child: Icon(
                iconData,
                size: 50.0,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                  style: const TextStyle(fontSize: 20.0),
                ),
                Text(
                  '\$ $value',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class Section extends StatelessWidget {
  final String title;

  Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Add your content for this section here
        ],
      ),
    );
  }
}

class CustomDrawerHeader extends StatelessWidget {
  final String accountName;
  final String accountEmail;
  final String profileImagePath;
  final VoidCallback onLogout;

  const CustomDrawerHeader({super.key,
    required this.accountName,
    required this.accountEmail,
    required this.profileImagePath,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: MaterialLocalizations
          .of(context)
          .signedInLabel,
      child: Container(
        height: 210,
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(color: Theme
            .of(context)
            .colorScheme
            .primary),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 0.0),
                  child: Column(
                    children: [
                      Semantics(
                        explicitChildNodes: true,
                        child: SizedBox.fromSize(
                          size: Size(80, 80),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                                'assets/images/error_illustration.jpg'),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: DefaultTextStyle(
                            style: Theme
                                .of(context)
                                .primaryTextTheme
                                .bodyLarge!,
                            overflow: TextOverflow.ellipsis,
                            child: const Text("UserName"),
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: DefaultTextStyle(
                            style: Theme
                                .of(context)
                                .primaryTextTheme
                                .bodyMedium!,
                            overflow: TextOverflow.ellipsis,
                            child: const Text("abc@yahoo.com"),
                          )
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(9),
                                    fixedSize: const Size(120, 32.5),
                                    textStyle: const TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.yellow,
                                    shape: const StadiumBorder()
                                ),
                                onPressed: () {},
                                child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(' Profile '),
                                      Icon(Icons.account_circle)
                                    ]
                                )
                            ),
                            const SizedBox(width: 16.0),
                            OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(9),
                                    fixedSize: const Size(120, 32.5),
                                    textStyle: const TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.yellow,
                                    shape: const StadiumBorder()
                                ),
                                onPressed: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  bool removeAuthToken = await prefs.clear();
                                  if(removeAuthToken) {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => const MyApp()));
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Unable to process logout'),
                                      ),
                                    );
                                  }
                                },
                                child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(' Logout '),
                                      Icon(Icons.logout)
                                    ]
                                )
                            )
                          ]
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}