import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationTaking extends StatefulWidget {
  const LocationTaking({Key? key, this.name, this.locationValue})
      : super(key: key);
  final String? name;
  final Location? locationValue;

  @override
  _LocationTakingState createState() => _LocationTakingState();
}

class _LocationTakingState extends State<LocationTaking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyLocationTracker(
        name: widget.name,
        locationValue: widget.locationValue,
      ),
    );
  }
}

class MyLocationTracker extends StatefulWidget {
  const MyLocationTracker({Key? key, this.name, this.locationValue})
      : super(key: key);
  final String? name;
  final Location? locationValue;

  @override
  _MyLocationTrackerState createState() => _MyLocationTrackerState();
}

class _MyLocationTrackerState extends State<MyLocationTracker> {
  void getlocation() async {
    widget.locationValue!.enableBackgroundMode(enable: true);
    widget.locationValue!.onLocationChanged
        .listen((LocationData currentLocation) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var dataRef = firestore.collection('LocationTrack');
      Map<String, dynamic> myData = {
        'Name': widget.name,
        'Location': {
          'Longitude': '${currentLocation.longitude}',
          'Latitude': '${currentLocation.latitude}'
        }
      };
      dataRef.doc(widget.name).set(myData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Longitude : ${currentLocation.longitude} || Latitude : ${currentLocation.latitude}')));
    });
  }

  @override
  Widget build(BuildContext context) {
    getlocation();
    return Center(
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black)),
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Text('"Name : ${widget.name}" Kaydının Konum Verisi Çekiliyor')
              ],
            ))));
  }
}
