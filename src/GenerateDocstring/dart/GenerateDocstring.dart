/// An annotator for generating docstrings for dart
/// classes, enums, and functions
class GenerateDocstring {
  final String description;
  final String? codeExample;
  final String annotatorName;

  const GenerateDocstring({
    required this.description,
    this.codeExample,
    this.annotatorName = "GenerateDocstring",
  });
}
