import 'dart:io';

import 'package:get/get.dart';

class GenerateLogic extends GetxController {
  final Rxn<File> pickedImage = Rxn<File>();

  final RxString outfitNotes = ''.obs;
  final RxString preferredColors = ''.obs;
  final RxString preferredStyle = ''.obs;
  final RxString preferredElements = ''.obs;
  final RxString customPrompt = ''.obs;

  final RxBool isGenerating = false.obs;
  final RxnString generatedImagePath = RxnString();
}
