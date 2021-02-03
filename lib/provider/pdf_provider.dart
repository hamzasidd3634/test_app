import 'package:flutter/cupertino.dart';
import 'package:pdf_viewer/Model/pdf_files.dart';
import 'package:pdf_viewer/provider/pdf_listing.dart';

class PDFProvider with ChangeNotifier {
  List<PDFFiles> pdfListing = new List();
  bool loading = false;

  allPDFS(context) async {
    loading = true;
    pdfListing = await data(context);
    loading = false;
    notifyListeners();


  }
}