import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:uuid/uuid.dart';

class Capteur {
  String id;
  String name;
  String commune;
  Timestamp date_installation;
  Timestamp date_last_update;
  String img1;
  String img2;
  String img3;
  String localisation;
  num battery;
  num fill_rate;


  Capteur({
    this.id,
    this.name,
    this.commune,
    this.date_installation,
    this.date_last_update,
    this.img1,
    this.img2,
    this.img3,
    this.localisation,
    this.battery,
    this.fill_rate,
  });
}


