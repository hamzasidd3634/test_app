import 'package:flutter/cupertino.dart';
import 'package:pdf_viewer/Model/pdf_files.dart';
import 'package:pdf_viewer/provider/pdf_listing.dart';

class LocalDbProvider with ChangeNotifier {
  List<PDFFiles> pdfListing = new List();
  bool loading = false;

  recentPDFS() async {
    loading = true;
    pdfListing = await fetchPDF();
    loading = false;
    notifyListeners();


  }
}