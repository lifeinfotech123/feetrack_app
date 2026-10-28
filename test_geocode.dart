import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=19.0760,72.8777&key=AIzaSyDODsIBKvD4Ft0M58AYjLrdsED5xZDg0A0';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    print(response.body);
  } else {
    print("Error: \${response.statusCode}");
  }
}
