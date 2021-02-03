import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Customs{


  Widget texts(String title, double font, Color colors) {
    return Text(
      title,
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: font, color: colors, fontFamily: "Manjari"),
    );
  }

  var dates;

  Card card(var element,var size,context,int num) {
    if(num == 0){
       dates = DateTime.parse(element.changedDate);

    }else{
       dates = DateTime.parse(element.date);
    }
    final DateFormat timeFormatter = DateFormat('HH:mm a');
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final String time = timeFormatter.format(dates);
    final String date = dateFormatter.format(dates);
    return Card(
      color: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
              ),
              Image.asset("assets/pdf.png"),
              SizedBox(
                width: 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: texts(
                          element.name , 16.0, Colors.black)),
                  // Text(pdfFiles[index].name,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      texts(
                          date,
                          14.0,
                          Colors.red),
                      texts(" • ", 15.0, Colors.black),
                      texts(
                          time,
                          14.0,
                          Colors.red),
                      texts(" • ", 15.0, Colors.black),
                      texts(size.toString() + " KB", 14.0, Colors.red),
                      // Text(pdfFiles[index].date+"•",),
                      // Text(pdfFiles[index].time+"•",),
                      // Text(pdfFiles[index].size+"•",),
                    ],
                  )
                ],
              ),
              Spacer(),
              Image.asset(
                "assets/threedot2.png",
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }



}