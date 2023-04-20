import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:codemod/codemod.dart';
import 'package:glob/glob.dart';
import 'package:docstring_generator_annotator/docstring_generator_annotator.dart';

/// A class for traversing the AST and finding annotated nodes
/// and then editing/generating the associated docstring accordingly
class DocstringGenerator extends GeneralizingAstVisitor<void>
    with AstVisitingSuggestor {
  /// Character before each line of a dart docstring
  String docstringChar = "\n///";

  @override
  bool shouldResolveAst(FileContext context) => true;

  /// A generalized function for building a docstring
  /// Each code segment will have individualized segments for a docstring,
  /// but the following properties are shared:
  /// [0]: name
  /// [1]: description
  /// [2]: 'EXAMPLES'
  /// [3+]: code formatting + actual examples
  /// [last]: '\n'
  /// Typically dynamic parts of the docstring will be inserted between
  /// the description and the 'EXAMPLES' label
  List<String> buildDocstring(
      String name, String description, List<String> examples) {
    List<String> docstring = [];
    docstring.add('/// ```');
    docstring.add('$docstringChar {$name}');
    docstring.add('$docstringChar ```');
    docstring.add('$docstringChar ```');
    docstring
        .add('$docstringChar ${description.replaceAll("/\n/g", "\n/// ")}');
    docstring.add('$docstringChar ```');
    docstring.add('$docstringChar EXAMPLES');
    for (String example in examples) {
      // Note that '```' is syntax used to render a docstring as code in the docstring
      docstring.add('$docstringChar ```');
      docstring.add("$docstringChar ${example.replaceAll("/\n/g", "\n/// ")}");
      docstring.add('$docstringChar ```');
    }
    docstring.add("\n");
    return docstring;
  }

  // TODO: elaborate on some of the generated docstrings
  // TODO: optimize and refactor code; add greater visitor coverage
  @override
  void visitAnnotation(Annotation node) {
    if (node.name.name == annotatorName) {
      final ArgumentList arguments = node.arguments!;
      String description =
          arguments.arguments.first.childEntities.last.toString();
      List<String> examples = (arguments.arguments.length == 2)
          ? arguments.arguments[1].childEntities.last
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", "")
              .split(",")
          : [];

      /// An index tracker for ensuring that the docstring is composed in the correct order
      int index = 6;
      switch (node.parent.runtimeType.toString()) {
        case 'ClassDeclarationImpl':
          ClassDeclaration classNode = node.parent as ClassDeclaration;
          List<String> docstring =
              buildDocstring(classNode.name.toString(), description, examples);
          ConstructorDeclaration? constructorNode =
              classNode.childEntities.whereType<ConstructorDeclaration>().first;
          docstring.insert(index, "$docstringChar PROPERTIES");
          index += 1;
          FormalParameterList parameters = constructorNode.parameters;
          for (FormalParameter parameter in parameters.parameters) {
            if (parameter.declaredElement != null) {
              docstring.insert(index, '$docstringChar ```');
              index += 1;
              docstring.insert(index,
                  '$docstringChar ${parameter.declaredElement!.declaration.getDisplayString(withNullability: true)}');
              index += 1;
              docstring.insert(index, '$docstringChar ```');
              index += 1;
            }
          }
          docstring.insert(index, "$docstringChar METHODS");
          index += 1;
          for (ClassMember member in classNode.members) {
            if (member.declaredElement != null) {
              if (member.declaredElement!.declaration != null) {
                if (member
                    .declaredElement!.declaration!.displayName.isNotEmpty) {
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                  docstring.insert(index,
                      '$docstringChar ${member.declaredElement!.declaration!.getDisplayString(withNullability: true)}');
                  index += 1;
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                }
              }
            }
          }
          int endOffset = classNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (classNode.documentationComment != null)
              ? classNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
        case 'MixinDeclarationImpl':
          MixinDeclaration classNode = node.parent as MixinDeclaration;
          List<String> docstring =
              buildDocstring(classNode.name.toString(), description, examples);
          ConstructorDeclaration? constructorNode =
              classNode.childEntities.whereType<ConstructorDeclaration>().first;
          docstring.insert(index, "$docstringChar PROPERTIES");
          index += 1;
          if (constructorNode != null) {
            FormalParameterList? parameters = constructorNode.parameters;
            if (parameters != null) {
              for (FormalParameter parameter in parameters.parameters) {
                if (parameter.declaredElement != null) {
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                  docstring.insert(index,
                      '$docstringChar ${parameter.declaredElement!.declaration.getDisplayString(withNullability: true)}');
                  index += 1;
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                }
              }
            }
          }
          docstring.insert(index, "$docstringChar METHODS");
          index += 1;
          for (ClassMember member in classNode.members) {
            if (member.declaredElement != null) {
              if (member.declaredElement!.declaration != null) {
                if (member
                    .declaredElement!.declaration!.displayName.isNotEmpty) {
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                  docstring.insert(index,
                      '$docstringChar ${member.declaredElement!.declaration!.getDisplayString(withNullability: true)}');
                  index += 1;
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                }
              }
            }
          }
          int endOffset = classNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (classNode.documentationComment != null)
              ? classNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
        case 'ExtensionDeclarationImpl':
          ExtensionDeclaration classNode = node.parent as ExtensionDeclaration;
          List<String> docstring =
              buildDocstring(classNode.name.toString(), description, examples);
          ConstructorDeclaration? constructorNode =
              classNode.childEntities.whereType<ConstructorDeclaration>().first;
          docstring.insert(index, "$docstringChar PROPERTIES");
          index += 1;
          if (constructorNode != null) {
            FormalParameterList? parameters = constructorNode.parameters;
            if (parameters != null) {
              for (FormalParameter parameter in parameters.parameters) {
                if (parameter.declaredElement != null) {
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                  docstring.insert(index,
                      '$docstringChar ${parameter.declaredElement!.declaration.getDisplayString(withNullability: true)}');
                  index += 1;
                  docstring.insert(index, '$docstringChar ```');
                  index += 1;
                }
              }
            }
          }
          docstring.insert(index, "$docstringChar METHODS");
          index += 1;
          for (ClassMember member in classNode.members) {
            if (member.declaredElement != null) {
              if (member.declaredElement!.declaration != null) {
                if (member
                    .declaredElement!.declaration!.displayName.isNotEmpty) {
                  docstring.insert(index,
                      '\n/// ${member.declaredElement!.declaration!.displayName}');
                  index += 1;
                }
              }
            }
          }
          int endOffset = classNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (classNode.documentationComment != null)
              ? classNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
        case 'FunctionDeclarationImpl':
          FunctionDeclaration functionNode = node.parent as FunctionDeclaration;
          List<String> docstring = buildDocstring(
              functionNode.name.toString(), description, examples);
          docstring.insert(index, "$docstringChar PARAMETERS");
          index += 1;
          FormalParameterList? parameters =
              functionNode.functionExpression.parameters;
          if (parameters != null) {
            for (FormalParameter parameter in parameters.parameters) {
              if (parameter.declaredElement != null) {
                docstring.insert(index, '$docstringChar ```');
                index += 1;
                docstring.insert(index,
                    '$docstringChar ${parameter.declaredElement!.declaration.getDisplayString(withNullability: true)}');
                index += 1;
                docstring.insert(index, '$docstringChar ```');
                index += 1;
              }
            }
          }
          int endOffset = functionNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (functionNode.documentationComment != null)
              ? functionNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
        case 'MethodDeclarationImpl':
          MethodDeclaration functionNode = node.parent as MethodDeclaration;
          List<String> docstring = buildDocstring(
              functionNode.name.toString(), description, examples);
          docstring.insert(index, "$docstringChar PARAMETERS");
          index += 1;
          FormalParameterList? parameters = functionNode.parameters;
          if (parameters != null) {
            for (FormalParameter parameter in parameters.parameters) {
              if (parameter.declaredElement != null) {
                docstring.insert(index, '$docstringChar ```');
                index += 1;
                docstring.insert(index,
                    '$docstringChar ${parameter.declaredElement!.declaration.getDisplayString(withNullability: true)}');
                index += 1;
                docstring.insert(index, '$docstringChar ```');
                index += 1;
              }
            }
          }
          int endOffset = functionNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (functionNode.documentationComment != null)
              ? functionNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
        case 'EnumDeclarationImpl':
          EnumDeclaration enumNode = node.parent as EnumDeclaration;
          List<String> docstring =
              buildDocstring(enumNode.name.toString(), description, examples);
          NodeList<EnumConstantDeclaration>? constants = enumNode.constants;
          docstring.insert(index, "$docstringChar VALUES");
          index += 1;
          if (constants != null) {
            for (EnumConstantDeclaration constant in constants) {
              if (constant.declaredElement != null) {
                if (constant.declaredElement!.declaration != null) {
                  if (constant
                      .declaredElement!.declaration!.displayName.isNotEmpty) {
                    docstring.insert(index, '$docstringChar ```');
                    index += 1;
                    docstring.insert(index,
                        '$docstringChar ${constant.declaredElement!.declaration!.getDisplayString(withNullability: true)}');
                    index += 1;
                    docstring.insert(index, '$docstringChar ```');
                    index += 1;
                  }
                } else if (constant.declaredElement!.name != null) {
                  if (constant.declaredElement!.name!.isNotEmpty) {
                    docstring.insert(index,
                        '$docstringChar ${constant.declaredElement!.name}');
                    index += 1;
                  }
                }
              }
            }
          }
          int endOffset = enumNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (enumNode.documentationComment != null)
              ? enumNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
        case 'VariableDeclarationImpl':
          VariableDeclaration variableNode = node.parent as VariableDeclaration;
          List<String> docstring = [];
          if (variableNode.declaredElement != null) {
            docstring = buildDocstring(
                variableNode.declaredElement!
                    .getDisplayString(withNullability: true),
                description,
                examples);
          } else {
            docstring = buildDocstring(
                variableNode.name.toString(), description, examples);
          }
          int endOffset = variableNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (variableNode.documentationComment != null)
              ? variableNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
        case 'TopLevelVariableDeclarationImpl':
          TopLevelVariableDeclaration variableNode =
              node.parent as TopLevelVariableDeclaration;
          List<String> docstring = [];
          if (variableNode.declaredElement != null) {
            docstring = buildDocstring(
                variableNode.declaredElement!
                    .getDisplayString(withNullability: true),
                description,
                examples);
          } else {
            docstring = buildDocstring(
                variableNode.variables.variables.first.name.toString(),
                description,
                examples);
          }
          int endOffset = variableNode.firstTokenAfterCommentAndMetadata.offset;
          int startOffset = (variableNode.documentationComment != null)
              ? variableNode.documentationComment!.offset
              : endOffset - 1;
          yieldPatch(docstring.join(), startOffset, endOffset);
          break;
      }
    }
  }
}

/// A function for generating docstrings
Future<void> generateDocstring(String filepath) async {
  // Create context and session for ast analysis
  AnalysisContextCollection collection =
      AnalysisContextCollection(includedPaths: [filepath]);
  AnalysisContext context = collection.contextFor(filepath);
  AnalysisSession session = context.currentSession;

  // Retrieve ast
  var parsed = await session.getResolvedUnit(filepath);
  CompilationUnit? unit;
  if (parsed is ResolvedUnitResult) {
    unit = parsed.unit;
  }

  // Visit annotated nodes
  // Compose docstring
  // Automatically add docstring
  // --yes-to-all is enabled because if a user doesn't want docstrings,
  // they just shouldn't annotate or should disable the extension
  await runInteractiveCodemod(
    filePathsFromGlob(Glob(filepath)),
    DocstringGenerator(),
    args: ['--yes-to-all'],
  );
}

/// Entry point
void main(List<String> args) async {
  if (File(args[0]).existsSync()) {
    await generateDocstring(args[0]);
  }
}
