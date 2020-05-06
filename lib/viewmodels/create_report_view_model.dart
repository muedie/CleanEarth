import 'dart:io';

import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:timwan/constants/route_names.dart';
import 'package:timwan/locator.dart';
import 'package:timwan/models/image_data.dart';
import 'package:timwan/models/trash_report.dart';
import 'package:timwan/services/authentication_service.dart';
import 'package:timwan/services/cloud_storage_service.dart';
import 'package:timwan/services/firestore_service.dart';
import 'package:timwan/services/image_picker_service.dart';
import 'package:timwan/services/location_service.dart';
import 'package:timwan/services/navigation_service.dart';
import 'package:timwan/viewmodels/base_model.dart';

class CreateReportViewModel extends BaseModel {
  final LocationService _locationService = locator<LocationService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final ImagePickerService _imagePickerService = locator<ImagePickerService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final CloudStorageService _cloudStorageService =
      locator<CloudStorageService>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();

  File image;
  List<TrashTag> tags = [];

  bool _cleaned = false;
  bool get cleaned => _cleaned;

  Future selectImageFromCamera() async {
    setIsLoading(true);
    image = await _imagePickerService.selectImageFromCamera();
    setIsLoading(false);
  }

  Future selectImageFromGallery() async {
    setIsLoading(true);
    image = await _imagePickerService.selectImageFromGallery();
    setIsLoading(false);
  }

  void changeCleanStatus(bool value) {
    _cleaned = value;
    notifyListeners();
  }

  Future createReport() async {
    if (image == null) {
      return;
    }

    setIsLoading(true);
    setErrors("");

    // TODO: remove dependency on GeoFirePoint
    GeoFirePoint position = await _locationService.getUserLocation();
    if (position == null) {
      return;
    }

    var result = await _cloudStorageService.uploadImage(
      image: image,
      uid: _authenticationService.currentUser.uid,
    );

    if (result is ImageData) {
      var report = TrashReport(
        position: position,
        tags: tags.map((tag) => tag.name).toList(),
        createdAt: DateTime.now().toUtc(),
        reporterUid: _authenticationService.currentUser.uid,
        cleanerUid: _cleaned ? _authenticationService.currentUser.uid : null,
        imageData: result,
      );

      var reportRes = await _firestoreService.createReport(report);

      if (reportRes is String) {
        setErrors(reportRes);
      } else {
        _navigationService.navigateTo(DashboardScreenRoute);
      }
    }

    setIsLoading(false);
  }

  List<TrashTag> findSuggestions(query) {
    return [
      TrashTag(name: 'Paper', position: 1),
      TrashTag(name: 'Plastic', position: 2),
      TrashTag(name: 'Hazardous', position: 3),
      TrashTag(name: 'Recyclable', position: 4),
      TrashTag(name: 'Decomposable', position: 5)
    ]
        .where((tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

class TrashTag extends Taggable {
  final String name;
  final int position;

  /// Creates TrashTag
  TrashTag({this.name, this.position});

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => '''  {
    "name": $name,\n
    "position": $position\n
  }''';

  String toString() => '[Trashtag]: {name: $name}';
}
