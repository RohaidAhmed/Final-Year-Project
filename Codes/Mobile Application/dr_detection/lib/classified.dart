import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Hscreen.dart';
import 'package:http/http.dart' as http;

class RetinaClassified extends StatefulWidget {
  final File image;
  final String confidence;
  final String drType;
  const RetinaClassified(
      {super.key,
      required this.image,
      required this.confidence,
      required this.drType});

  @override
  State<RetinaClassified> createState() => _RetinaClassifiedState();
}

class _RetinaClassifiedState extends State<RetinaClassified> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(),
                    ));
              },
              icon: Icon(Icons.arrow_back)),
          title: Text('DR Classification',
              style: const TextStyle(color: Colors.white)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 2),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(
                          widget.image,
                        ),
                        fit: BoxFit.cover),
                    border: Border.all(),
                  ),

                  //child: _imageWidget,
                ),
              ),
              const SizedBox(
                height: 36,
              ),
              Text(
                widget.drType,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Confidence: ${widget.confidence}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage()));
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.teal),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(20)),
                        textStyle: MaterialStateProperty.all(const TextStyle(
                            fontSize: 14, color: Colors.white))),
                    child: Text("Classify Another")),
              )
            ],
          ),
        ));
  }
}
