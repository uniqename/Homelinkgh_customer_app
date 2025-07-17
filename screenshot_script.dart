import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ScreenshotHelper {
  static const platform = MethodChannel('screenshot/capture');
  
  // Take screenshot and save to desktop
  static Future<void> captureAndSave(String filename) async {
    try {
      // Using platform-specific method to capture screenshot
      final Uint8List? result = await platform.invokeMethod('capture');
      
      if (result != null) {
        final directory = '/Users/enamegyir/Desktop/HomeLinkGH_Screenshots';
        await Directory(directory).create(recursive: true);
        
        final file = File('$directory/$filename.png');
        await file.writeAsBytes(result);
        print('Screenshot saved: $filename.png');
      }
    } catch (e) {
      print('Error taking screenshot: $e');
    }
  }
  
  // Alternative method using RepaintBoundary
  static Future<void> captureWidget(GlobalKey key, String filename) async {
    try {
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      final directory = '/Users/enamegyir/Desktop/HomeLinkGH_Screenshots';
      await Directory(directory).create(recursive: true);
      
      final file = File('$directory/$filename.png');
      await file.writeAsBytes(pngBytes);
      print('Screenshot saved: $filename.png');
    } catch (e) {
      print('Error capturing widget: $e');
    }
  }
}