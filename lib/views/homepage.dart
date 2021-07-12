import 'package:flutter/material.dart';
import '../controllers/image_controller.dart';
import 'package:get/get.dart';
import 'dart:io';

class HomePage extends StatelessWidget {
  final imageController = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Remind'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: GetX<ImageController>(builder: (controller) {
              return Column(
                children: [
                  Container(
                    height: size.height * 0.5,
                    color: Colors.grey,
                    margin: EdgeInsets.all(20),
                    child: controller.imagePath == null
                        ? Container()
                        : Image.file(File(controller.imagePath.toString())),
                  ),
                  MaterialButton(
                    onPressed: () {
                      imageController.getImage();
                    },
                    child: Text("Select Image"),
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                  SizedBox(height: 30),
                  SelectableText(controller.text.toString()),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          imageController.downloadModel();
                        },
                        child: Text("Download Model"),
                        color: Colors.blue,
                        textColor: Colors.white,
                      ),
                      MaterialButton(
                        onPressed: () {
                          imageController.translateText();
                        },
                        child: Text("Extract Entity"),
                        color: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
