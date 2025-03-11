import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPhotoSection extends StatefulWidget {
  final Function(File) onImageSelected;
  final String titleText;

  const UploadPhotoSection({
    Key? key,
    required this.onImageSelected,
    this.titleText = 'ارفع صورة',
  }) : super(key: key);

  @override
  _UploadPhotoSectionState createState() => _UploadPhotoSectionState();
}

class _UploadPhotoSectionState extends State<UploadPhotoSection> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 400,
              ),
              child: Image.file(_image!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() => _image = imageFile);
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
        title: _image == null
            ? Text(
                widget.titleText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              )
            : null, // Hide title when an image is uploaded
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_image != null)
              IconButton(
                icon: Icon(Icons.visibility, size: 30, color: Colors.orange),
                onPressed: _showImageDialog,
              ),
            IconButton(
              icon: Icon(Icons.camera_alt, size: 30, color: Colors.green),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.photo_library, size: 30, color: Colors.blue),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPhotoSection();
  }
}
