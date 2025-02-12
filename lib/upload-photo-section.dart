import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPhotoSection extends StatefulWidget {
  final Function(File) onImageSelected;

  const UploadPhotoSection({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _UploadPhotoSectionState createState() => _UploadPhotoSectionState();
}

class _UploadPhotoSectionState extends State<UploadPhotoSection> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from the camera
  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
      widget.onImageSelected(imageFile);
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
      widget.onImageSelected(imageFile);
    }
  }

  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          'ارفع صورة من جمع النفايات', // Arabic for "Upload a photo from waste collection"
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Ensure the icons stay close together
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt, size: 30, color: Colors.green), // Camera icon
              onPressed: _pickImageFromCamera,
            ),
            const SizedBox(width: 8), // Add spacing between the icons
            IconButton(
              icon: Icon(Icons.photo_library, size: 30, color: Colors.blue), // Gallery icon
              onPressed: _pickImageFromGallery,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_image != null) Image.file(_image!), // Displays the selected/captured image
        _buildPhotoSection(),
      ],
    );
  }
}