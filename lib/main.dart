import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:locationtrial/LocationTaking.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Location().enableBackgroundMode(enable: true);
  Location location = new Location();
  runApp(MyApp(
    locationValue: location,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, this.locationValue}) : super(key: key);
  final Location? locationValue;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('HATA!!'));
            } else if (snapshot.hasData) {
              return MyHomePage(
                title: 'Flutter Demo Home Page',
                locationValue: locationValue,
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, this.title, this.locationValue})
      : super(key: key);
  final String? title;
  final Location? locationValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LocTrial(
      locationValue: locationValue,
    ));
  }
}

class LocTrial extends StatefulWidget {
  const LocTrial({Key? key, this.locationValue}) : super(key: key);
  final Location? locationValue;

  @override
  _LocTrialState createState() => _LocTrialState();
}

class _LocTrialState extends State<LocTrial> {
  String? _name = '';
  final _formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                width: Get.width * 0.5,
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black)),
                child: TextFormField(
                  validator: (name) {
                    if (name!.length < 5) {
                      return 'İsim 5 karakterden büyük olmalı';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (name) {
                    _name = name;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(hintText: 'İsim'),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      _formkey.currentState!.save();

                      LocationData? _locationData;
                      bool? _serviceEnabled;
                      PermissionStatus? _permissionGranted;
                      _locationData = await widget.locationValue!.getLocation();
                      _serviceEnabled =
                          await widget.locationValue!.serviceEnabled();
                      if (!_serviceEnabled) {
                        _serviceEnabled =
                            await widget.locationValue!.requestService();
                        if (!_serviceEnabled) {
                          return;
                        }
                      }

                      _permissionGranted =
                          await widget.locationValue!.hasPermission();
                      if (_permissionGranted == PermissionStatus.denied) {
                        _permissionGranted =
                            await widget.locationValue!.requestPermission();
                        if (_permissionGranted != PermissionStatus.granted) {
                          return;
                        }
                      }

                      FirebaseFirestore firestore = FirebaseFirestore.instance;
                      var dataRef = firestore.collection('LocationTrack');
                      Map<String, dynamic> myData = {
                        'Name': _name.toString(),
                        'Location': {
                          'Longitude': '${_locationData.longitude}',
                          'Latitude': '${_locationData.latitude}'
                        }
                      };
                      dataRef.doc(_name.toString()).set(myData);

                      Get.to(LocationTaking(
                        name: _name.toString(),
                        locationValue: widget.locationValue!,
                      ));
                    }
                  },
                  child: Text('Konum Verisini Göndermeye Başla'))
            ],
          ),
        ),
      ),
    );
  }
}
