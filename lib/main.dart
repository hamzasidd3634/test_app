import 'package:flutter/material.dart';
import 'package:pdf_viewer/home_page.dart';
import 'package:pdf_viewer/provider/pdf_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
 WidgetsFlutterBinding.ensureInitialized();


  runApp(MyApp());
}

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<PDFProvider>(create: (_) => PDFProvider()),
];
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}

