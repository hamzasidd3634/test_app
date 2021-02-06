import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:mime/mime.dart';
import 'package:pdf_viewer/Model/pdf_files.dart';
import 'package:pdf_viewer/database/db.dart';
import 'package:permission_handler/permission_handler.dart';

List<File> files = new List();
List<PDFFiles> result = new List();
List<PDFFiles> recent = new List();
PdfDbProvider dbPDF = PdfDbProvider();

retrievingList() async {
  if (await Permission.storage.isGranted) {
    var extDir = await ExtStorage.getExternalStorageDirectory();
    //  var file = "$fileOrDir/pdf/";
    List contents = Directory(extDir).listSync();
    recursiveMethod(contents);

  }else{
    exit(1);
  }
  return files;
}

recursiveMethod(contents){
  for (dynamic fileOrDir in contents) {
    String name1 = fileOrDir.runtimeType.toString();

    if (name1 == '_Directory') {

      List content = fileOrDir.listSync();
      recursiveMethod(content);
      // for (var newFile in content) {
      //   String name = newFile.runtimeType.toString();
      //   if (name == '_Directory'){
      //     recursiveMethod(content);
      //   }else{
      //     var path = newFile.path;
      //     String name = lookupMimeType(path);
      //     if (name == "application/pdf") {
      //       files.add(File(newFile.path));
      //     }
      //   }
      //
      // }
    }else{
      var path = fileOrDir.path;
      String name = lookupMimeType(path);
      if (name == "application/pdf") {
        files.add(File(fileOrDir.path));
      }
    }
  }
}

Future<void> checkPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();
}

Future<List<PDFFiles>> data(context) async {
  await checkPermissions();
  await retrievingList();
  for (int i = 0; i < files.length; i++) {
    result.add(PDFFiles(
        id: i,
        name: files.elementAt(i).path.split("/").last,
        date: files.elementAt(i).statSync().modified.toUtc().toString(),
        changedDate: files.elementAt(i).statSync().modified.toUtc().toString(),
        size: files.elementAt(i).statSync().size.toString(),
        path: files.elementAt(i).path));
  }
  return result;
}

Future<List<PDFFiles>> fetchPDF() async {
  //returns the memos as a list (array)

  final db = await dbPDF.init();
  final maps =
      await db.query("PDF"); //query all the rows in a table as an array of maps

  recent = List.generate(maps.length, (i) {

    //create a list of memos
    return PDFFiles(
      id: maps[i]['id'],
      name: maps[i]['name'],
      size: maps[i]['size'],
      date: maps[i]['date'],
      path: maps[i]['path'],
      changedDate: maps[i]['changedDate'],
    );
  });
  return recent;
}
