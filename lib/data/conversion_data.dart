import "package:flutter/material.dart";
import "package:velocity/models/conversionListModel.dart";

 

class ConversionData {
  static final Map<FileTypeCategory, CategoryConfig> registry = {
    
    // --- IMAGE CONVERSIONS ---
    FileTypeCategory.image: const CategoryConfig(
      pageTitle: 'Image Conversions',
      options: [
        ConversionOption(
          title: 'JPG to PNG',
          description: 'Lossless conversion for transparent backgrounds',
          icon: Icons.image,
          iconColor: Colors.blueAccent,
          routeName: '/jpg_to_png',
        ),
        ConversionOption(
          title: 'JPG to WEBP',
          description: 'Highly compressed format for web',
          icon: Icons.photo_library,
          iconColor: Colors.green,
          routeName: '/jpg_to_webp',
        ),
        ConversionOption(
          title: 'HEIC to JPG',
          description: 'Convert iOS photos for universal compatibility',
          icon: Icons.phone_android,
          iconColor: Colors.orange,
          routeName: '/heic_to_jpg',
        ),
      ],
    ),

    // --- VIDEO CONVERSIONS ---
    FileTypeCategory.video: const CategoryConfig(
      pageTitle: 'Video Conversions',
      options: [
        ConversionOption(
          title: 'MP4 to GIF',
          description: 'Create animated loops from video',
          icon: Icons.gif_box,
          iconColor: Colors.indigo,
          routeName: '/mp4_to_gif',
        ),
        ConversionOption(
          title: 'MOV to MP4',
          description: 'Convert Apple QuickTime videos to MP4',
          icon: Icons.video_file,
          iconColor: Colors.purple,
          routeName: '/mov_to_mp4',
        ),
      ],
    ),

    // --- DOCUMENT CONVERSIONS ---
    FileTypeCategory.document: const CategoryConfig(
      pageTitle: 'Document Conversions',
      options: [
        ConversionOption(
          title: 'PDF to Word',
          description: 'Convert PDF documents into editable DOCX files',
          icon: Icons.description,
          iconColor: Colors.redAccent,
          routeName: '/pdf_to_word',
        ),
        ConversionOption(
          title: 'Word to PDF',
          description: 'Save documents as universally readable PDFs',
          icon: Icons.picture_as_pdf,
          iconColor: Colors.blue,
          routeName: '/word_to_pdf',
        ),
      ],
    ),
  };
}