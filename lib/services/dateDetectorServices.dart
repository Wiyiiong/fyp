import 'dart:io';
import 'dart:typed_data';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:image/image.dart' as img;
import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart' show rootBundle;

class DateDetectorService {
  static Future<DateTime> getPredictedResult(File image) async {
    Tflite.close();
    DateTime date;
    try {
      await Tflite.loadModel(
          model: 'assets/model/model.tflite',
          labels: 'assets/model/label-digits.txt',
          numThreads: 1,
          useGpuDelegate: true);
      img.Image oriImage = img.decodeImage(image.readAsBytesSync());
      img.Image resizedImage = img.copyResize(oriImage, height: 80, width: 215);

      var recognitions = await Tflite.runModelOnBinary(
          binary: imageToByteListFloat32(resizedImage),
          asynch: false,
          threshold: 0.0);
      if (recognitions != null) {
        String result = recognitions[0]['label'];
        String labelStr = await rootBundle.loadString('assets/model/label.txt');
        List<String> label = labelStr.split('\n').toList();
        label.removeLast();
        print(label.length);
        int element = (int.parse(result) ?? 1) - 1;
        String dates = label.elementAt(element).trim();
        if (dates.length == 6) {
          var day = int.parse(dates.substring(0, 2));
          var month = int.parse(dates.substring(2, 4));
          var year = int.parse('20' + dates.substring(4, 6));
          date = new DateTime(year, month, day);
        } else if (dates.length == 8) {
          /// Format: ddmmyyyy || yyyymmdd
          if (dates.startsWith('202')) {
            /// Format : yyyymmdd
            var year = int.parse(dates.substring(0, 4));
            var month = int.parse(dates.substring(4, 6));
            var day = int.parse(dates.substring(6, 8));
            date = new DateTime(year, month, day);
          } else {
            /// Format : ddmmyyyy
            var day = int.parse(dates.substring(0, 2));
            var month = int.parse(dates.substring(2, 4));
            var year = int.parse(dates.substring(4, 8));
            date = new DateTime(year, month, day);
          }
        } else if (dates.length == 7) {
          /// Format : MMyyyy
          if (dates.startsWith('Feb')) {
            if (int.parse(dates.substring(3)) % 4 == 0) {
              var day = 29;
              var month = monthConst['Feb'];
              var year = int.parse(dates.substring(3, 7));
              date = new DateTime(year, month, day);
            } else {
              var day = 28;
              var month = monthConst['Feb'];
              var year = int.parse(dates.substring(3, 7));
              date = new DateTime(year, month, day);
            }
          } else if (dates.startsWith('Jan') ||
              dates.startsWith('Mar') ||
              dates.startsWith('May') ||
              dates.startsWith('Jul') ||
              dates.startsWith('Aug') ||
              dates.startsWith('Oct') ||
              dates.startsWith('Dec')) {
            var day = 31;
            var month = monthConst[dates.substring(0, 3)];
            var year = int.parse(dates.substring(3));
            date = new DateTime(year, month, day);
          } else {
            var day = 30;
            var month = monthConst[dates.substring(0, 3)];
            var year = int.parse(dates.substring(3));
            date = new DateTime(year, month, day);
          }
        }
        Tflite.close();
        return date;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Uint8List imageToByteListFloat32(img.Image image) {
    var convertedBytes = Float32List(1 * 80 * 215 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < 80; i++) {
      for (var j = 0; j < 215; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - 0.0) / 1.0;
        buffer[pixelIndex++] = (img.getGreen(pixel) - 0.0) / 1.0;
        buffer[pixelIndex++] = (img.getBlue(pixel) - 0.0) / 1.0;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
