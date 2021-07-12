import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageController extends GetxController {
  var imagePath = ''.obs;
  var text = ''.obs;
  var inputImage;
  RecognisedText recognisedText;
  final _languageModelManager = GoogleMlKit.nlp.entityModelManager();

  final _entityExtractor =
      GoogleMlKit.nlp.entityExtractor(EntityExtractorOptions.ENGLISH);

  final picker = ImagePicker();
  final textDetector = GoogleMlKit.vision.textDetector();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
      inputImage = InputImage.fromFilePath(pickedFile.path);

      // recognisedText = await textDetector.processImage(inputImage);
      // text.value = recognisedText.text;
      // textDetector.close();
    } else {
      print('No image selected.');
    }
  }

  Future downloadModel() async {
    var result = await _languageModelManager
        .downloadModel(EntityExtractorOptions.ENGLISH, isWifiRequired: false);
    print('Model downloaded: $result');
  }

  Future getAvailableModels() async {
    var result = await _languageModelManager.getAvailableModels();
    print('Available models: $result');
  }

  Future isModelDownloaded() async {
    var result = await _languageModelManager
        .isModelDownloaded(EntityExtractorOptions.ENGLISH);
    print('Model download: $result');
  }

  Future translateText() async {
    var result = await _entityExtractor.extractEntities(text.value);
    result.forEach((element) {
      print('${element.entities} and ${element.text}');
    });
  }
}
