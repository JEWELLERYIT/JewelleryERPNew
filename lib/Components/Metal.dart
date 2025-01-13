
class Metal1 {
  String metal;
  String price;
  String labGrm;
  String labPar;

  Metal1(
      {required this.metal,
        required this.price,
        required this.labGrm,
        required this.labPar});

  factory Metal1.fromJson(Map<String, dynamic> json) {
    return Metal1(
        metal: json['metal'].toString(), price: "", labGrm: "", labPar: "");
  }

  Map<String, dynamic> toJson() {
    return {
      'metal': metal,
      'price': price,
      'labGrm': labGrm ?? "",
      'labPar': labPar ?? "",
    };
  }

  // Method to create a JSON array from a list of Metal instances
  static List<Map<String, dynamic>> toJsonArray(List<Metal1> metals) {
    return metals.map((metal) => metal.toJson()).toList();
  }
}
