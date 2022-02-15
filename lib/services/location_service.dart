import 'dart:convert';
import 'package:saudi_chat/models/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_init_to_null
MyLocation? pastData = null;

class GeoLocation {
  Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();

  String apiKey = "6269d398a98b5fb6cf7fbefb4868de77";
  Uri forwardApi = Uri.parse(
      "http://api.positionstack.com/v1/forward?access_key=6269d398a98b5fb6cf7fbefb4868de77");
  Uri reverseApi = Uri.parse(
      "http://api.positionstack.com/v1/reverse?access_key=6269d398a98b5fb6cf7fbefb4868de77");

  Future get getDeviceCoordinates async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print("Location services are disabled.");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && pastData == null) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print("Location permissions are denied");
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position location = await Geolocator.getCurrentPosition();
    return location;
  }

  Future getDeviceLocation() async {
    // 0 - Location services are disabled.
    // 1 - Location permissions are denied
    // 2 - Location permissions are permanently denied, we cannot request permissions.

    Future getCoordinates = getDeviceCoordinates.catchError((error) async {
      if (error.toString() == "Location services are disabled.") {
        Position? lastLocation =
            await Geolocator.getLastKnownPosition().catchError((error) => null);
        if (lastLocation == null) {
          SharedPreferences prefs = await sharedPreferences;
          if (prefs.containsKey("longitude")) {
            Position lastLocationPref = Position(
                longitude: double.parse(prefs.getString("longitude")!),
                latitude: double.parse(prefs.getString("latitude")!),
                timestamp: DateTime.tryParse(prefs.getString("timestamp")!),
                accuracy: double.parse(prefs.getString("accuracy") ?? "0"),
                altitude: double.parse(prefs.getString("altitude") ?? "0"),
                heading: double.parse(prefs.getString("heading") ?? "0"),
                speed: double.parse(prefs.getString("speed") ?? "0"),
                speedAccuracy:
                    double.parse(prefs.getString("speedAccuracy") ?? "0"));
            return lastLocationPref;
          } else {
            return 0;
          }
        } else {
          return lastLocation;
        }
      } else if (error.toString() == "Location permissions are denied") {
        return 1;
      } else {
        print(error);
        return 2;
      }
    });

    var errorCheck = await getCoordinates;
    if (errorCheck is int) {
      return errorCheck;
    } else {
      Position coordinates = errorCheck;
      // TODO: Save location result not coordenits
      sharedPreferences.then((pref) {
        coordinates.toJson().forEach((key, value) {
          pref.setString(key, value.toString());
        });
      });
      Uri api = Uri.parse(
          "$reverseApi&query=${coordinates.latitude},${coordinates.longitude}");
      // ignore: unnecessary_null_comparison
      try {
        if (pastData == null) {
          http.Response apiResults = await http.get(api);
          Map resultsData = jsonDecode(apiResults.body);
          MyLocation data = MyLocation().parseFromHttpResults(resultsData);
          pastData = data;
          return data;
        } else {
          return pastData!;
        }
      } catch (e) {
        print(e.toString()); // TODO: Test
        return MyLocation(); // SHOULD BE A FUTURE.ERROR
      }
    }
  }
}
