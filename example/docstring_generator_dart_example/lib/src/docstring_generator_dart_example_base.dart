import 'dart:math';

import 'package:docstring_generator_annotator/docstring_generator_annotator.dart';

@GenerateDocstring(description: "A class for shapes")


/// ```
/// {Shape}
/// ```
/// ```
/// "A class for shapes"
/// ```
/// PROPERTIES
/// ```
/// {required String color}
/// ```
/// METHODS
/// ```
/// Shape Shape({required String color})
/// ```
/// ```
/// dynamic setColor(String color)
/// ```
/// EXAMPLES
class Shape {
  String color;
  Shape({required this.color});

  setColor(String color) {
    this.color = color;
  }
}

@GenerateDocstring(description: "A class for circles")


/// ```
/// {Circle}
/// ```
/// ```
/// "A class for circles"
/// ```
/// PROPERTIES
/// ```
/// {required int radius}
/// ```
/// ```
/// {required String color}
/// ```
/// METHODS
/// ```
/// Circle Circle({required int radius, required String color})
/// ```
/// ```
/// dynamic setRadius(dynamic radius)
/// ```
/// ```
/// dynamic calculateArea(double radius)
/// ```
/// EXAMPLES
class Circle extends Shape {
  int radius;

  Circle({required this.radius, required String color}) : super(color: color);

  setRadius(radius) {
    this.radius = radius;
  }

  @GenerateDocstring(
      description: "A function for calculating the area of ANY circle",
      codeExample: ["calculateArea(4) -> returns 8pi"])

  
/// ```
/// {calculateArea}
/// ```
/// ```
/// "A function for calculating the area of ANY circle"
/// ```
/// PARAMETERS
/// ```
/// double radius
/// ```
/// EXAMPLES
/// ```
/// "calculateArea(4) -> returns 8pi"
/// ```
static calculateArea(double radius) {
    double area = 2 * radius * pi;
    return area;
  }
}

@GenerateDocstring(
    description: "An enum for listing shapes", codeExample: ["Shapes.circle"])


/// ```
/// {Shapes}
/// ```
/// ```
/// "An enum for listing shapes"
/// ```
/// VALUES
/// ```
/// Shapes circle
/// ```
/// ```
/// Shapes square
/// ```
/// ```
/// Shapes triangle
/// ```
/// ```
/// Shapes dodecahedron
/// ```
/// EXAMPLES
/// ```
/// "Shapes.circle"
/// ```
enum Shapes { circle, square, triangle, dodecahedron }

@GenerateDocstring(description: "This is a very important num")
/// ```
/// {IMPORTANTNUM}
/// ```
/// ```
/// "This is a very important num"
/// ```
/// EXAMPLES
const int IMPORTANTNUM = 42;
