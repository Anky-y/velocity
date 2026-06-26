import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:velocity/models/fileOperationModel.dart';

final operationTypes = [
  OperationType(
    name: "Converter",
    description:
        "Convert audio, video, and image files between high-quality formats instantly.",
    icon: LucideIcons.rotate3d200,
  ),
  OperationType(
    name: "Compressor",
    description:
        "Reduce file sizes significantly without losing perceived quality.",
    icon: LucideIcons.foldVertical200,
  ),
  OperationType(
    name: "Merger",
    description:
        "Combine multiple PDFs or media files into a single continuous document.",
    icon: LucideIcons.merge200,
  ),
];
