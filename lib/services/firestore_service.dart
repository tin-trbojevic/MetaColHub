import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:metacolhub/helper/helper_functions.dart';
import 'package:path_provider/path_provider.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;

  Stream<QuerySnapshot> getFiles() {
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('uploaded_files')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getCollocations(String fileId) {
    return _firestore
        .collection('uploaded_files')
        .doc(fileId)
        .collection('collocations')
        .snapshots();
  }

  Future<void> pickAndUploadFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      for (PlatformFile file in result.files) {
        bool fileExists = await _isFileAlreadyUploaded(file.name);
        if (fileExists) {
          continue;
        }

        await _processCSVFile(context, file);
      }
    }
  }

  Future<bool> _isFileAlreadyUploaded(String fileName) async {
    QuerySnapshot existingFiles =
        await _firestore
            .collection('uploaded_files')
            .where("fileName", isEqualTo: fileName)
            .where("userId", isEqualTo: userId)
            .limit(1)
            .get();
    return existingFiles.docs.isNotEmpty;
  }

  Future<void> _processCSVFile(BuildContext context, PlatformFile file) async {
    try {
      File localFile = File(file.path!);
      String csvString = await localFile.readAsString();

      List<List<dynamic>> csvRows = const CsvToListConverter(
        fieldDelimiter: ';',
        eol: '\n',
      ).convert(csvString);

      if (csvRows.isEmpty || csvRows.isEmpty) {
        return;
      }

      DocumentReference fileRef = _firestore
          .collection('uploaded_files')
          .doc(file.name);

      await fileRef.set({
        'fileName': file.name,
        'uploadedAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });
      for (int i = 0; i < csvRows.length; i++) {
        List<dynamic> row = csvRows[i];

        if (row.length == 3) {
          String base = row[0].toString().trim();
          String collocation = row[1].toString().trim();
          List<String> exampleParts =
              row.sublist(2).map((e) => e.toString().trim()).toList();
          String example = exampleParts.join(" ");

          await fileRef.collection("collocations").add({
            'base': base,
            'collocation': collocation,
            'example': example,
            'fileId': fileRef.id,
          });
        } else {
          displayMessageToUser('Invalid row skipped: $row', context);
        }
      }
    } catch (e) {
      //
    }
  }

  Future<void> addCollocation(
    String fileId,
    String base,
    String collocation,
    String example,
  ) async {
    try {
      await _firestore
          .collection('uploaded_files')
          .doc(fileId)
          .collection('collocations')
          .add({
            'base': base.trim(),
            'collocation': collocation.trim(),
            'example': example.trim(),
            'fileId': fileId,
            'addedManually': true,
          });
    } catch (e) {
      //
    }
  }

  Future<void> deleteFile(String fileId) async {
    var fileRef = _db.collection('uploaded_files').doc(fileId);
    var collocations = await fileRef.collection("collocations").get();

    for (var doc in collocations.docs) {
      await doc.reference.delete();
    }

    await fileRef.delete();
  }

  Stream<QuerySnapshot> getUserFiles() {
    if (userId == null) {
      return const Stream.empty();
    }

    return _db
        .collection('uploaded_files')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> searchCollocations(String query) async* {
    if (userId == null) {
      yield [];
      return;
    }

    if (query.isEmpty) {
      yield [];
      return;
    }

    var filesSnapshot =
        await _firestore
            .collection('uploaded_files')
            .where('userId', isEqualTo: userId)
            .get();

    List<Map<String, dynamic>> collocationsList = [];

    for (var file in filesSnapshot.docs) {
      var collocationsSnapshot =
          await file.reference.collection('collocations').get();

      for (var colloc in collocationsSnapshot.docs) {
        var data = colloc.data();
        if ((data['base'] as String).toLowerCase().startsWith(
          query.toLowerCase(),
        )) {
          collocationsList.add({
            "id": colloc.id,
            "base": data['base'],
            "collocation": data['collocation'],
            "example": data['example'],
            "fileId": file.id,
          });
        }
      }
    }

    yield collocationsList;
  }

  Stream<List<Map<String, dynamic>>> getCollocationsByBase(String base) async* {
    if (userId == null) {
      yield [];
      return;
    }

    var filesSnapshot =
        await _firestore
            .collection('uploaded_files')
            .where('userId', isEqualTo: userId)
            .get();

    List<Map<String, dynamic>> results = [];

    for (var file in filesSnapshot.docs) {
      var collocationsSnapshot =
          await file.reference
              .collection('collocations')
              .where('base', isEqualTo: base)
              .get();

      for (var colloc in collocationsSnapshot.docs) {
        var data = colloc.data();
        results.add({
          "id": colloc.id,
          "base": data['base'],
          "collocation": data['collocation'],
          "example": data['example'],
          "fileId": file.id,
        });
      }
    }

    yield results;
  }

  Stream<List<Map<String, dynamic>>> getRecentCollocations({
    int limit = 10,
  }) async* {
    if (userId == null) {
      yield [];
      return;
    }

    var filesSnapshot =
        await _firestore
            .collection('uploaded_files')
            .where('userId', isEqualTo: userId)
            .get();

    List<Map<String, dynamic>> recentCollocations = [];

    for (var file in filesSnapshot.docs) {
      var collocationsSnapshot =
          await file.reference
              .collection('collocations')
              .where('addedManually', isEqualTo: true)
              .limit(limit)
              .get();

      for (var colloc in collocationsSnapshot.docs) {
        var data = colloc.data();
        recentCollocations.add({
          "id": colloc.id,
          "base": data['base'],
          "collocation": data['collocation'],
          "example": data['example'],
          "fileId": file.id,
        });
      }
    }

    yield recentCollocations;
  }

  Future<void> deleteCollocation(String fileId, String collocationId) async {
    try {
      await _firestore
          .collection('uploaded_files')
          .doc(fileId)
          .collection('collocations')
          .doc(collocationId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editCollocation({
    required String fileId,
    required String collocationId,
    required String newBase,
    required String newCollocation,
    required String newExample,
  }) async {
    try {
      await _firestore
          .collection('uploaded_files')
          .doc(fileId)
          .collection('collocations')
          .doc(collocationId)
          .update({
            'base': newBase,
            'collocation': newCollocation,
            'example': newExample,
          });
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getAllUploadedFiles(String userId) {
    return FirebaseFirestore.instance
        .collection('uploadediles')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> exportFileAsCSV(
    BuildContext context,
    String fileId,
    String fileName,
  ) async {
    try {
      final fileRef = _firestore.collection('uploaded_files').doc(fileId);
      final collocsSnapshot = await fileRef.collection('collocations').get();

      if (collocsSnapshot.docs.isEmpty) {
        displayMessageToUser('No collocations found in this file.', context);
        return;
      }

      List<List<String>> rows = [];

      for (var doc in collocsSnapshot.docs) {
        final data = doc.data();
        rows.add([
          data['base'] ?? '',
          data['collocation'] ?? '',
          data['example'] ?? '',
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      File? file;

      if (Platform.isIOS || Platform.isAndroid) {
        Directory dir = await getApplicationDocumentsDirectory();
        final folderPath = '${dir.path}/metacolhub_files';
        final folder = Directory(folderPath);

        if (!await folder.exists()) {
          await folder.create(recursive: true);
        }

        final fullPath = '$folderPath/$fileName';
        file = File(fullPath);
      } else {
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save CSV File',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputPath == null) {
          displayMessageToUser('File save canceled.', context);
          return;
        }

        file = File(outputPath);
      }

      await file.writeAsString(csvData);
      displayMessageToUser('CSV file saved to ${file.path}', context);
    } catch (e) {
      displayMessageToUser('Failed to export CSV file.', context);
    }
  }
}
