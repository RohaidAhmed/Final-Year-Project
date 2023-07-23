import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dr_detection/classified.dart';
import 'package:logger/logger.dart';
import "package:image/image.dart" as img;
import 'package:http/http.dart' as http;
import "package:flutter_easyloading/flutter_easyloading.dart";

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedImagePath = '';
  String confidence = "";
  String diseaseConfidence = "";
  var logger = Logger();
  bool isRetinal = false;
  //double score1 = score *100;

  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  Future getCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Image Selected")));
      return;
    } else {
      setState(() {
        _image = File(pickedFile.path);
        _imageWidget = Image.file(_image!);
      });
      EasyLoading.show(status: 'loading...');
      await uploadImage();
      EasyLoading.dismiss();
    }
  }

  Future getGalleryImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Image Selected")));
      return;
    } else {
      setState(() {
        _image = File(pickedFile.path);
        _imageWidget = Image.file(_image!);
      });
    }
    EasyLoading.show(status: 'loading...');
    await uploadImage();
    EasyLoading.dismiss();
  }

  File? second_Image;
  String message = "";
  String diseaseMessage = "";
  bool flag = true;
  uploadImage() async {
    flag = false;
    final request = http.MultipartRequest(
        "POST", Uri.parse("https://fypdr-3cc646a95118.herokuapp.com/upload"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile(
        'image', _image!.readAsBytes().asStream(), _image!.lengthSync(),
        filename: _image!.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    setState(() {
      message = resJson['message'];
      confidence = resJson['confidence'];
    });
    Fluttertoast.showToast(msg: message.toString());
    second_Image = _image;

    if (message == 'retinal') {
      setState(() {
        isRetinal = true;
      });

      await _predictViaApi();
    }
  }

  _predictViaApi() async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("https://fypdr-3cc646a95118.herokuapp.com/uploadS"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile(
        'image', _image!.readAsBytes().asStream(), _image!.lengthSync(),
        filename: _image!.path.split("/").last));

    request.headers.addAll(headers);

    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    setState(() {
      diseaseMessage = resJson['message'];
      diseaseConfidence = resJson['confidence'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retinal Image Classification',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: _image == null
                ? const Text('No image selected.')
                : Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: _imageWidget,
                  ),
          ),
          const SizedBox(
            height: 36,
          ),
          Text(
            message != "" ? message : '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            confidence != "" ? 'Confidence: ${confidence.toString()}' : '',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 8,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.teal),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                  textStyle: MaterialStateProperty.all(
                      const TextStyle(fontSize: 14, color: Colors.white))),
              onPressed: isRetinal
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RetinaClassified(
                              image: _image!,
                              drType: diseaseMessage,
                              confidence: diseaseConfidence,
                            ),
                          ));
                    }
                  : () async {
                      selectImage();
                      setState(() {});
                    },
              child: isRetinal ? const Text("Classify") : const Text('Select')),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future selectImage() {
    return showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Text(
                        'Select Image From !',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await getGalleryImage();
                              Navigator.pop(context);

                              // if (selectedImagePath != '') {
                              //   Navigator.pop(context);
                              //   setState(() {});
                              // } else {
                              //   ScaffoldMessenger.of(context)
                              //       .showSnackBar(const SnackBar(
                              //     content: Text("No Image Captured !"),
                              //   ));
                              // }
                            },
                            child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/gallery.png',
                                        height: 60,
                                        width: 60,
                                      ),
                                      const Text('Gallery'),
                                    ],
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await getCameraImage();
                              Navigator.pop(context);
                            },
                            child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/camera.png',
                                        height: 60,
                                        width: 60,
                                      ),
                                      const Text('Camera'),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}
