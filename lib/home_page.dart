import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:pdf_viewer/customization/custom_card.dart';
import 'package:pdf_viewer/provider/pdf_provider.dart';
import 'package:pdf_viewer/provider/localdb_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unicorndial/unicorndial.dart';
import 'Model/pdf_files.dart';
import 'database/db.dart';
import 'package:pdf_viewer/global/global_variables.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const platform = const MethodChannel('it.hamza/pdfViewer');

  TabController tabController;
  List<PDFFiles> pdfFiles = new List();
  List<PDFFiles> recent = new List();
  PdfDbProvider dbPDF = PdfDbProvider();
  Directory rootPath;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    final provider = Provider.of<PDFProvider>(context, listen: false);
    provider.allPDFS(context);
    final provider1 = Provider.of<LocalDbProvider>(context, listen: false);
    provider1.recentPDFS();

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.index != tabController.previousIndex) setState(() {});
    });
  }

  addItem(PDFFiles item) async {
    item.changedDate = DateTime.now().toLocal().toString();
    final db = await dbPDF.init();
    if (GlobalVariables.globalList.length != 0) {
      for (int i = 0; i < GlobalVariables.globalList.length; i++) {
        if (GlobalVariables.globalList[i].path == item.path) {
          return await db.update("PDF", item.toMap(),
              where: "id = ?", whereArgs: [GlobalVariables.globalList[i].id]);
        } else {
          if (i == GlobalVariables.globalList.length - 1) {
            return db.insert(
              "PDF",
              item.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
          continue;
        }
      }
    } else {
      return db.insert(
        "PDF",
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
    } else {
      print(state.toString());
    }
  }

  Widget list(var provider) {
    // provider.pdfListing = provider.pdfListing.toList()
    //   ..sort((a, b) => DateTime.parse(b.changedDate)
    //       .millisecondsSinceEpoch
    //       .compareTo(DateTime.parse(a.changedDate).millisecondsSinceEpoch));
    return GroupedListView<PDFFiles, DateTime>(
        elements: provider.pdfListing,
        physics: AlwaysScrollableScrollPhysics(),
        order: GroupedListOrder.ASC,
        floatingHeader: true,
        itemComparator: (item1, item2) => DateTime.parse(item2.changedDate).millisecondsSinceEpoch.compareTo(DateTime.parse(item1.changedDate).millisecondsSinceEpoch),
        groupBy: (PDFFiles pdfFiles) {
          var dates = DateTime.parse(pdfFiles.changedDate);
          return DateTime(
            dates.year,
            dates.month,
            dates.day,
          );
        },
        groupHeaderBuilder: (PDFFiles element) {
          var dates = DateTime.parse(element.changedDate);

          return Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${DateFormat.yMMMd().format(dates)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, color: Colors.black, fontFamily: "Manjari"),
                ),
              ),
            ),
          );
        },
        itemBuilder: (context, dynamic element) {
          var sizes = double.parse(element.size) / 1024;
          var a = sizes.toString().split(".");
          var size = a[0] + "." + a[1].substring(0, 1);

          if (controller.text.isEmpty) {
            return invoke(element, size, context, 0);
          } else {
            if (element.name
                .toString()
                .toLowerCase()
                .contains(controller.text)) {
              return invoke(element, size, context, 0);
            }
          }
          return Container();
        });
  }

  Widget invoke(var element, var size, context, int listIndex) {
    return InkWell(
      onTap: () {
        addItem(element);
        final provider1 = Provider.of<LocalDbProvider>(context, listen: false);
        provider1.recentPDFS();
        var args = {'url': element.path};
        platform.invokeMethod('viewPdf', args);
      },
      child: Customs().card(element, size, context, listIndex),
    );
  }

  Widget allList(var provider) {
    return ListView.builder(
        itemCount: provider.pdfListing.length,
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          var sizes = double.parse(provider.pdfListing[index].size) / 1024;
          var a = sizes.toString().split(".");
          var size = a[0] + "." + a[1].substring(0, 1);

          if (controller.text.isEmpty) {
            return invoke(provider.pdfListing[index], size, context, 1);
          } else {
            if (provider.pdfListing[index].name
                .toString()
                .toLowerCase()
                .contains(controller.text)) {
              return invoke(provider.pdfListing[index], size, context, 1);
            }
            return Container();
          }
        });
  }

  Widget appBar() {
    return PreferredSize(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Color(0XFFF1E4164), Color(0XFFF2980B9)]),
            boxShadow: [
              new BoxShadow(
                color: Colors.grey[500],
                blurRadius: 20.0,
                spreadRadius: 1.0,
              )
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: new Container(
                child: Row(
                  children: [
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 20.0, bottom: 20.0),
                      child: new Text(
                        'My Files',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontFamily: "Manjari"),
                      ),
                    ),
                    Spacer(),
                    new Padding(
                      padding: const EdgeInsets.only(
                          right: 10.0, top: 20.0, bottom: 20.0),
                      child: new Image.asset("assets/threedot2.png"),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Center(
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Color(0XFFF297FB780),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                      controller: controller,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontFamily: "Manjari"),
                      decoration: InputDecoration(
                        prefixIcon: Image.asset("assets/search2.png"),
                        border: InputBorder.none,
                        hintText: "I'm looking for...",
                        hintStyle: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[400],
                            fontFamily: "Manjari"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.bottomCenter,
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: tabController.index == 0
                        ? BorderRadius.only(topRight: Radius.circular(35))
                        : BorderRadius.only(topLeft: Radius.circular(35)),
                    color: Color(0XFFF297FB780),
                  ),
                  // isScrollable: true,
                  labelPadding: EdgeInsets.only(left: 0, right: 0),
                  indicatorSize: TabBarIndicatorSize.label,
                  //  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  controller: tabController,
                  tabs: [
                    Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Tab(
                          child: Text(
                            "Recent",
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[100],
                                fontFamily: "Manjari"),
                          ),
                        )),
                    Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Tab(
                            child: Text(
                          "All Files",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[100],
                              fontFamily: "Manjari"),
                        ))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      preferredSize: new Size(MediaQuery.of(context).size.width, 180),
    );
  }

  filePicker() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;

      var args = {'url': file.path};
      platform.invokeMethod('viewPdf', args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PDFProvider>(context);
    final provider1 = Provider.of<LocalDbProvider>(context);
    GlobalVariables.globalList = provider1.pdfListing;

    return MaterialApp(
      //  navigatorKey: Catcher.navigatorKey,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: UnicornDialer(
            //  orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.add),


            childButtons: [
              UnicornButton(
                  labelText: "Add Files",
                  labelColor: Colors.white,
                  labelHasShadow: false,
                  currentButton: FloatingActionButton.extended(
                    onPressed: () => print('Unicorn BUTTON pressed'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    label: InkWell(
                      onTap: () {
                        filePicker();
                      },
                      child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text('Add Files',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Manjari")),
                          )),
                    ),
                  ),
                  labelBackgroundColor: Colors.white),
            ],
            backgroundColor: Colors.transparent,
          ),
          appBar: appBar(),
          body: provider1.loading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                )
              : Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        "assets/bg.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    TabBarView(
                      controller: tabController,
                      children: [
                        Container(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        1.5,
                                    child: list(provider1)),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        )),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Expanded(child: allList(provider)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
