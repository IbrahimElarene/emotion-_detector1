import 'package:camera/camera.dart';
//import 'package:emotion_detector/main.dart';
import 'package:flutter/material.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';

import 'main.dart';

class EmotionDetector extends StatefulWidget {
  const EmotionDetector({super.key});

  @override
  State<EmotionDetector> createState() => _EmotionDetectorState();
}

class _EmotionDetectorState extends State<EmotionDetector> {
  CameraController? cameraController;
  String output = '';
  double? per;
  int? i;

  loadCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.high);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController!.startImageStream((image) {
            runModel(image);
          });
        });
      }
    });
  }

  runModel(CameraImage img) async {
    dynamic recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );
    for (var element in recognitions) {
      setState(() {
        output = element['label'];
      });
    }
    for (var element in recognitions) {
      setState(() {
        per = element['confidence'] * 100;
        i = per?.toInt();
      });
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets1/model_unquant.tflite', labels: 'assets1/labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Emotion Detector'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 360,
            child: CameraPreview(cameraController!),
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            '$output $i%',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      ),
    );
  }
}
