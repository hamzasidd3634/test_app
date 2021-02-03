class PDFFiles implements Comparable{
  var time,size,name,path,id,changedDate;

  var date;

  PDFFiles({this.date,this.name, this.changedDate,  this.size,this.path,this.id});


  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
  Map<String,dynamic> toMap(){
    return <String,dynamic>{
      'id':id,
      'date':date,
      'name':name,
      'size':size,
      'path':path,
      'changedDate':changedDate,
  };
  }

}



