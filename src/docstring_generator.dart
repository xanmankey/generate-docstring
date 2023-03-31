import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
// import 'package:code_builder/code_builder.dart';
import 'package:path/path.dart' as path;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

/// TODO: still need to set up the VSCODE extension to generate/
/// adapt code w/ docstrings on save or on build (dependant on user)

/// The annotation class
class Docstring {
  final String description;

  const Docstring({this.description = ''});
}

/// An enumerator for checking against and handling formatting for specific types
enum SupportedTypes {
  methodElement,
  constructorElement,
  classElement,
  mixinElement,
  enumElement;

  // Check if a given type is supported or not
  static bool checkType(dynamic type) {
    switch (type.runtimeType) {
      case MethodElement:
        return true;
      case ConstructorElement:
        return true;
      case ClassElement:
        return true;
      case MixinElement:
        return true;
      case EnumElement:
        return true;
      default:
        return false;
    }
  }

  get methodElementType => MethodElement;
  get constructorElementType => ConstructorElement;
  get classElementType => ClassElement;
  get mixinElementType => MixinElement;
  get enumElementType => EnumElement;
}

/// A utility class for retrieving code
class CodeRetrieval {
  // Retrieve code based on the type of the annotated element
  SupportedTypes type;
  Element element;

  CodeRetrieval(this.type, this.element);

  /// A function for retrieving the offset of the annotated code
  /// Uses string manip to handle cases for differing types
  int getOffset(String sourceFileString) {
    // element.accept(visitor);
  }

  /// A function for retrieving the annotated code
  /// How the code is retrieved depends on the type of the annotated element
  List<int> getCode(List<int> bytes, SupportedTypes type) {
    switch (type) {
      case SupportedTypes.classElement:

      case SupportedTypes.constructorElement:

      case SupportedTypes.enumElement:

      case SupportedTypes.methodElement:

      case SupportedTypes.mixinElement:
    }
    List<int> sourceCode = [];
    int functionDepth = 1;
    bool firstCurlyBrace = true;
    for (int byte in bytes) {
      if (byte == '{'.codeUnits[0]) {
        if (!firstCurlyBrace) {
          functionDepth += 1;
        } else {
          firstCurlyBrace = false;
        }
      } else if (byte == '}'.codeUnits[0]) {
        functionDepth -= 1;
      }
      sourceCode.add(byte);
      if (functionDepth == 0) {
        return sourceCode;
      }
    }
    throw FormatException(
        "Could not return code; curly brace never closes from offset");
  }

  /// Combines class functionality to retrieve a code string
  String getSourceCode(int offset, String filepath) {
    var sourceFile = File(filepath);
    var bytes = sourceFile.readAsBytesSync().sublist(offset);
    var sourceCode = ascii.decode(getCode(bytes));
    return sourceCode;
  }
}

/// A function for formatting a string as a docstring
String formatDocstring(String string, {bool extraLine = false}) {
  String formattedString = '';
  List<String> lines = string.split("\n");
  int lineNum = 0;
  for (String line in lines) {
    lineNum += 1;
    // Don't add a newline on the last line for formatting purposes
    if (lineNum == lines.length) {
      formattedString += "/// " + line;
      return formattedString;
    }
    formattedString += "/// " + line + "\n";
  }
  return '';
}

// TODO: not sure how to get the description this way
// it's definitely a compelling option in theory tho

/// A recursive visitor that runs on save or on build, depending 
/// on the user option; 
/// checks for the @Docstring annotator for supported classes, and if it exists,
/// updates the docstring accordingly using the given information 
class DocstringGenerator extends GeneralizingAstVisitor<void> with ElementVisitor<void> {
  final TypeChecker annotationChecker;
  final String homeDirectory;

  DocstringGenerator() : annotationChecker = TypeChecker.fromRuntime(Docstring), homeDirectory = Directory.current.path;
  @override
  void visitClassElement(ClassElement element) async {
    if (annotationChecker.hasAnnotationOfExact(element)) {
      // Retrieve filepath of the file with the class, open in read mode
      String filepath = homeDirectory + element.source.shortName;
      // Validate the filepath and adapt it if necessary; error out if invalid
      filepath = await validateFilepath(filepath);
      File file = File(filepath);
      RandomAccessFile raf = await file.open(mode: FileMode.append);
      // Read the entirety of the file into a string as code
      String code = await file.readAsString();
      // Retrieve class code (may not be able to do this; I need to test)
      String sourceCode = element.source.contents.data;
      // Isolate previous docstring using the length property
      final int previousDocstringLength = (element.documentationComment != null)
        ? element.documentationComment!.runes.length +
            element.documentationComment!.split("\n").length
        : 0;
      // Fetch the offset where the class starts 
      // .lastIndexOf() is used in the case of a docstring
      int offsetOfSourceCode = code.lastIndexOf(sourceCode);
      // Fetch the description of the annotation
      String description = TODO;
      // Create a new, formatted docstring using the current class code
      String docstring = formatDocstring(description) + formatDocstring(sourceCode);
      // Compare the previous and current docstrings. If they are not equal, 
      // open the file, and write from the docstring on with the new docstring 
      // + the rest of the file
      if (docstring != element.documentationComment) {
        // Read the remainder code into a variable, so it can be preserved
        String remainderCode = ascii.decode(code.codeUnits.getRange(offsetOfSourceCode, code.codeUnits.length).toList());
        // Truncate all of the code after the docstring of the annotated element
        await raf.truncate(offsetOfSourceCode - previousDocstringLength);
        // Set the file position to directly after the docstring
        await raf.setPosition(await raf.length());
        // Write the new docstring + the rest of the code
        await raf.writeString(docstring + remainderCode);
        // Close the file
        await raf.close();
      }
    }
  }

  @override
  void visitConstructorElement(ConstructorElement element) {
    if (annotationChecker.hasAnnotationOfExact(element)) {
      // Do stuff
    }
  }

  @override
  void visitFunctionElement(FunctionElement element) {
    if (annotationChecker.hasAnnotationOfExact(element)) {
      // Do stuff
    }
  }

  @override
  void visitMethodElement(MethodElement element) {
    if (annotationChecker.hasAnnotationOfExact(element)) {
      // Do stuff
    }
  }

  @override
  void visitEnumElement(EnumElement element) {
    if (annotationChecker.hasAnnotationOfExact(element)) {
      // Do stuff
    }
  }

  @override
  void visitMixinElement(MixinElement element) {
    if (annotationChecker.hasAnnotationOfExact(element)) {
      // Do stuff
    }
  }

  /// Methods from here on out are not yet implemented, 
  /// as they are not considered part of the core functionality 
  /// of the library. Feel free to provide implementations if you desire.
  @override
  void visitVariableElement(VariableElement element) {
    // TODO: implement visitVariableElement
  }

  @override
  void visitTypeParameterElement(TypeParameterElement element) {
    // TODO: implement visitTypeParameterElement
  }

  @override
  void visitDynamicType(DynamicType type) {
    // TODO: implement visitDynamicType
  }

  @override
  void visitFunctionType(FunctionType type) {
    // TODO: implement visitFunctionType
  }

  @override
  void visitInterfaceType(InterfaceType type) {
    // TODO: implement visitInterfaceType
  }

  @override
  void visitTypeParameterType(TypeParameterType type) {
    // TODO: implement visitTypeParameterType
  }

  @override
  void visitVoidType(VoidType type) {
    // TODO: implement visitVoidType
  }
  
  @override
  void visitAugmentationImportElement(AugmentationImportElement element) {
    // TODO: implement visitAugmentationImportElement
  }
  
  @override
  void visitCompilationUnitElement(CompilationUnitElement element) {
    // TODO: implement visitCompilationUnitElement
  }
  
  @override
  void visitExtensionElement(ExtensionElement element) {
    // TODO: implement visitExtensionElement
  }
  
  @override
  void visitFieldElement(FieldElement element) {
    // TODO: implement visitFieldElement
  }
  
  @override
  void visitFieldFormalParameterElement(FieldFormalParameterElement element) {
    // TODO: implement visitFieldFormalParameterElement
  }
  
  @override
  void visitGenericFunctionTypeElement(GenericFunctionTypeElement element) {
    // TODO: implement visitGenericFunctionTypeElement
  }
  
  @override
  void visitLabelElement(LabelElement element) {
    // TODO: implement visitLabelElement
  }
  
  @override
  void visitLibraryAugmentationElement(LibraryAugmentationElement element) {
    // TODO: implement visitLibraryAugmentationElement
  }
  
  @override
  void visitLibraryElement(LibraryElement element) {
    // TODO: implement visitLibraryElement
  }
  
  @override
  void visitLibraryExportElement(LibraryExportElement element) {
    // TODO: implement visitLibraryExportElement
  }
  
  @override
  void visitLibraryImportElement(LibraryImportElement element) {
    // TODO: implement visitLibraryImportElement
  }
  
  @override
  void visitLocalVariableElement(LocalVariableElement element) {
    // TODO: implement visitLocalVariableElement
  }
  
  @override
  void visitMultiplyDefinedElement(MultiplyDefinedElement element) {
    // TODO: implement visitMultiplyDefinedElement
  }
  
  @override
  void visitParameterElement(ParameterElement element) {
    // TODO: implement visitParameterElement
  }
  
  @override
  void visitPartElement(PartElement element) {
    // TODO: implement visitPartElement
  }
  
  @override
  void visitPrefixElement(PrefixElement element) {
    // TODO: implement visitPrefixElement
  }
  
  @override
  void visitPropertyAccessorElement(PropertyAccessorElement element) {
    // TODO: implement visitPropertyAccessorElement
  }
  
  @override
  void visitSuperFormalParameterElement(SuperFormalParameterElement element) {
    // TODO: implement visitSuperFormalParameterElement
  }
  
  @override
  void visitTopLevelVariableElement(TopLevelVariableElement element) {
    // TODO: implement visitTopLevelVariableElement
  }
  
  @override
  void visitTypeAliasElement(TypeAliasElement element) {
    // TODO: implement visitTypeAliasElement
  }
}

/// A function for formatting a string as a docstring
String formatDocstring(String string, {bool extraLine = false}) {
  String formattedString = '';
  List<String> lines = string.split("\n");
  int lineNum = 0;
  for (String line in lines) {
    lineNum += 1;
    // Don't add a newline on the last line for formatting purposes
    if (lineNum == lines.length) {
      formattedString += "/// " + line;
      return formattedString;
    }
    formattedString += "/// " + line + "\n";
  }
  return '';
}

/// A check for verifying if the filepath exists
Future<bool> checkFilepath(String filepath) async {
  if (await File(filepath).exists()) {
    return true;
  }
  return false;
}

/// A function for validating the filepath
Future<String> validateFilepath(String filepath) async {
  bool filepathValidator = false;
  filepathValidator = await checkFilepath(filepath);
  if (filepathValidator) {
    return filepath;
  }
  if (path.separator == "/") {
    filepath = filepath.replaceAll("/", "\\");
    filepathValidator = await checkFilepath(filepath);
    if (filepathValidator) {
      return filepath;
    }
  } else {
    filepath = filepath.replaceAll("\\", "/");
    filepathValidator = await checkFilepath(filepath);
    if (filepathValidator) {
      return filepath;
    }
  }
  throw FileSystemException("Could not find a valid filepath");
}

/// For switching path seperators
String switchSeperator(
    String newSeperator, String oldSeperator, String string) {
  var newString = string.replaceAll(oldSeperator, newSeperator);
  return newString;
}

/// The generator class
class DocstringGenerator extends GeneratorForAnnotation<Docstring> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
  var emitter = DartEmitter();
  element.library!.accept(emitter.visitAnnotation(Docstring));
        Library().annotations.where((annotatedElement) {
          annotatedElement.expression
        });
          var source = File('path/to/your/file.dart').readAsStringSync();
  var parsed = parseString(content: source);
  var library = parsed.unit.declaredElement!.library;
    final annotatedElements =
        library.(TypeChecker.fromRuntime(Docstring));
    final buffer = StringBuffer();
    for (final annotatedElement in annotatedElements) {
      final elementSource = annotatedElement.element!.source!;
      final start = annotatedElement.node!.offset;
      final end = annotatedElement.node!.end;
      final sourceCode = elementSource.contents.data.substring(start, end);
      buffer.writeln(sourceCode);
    }
    return buffer.toString();
    /*
    // Ensure that an element is annotated
    assert(element.source != null);
    // Ensure that the annotated element is of a supported type
    assert(SupportedTypes.checkType(element.runtimeType));
    // Initialize a formatter for formatting the annotated code
    DartFormatter formatter = DartFormatter();
    // Retrieve the entirety of the code so the file can be pieced back together
    String sourceCode = element.source!.contents.data;
    // Retrieve file information for reading to the file
    final currentDir = Directory.current.path.split("\\docstring_generator")[0];
    String filepath = currentDir + element.source!.fullName;
    filepath = await validateFilepath(filepath);
    // If a documentation comment exists,
    // its length is retrieved so it
    // can be properly overwritten
    final int previousCommentLength = (element.documentationComment != null)
        ? element.documentationComment!.runes.length +
            element.documentationComment!.split("\n").length
        : 0;
    // The description provided, split to be readable
    final String description =
        formatDocstring(annotation.read('description').stringValue) + "\n";
    // Use offsets to determine type, retrieve annotated code,
    // and write the docstring after the @Docstring annotator
    var startByte = element.nameOffset;
    // Use dart formatting concepts and string manip to get the length of the type
    final int typeOffset =
        element.getDisplayString(withNullability: true).split("(")[0].length -
            element.name!.length;
    // The code annotated, as a string
    final String annotatedCodeString =
        formatDocstring(formatter.format(getSourceCode(
      startByte,
      filepath,
      typeOffset,
    )));
    final String docString =
        "\n" + description + "/// ``` \n" + annotatedCodeString + "```";
    final String remainderCode = sourceCode.substring(startByte - typeOffset);
    final File file = File(filepath);
    final RandomAccessFile raf = await file.open(mode: FileMode.append);
    // The prior docstring, if it exists, is subtracted from the offset and thus
    // overwritten
    await raf.truncate(startByte - typeOffset - previousCommentLength);
    await raf.setPosition(await raf.length());
    await raf.writeString(docString + remainderCode);
    await raf.close();*/
    return '';
  }
}
