# docstring-generator

#### A dart code generator for functions and classes. Generates a docstring composed of a String passed to the Docstring decorator and the code annotated on build, so if you want to add a Docstring so users or devs can view your implementation, you don't constantly have to manually update the docstring each time you make a change <br>

---

![](https://github.com/xanmankey/generate-docstring/blob/main/assets/DocstringGeneratorBefore.gif?raw=true)

Notice the apparent lack of docstrings... but just one **save** later... <br>

![](https://github.com/xanmankey/generate-docstring/blob/main/assets/DocstringGeneratorAfter.gif?raw=true)
![](https://github.com/xanmankey/generate-docstring/blob/main/assets/DocstringGeneratorPopup.gif?raw=true)

And voila!!! Docstrings galore <br>

Currently the following code segments are supported for annotation and generation (although they are largely untested): 
- Classes
- Functions/Methods
- Variables
- Enums

## Requirements

- Dart VSCode extension 
- Dart docstring_generator_annotator package: https://github.com/xanmankey/docstring_generator_annotator_dart.git (https://pub.dev/packages/docstring_generator_annotator)

## Usage

Docstring_generator is pretty simple to use; all you have to do is: 
- Install the dart vscode extension
- Install the docstring_generator_annotator package via ```dart pub add docstring_generator_annotator```
- Import the package via ```import 'package:docstring_generator_annotator/docstring_generator_annotator.dart'```
- Add annotators above your code segments, e.g. ```@GenerateDocstring(description: "your description", codeExample: ["as", "many", "optional", "code", "examples", "as", "you", "want!"])``` 
- Save your code and enjoy your docstrings!

## Extension Settings

Currently NA, however the extension does use the codemod (https://pub.dev/packages/codemod) dart package, so API could be potentially added for configuring codemod

## Concerns

- LACK of testing (I haven't written any tests for the extension yet); all a test would consist of though is taking an example file, one without generated docstrings and one with the ideal generated docstrings, running the generator, and then comparing the two
- ⚠️ This is my first vscode extension :)

## Future Plans

- Fleshing out the current codebase; any ideas or contributions are welcome!
- Potentially supporting other languages as well could be fun; I was thinking js, java, and python (although I haven't taken any action to support these languages as of yet)

## Release Notes

### 1.0.0

Initial release of docstring_generator (yay!)

---