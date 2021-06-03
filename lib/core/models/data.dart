class Data {
  int? id;
  Object? resp;
  Data({this.id, this.resp});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['resp'] = this.resp;
    return data;
  }
}
