import 'dart:convert';
import 'dart:math';

// import 'package:digicat/Constants/KeyValue.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

import 'StaticConstant.dart';

class Constans {
  late SharedPreferences prefs;

  String getImageUrl(String image) {
    return "${StaticUrl.baseUrlS}webroot/uploads/products/${StaticData.unique_id}/$image";
  }

  String getCompanyImageUrl(String image) {
    return "https://www.digicat.in/webroot/uploads/users/$image";
  }

  String getDate(String dateStr) {
    try {
      final DateTime date =
          DateTime.parse(dateStr); // Parse the input date string
      final DateFormat formatter =
          DateFormat('dd-MMM-yyyy'); // Define the output format
      return formatter.format(date); // Format the date
    } catch (e) {
      return 'Invalid Date'; // Handle invalid date inputs
    }
  }

  void setData(String key, dynamic data) async {
    prefs = await SharedPreferences.getInstance();

    if (data is String) {
      await prefs.setString(key, data);
    } else if (data is double) {
      await prefs.setString(key, data.toString());
    } else if (data is int) {
      await prefs.setString(key, data.toString());
    } else if (data is bool) {
      await prefs.setBool(key, data);
    } else {
      throw ArgumentError('Unsupported data type');
    }
  }

  Future<dynamic> getDATA(String key, Type type) async {
    prefs = await SharedPreferences.getInstance();

    if (type == String) {
      return prefs.getString(key) ?? '';
    } else if (type == double) {
      return prefs.getString(key)?.isNotEmpty ?? true
          ? double.tryParse(prefs.getString(key) ?? '') ?? 1.0
          : 1.0;
    } else if (type == int) {
      return (prefs.getString(key)?.isNotEmpty ?? false)
          ? int.tryParse(prefs.getString(key) ?? '') ??
              (key == StaticConstant.tagDecimalPlaces ? 0 : 1)
          : (key == StaticConstant.tagDecimalPlaces ? 0 : 1);
    } else if (type == bool) {
      return prefs.getBool(key) ?? true;
    } else {
      throw ArgumentError('Unsupported data type');
    }
  }

  Future<String?> getData(String key) async {
    prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      key,
    );
  }

  Future<String> callApi(Map<String, dynamic> formData, String urlStr) async {
    var url = Uri.parse(urlStr);

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Add fields to the request
    formData.forEach((key, value) {
      request.fields[key] = value.toString(); // Convert to string if necessary
    });

    try {
      // Send the request
      var response = await request.send();

      // Convert response to a string
      var responseBody = await response.stream.bytesToString();

      // print("responseBody  : $responseBody");
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        showToast("Error: ${response.reasonPhrase}");
        return "";
      }
    } catch (e) {
      // Handle exceptions
      showToast("Exception: $e");
      return "";
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

//
//
// String formatNumber(double value, int decimalPlaces) {
//   NumberFormat formatter = NumberFormat("###,###,###,###.${'0' * decimalPlaces}");
//   return formatter.format(value);
// }
}
