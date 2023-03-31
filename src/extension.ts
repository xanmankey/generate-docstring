// My own Typescript notes (I'll transfer these to a .md file afterwards):
// export: adds code to a module (scope)
// Function return type syntax is AFTER (), e.g. function myFunc(): string {}
// Use Fn + F5 to run the extension
// Help -> toggle developer tools is useful for debugging "vscode extension development host"
// To view console info, check the debug console in the host process
// Essentially in order to work with multiple languages, I need to have multiple packages
// that ALL get installed when the extension is installed

// CURRENT GOAL: 
// start reading about the parsers I chose and looking into necessary steps
// My three subgoals are:
// 1. figure out how to provide annotators for each language (if possible)
// 2. figure out how to retrieve offset and write above accordingly (if possible)
// 3. parsing and formatting (should be easy)

// TODO: 
// Left off trying to find documentation for the ast-parsers
// and trying to figure out how to write and export the annotaters

// Do I want to finish this? I probably could do it, but you don't 
// want your docstrings to just copy and paste code...
// I think I'm going to change it to keep the description, 
// add a parameter to allow passing an example call,
// and instead of copy and pasting the code, I'm going to 
// detail the arguments, their names, their types, 
// return value/types, etc

// What would be special about mine would be the decorators...

/// Extension imports
import assert = require('assert');
import * as vscode from 'vscode';
export { GenerateDocstring as generateDocstringDart } from './GenerateDocstring/dart/GenerateDocstring.dart';
export { GenerateDocstring as generateDocstringPython } from './GenerateDocstring/python/GenerateDocstring.py';
export { GenerateDocstring as generateDocstringJava } from './GenerateDocstring/java/GenerateDocstring.java';
export { GenerateDocstring as generateDocstringJavascript } from './GenerateDocstring/typescript/GenerateDocstring';

/// AST parsers
// https://www.npmjs.com/package/flutter-ast
import dartParser = require("flutter-ast");
// https://www.npmjs.com/package/@qoretechnologies/python-parser?activeTab=code
import pythonParser = require("@qoretechnologies/python-parser");
// https://www.npmjs.com/package/java-ast
import javaAst = require("java-ast");
import javaParser = require("java-parser");
// https://babeljs.io/docs/babel-parser
import jsParser = require("@babel/parser");

/// Globals
export let languageIds: String[];
interface DocstringDictionary {
	description: String,
	code: String,
}

/// An abstract class for providing the structure of an annotator 
/// This is provided as the recommended structure for annotators, 
/// and is used as guidelines for the implementation of annotators in:
/// - dart
/// - python
/// - java
/// - js   
const annotatorName:String = "GenerateDocstring";

export abstract class Annotator {
	/// The description to go above the code
	description: String;
	/// An optional code example of the code in use
	codeExample: String | null;
	/// The name of the annotator 
	annotatorName: String;

	constructor(description: String, codeExample: String | null, annotatorName: String) {
		this.description = description;
		this.codeExample = codeExample;
		this.annotatorName = annotatorName;
	}
}

/// An abstract class proposed for code retrieval methods
export abstract class RetrieveCode {
	languageId: String;
	document: vscode.TextDocument | null;
	// annotator: Annotator;
	code: String | null;

	// annotator: Annotator, 
	constructor(languageId: String, document: vscode.TextDocument | null, code:String | null) {
		/// Verify that the languageId is a language registered with vscode
		/// Otherwise, error out
		assert(languageIds.includes(languageId), "Invalid languageId");
		this.languageId = languageId;
		this.document = document;
		// this.annotator = annotator;
		this.code = code;
	}

	/// Retrieve the class code for a specified language 
	public abstract getClassCode(): DocstringDictionary[] | null;

	/// Retrieve the constructor code for a specified language 
	// Chose to cut this to simplify a bit 
	// abstract public getConstructorCode(): DocstringDictionary[] | null;

	/// Retrieve the function code for a specified language 
	public abstract getFunctionCode(): DocstringDictionary[] | null;

	/// Retrieve the enum code for a specified language 
	public abstract getEnumCode(): DocstringDictionary[] | null;

	/// Retrieve the mixin code for a specified language 
	// Chose to cut this to simplify a bit
	// abstract public getMixinCode(): DocstringDictionary[] | null;
}

/// An implementation of RetrieveCode for dart
export class RetrieveDartCode extends RetrieveCode {
	parseCode(): dartParser.DartResult {
		assert(this.document !== null);
		// Parse all the code
		var parsed:dartParser.DartResult = dartParser.parse(this.document.getText(undefined));
		return parsed;
	}
	getClassCode(): DocstringDictionary[] | null {
		var parsed:dartParser.DartResult = this.parseCode();
		var classes:dartParser.DartClass[] | undefined = parsed.file?.classes;
		// Filter to find the classes (if any) marked by the dart DocstringGenerator decorator
		if (classes !== null) {
			for (let astClass of classes!) {
				console.log(astClass);
			}
		}
		return null;
		// const annotatedClasses = classes?.filter((node) => {
		// 	if (node. === 'ClassDeclaration') {
		// 	  // Check if the class has the specific extension
		// 	  const hasExtension = node.decorators?.some(
		// 		(decorator) => decorator.name.name === 'SpecificExtension'
		// 	  );
		// 	  return hasExtension;
		// 	}
		//   });
		// return classes
	}
	// getConstructorCode(): DocstringDictionary[] | null {
	// 	return '';
	// }
	getFunctionCode(): DocstringDictionary[] | null {
		var parsed:dartParser.DartResult = this.parseCode();
		var functionCode:dartParser.DartClass[] | undefined = parsed.file?.classes;
		// Filter to find the classes (if any) marked by the dart DocstringGenerator decorator
		// code?.;
		return null;
	}
	getEnumCode(): DocstringDictionary[] | null {
		var parsed:dartParser.DartResult = this.parseCode();
		var enumCode:dartParser.DartClass[] | undefined = parsed.file?.classes;
		// Filter to find the classes (if any) marked by the dart DocstringGenerator decorator
		// code?.;
		return null;
	}
	// getMixinCode(): DocstringDictionary[] | null {
	// 	return '';
	// }
}

/// An implementation of RetrieveCode for python
export class RetrievePythonCode extends RetrieveCode {
	// Returns a dictionary of {description: String, code: String}
	parseCode(): pythonParser.Module {
		assert(this.document !== null);
		// Parse all the code
		var parsed:pythonParser.Module = pythonParser.parse(this.document.getText(undefined));
		return parsed;
		// var code:pythonParser.SyntaxNode[] = pythonParser.walk(parsed);
		// // Retrieve and return the code immediately following the decorators
		// var index:number = 0;
		// var annotatedCode:DocstringDictionary[] = [];
		// var decorators:pythonParser.SyntaxNode[] = code.filter((node) => {
		// 	index += 1;
		// 	if (node.type == "decorator" && node.decorator == PythonAnnotator.annotatorName) {
		// 		annotatedCode.push({description: node.args.values.arguments, code: code[index + 1].toString()});
		// 		return node;
		// 	}
		// });
		// // If no examples exist, return null
		// if (annotatedCode.length == 0) {
		// 	return null;
		// }
		// // Else, return the class code strings
		// return annotatedCode;
	}

	getClassCode(): DocstringDictionary[] | null {
		var parsed:pythonParser.Module = this.parseCode();
		// pythonParser.walk(parsed).filter(node => (node.type == "decorator" && ));
		for (let node in parsed) {
			console.log(node);
		}
		// // Retrieve all the class code annotated by the pythonAnnotator
		// var classCode:pythonParser.SyntaxNode[] = parsed.code.filter(node => (node.type == "class" && node.type.));
		// // If no examples exist, return null
		// if (classCode.length == 0) {
		// 	return null;
		// }
		// // Else, return the class code strings
		// return classCode;
		return null;
	}
	// getConstructorCode(): DocstringDictionary[] | null {
	// 	assert(this.document != null);
	// 	return '';
	// }
	getFunctionCode(): DocstringDictionary[] | null {
		var parsed:pythonParser.Module = this.parseCode();
		// pythonParser.walk(parsed).filter(node => (node.type == "decorator" && ));
		// Retrieve all the class code annotated by the pythonAnnotator
		// var functionCode:String[] = parsed.code.filter(node => (node.type == "class" && node.name.));
		// // If no examples exist, return null
		// if (functionCode.length == 0) {
		// 	return null;
		// }
		// // Else, return the class code strings
		// return functionCode;
		return null;
	}
	getEnumCode(): DocstringDictionary[] | null {
		var parsed:pythonParser.Module = this.parseCode();
		// pythonParser.walk(parsed).filter(node => (node.type == "decorator" && ));
		// Retrieve all the class code annotated by the pythonAnnotator
		// var enumCode:String[] = parsed.code.filter(node => (node.type == "class" && node.name.));
		// // If no examples exist, return null
		// if (enumCode.length == 0) {
		// 	return null;
		// }
		// // Else, return the class code strings
		// return enumCode;
		return null;
	}
	// getMixinCode(): DocstringDictionary[] | null {
	// 	assert(this.document != null);
	// 	return '';
	// }
}

/// An implementation of RetrieveCode for java
export class RetrieveJavaCode extends RetrieveCode {
	parseCode(): javaAst.ParseTree {
		assert(this.document !== null);
		// Parse all the code
		var parsed:javaAst.ParseTree = javaAst.parse(this.document.getText(undefined));
		return parsed;
		// var annotatedCode:DocstringDictionary[] = [];
		// // Retrieve and return the code immediately following the decorators
		// const visitor = {
		// 	visit(node: any) {
		// 		if (node.type === 'Annotation' && node.name.identifier === JavaAnnotator.annotatorName) {
		// 			annotatedCode.push(node.tryGetChild());
		// 		}
		// 	},
		// };
		// visit(ast, visitor);
		// parsed.tryGetChild();
		// var index:number = 0;
		// var annotatedCode:String[] = [];
		// var decorators:pythonParser.SyntaxNode[] = code.filter((node) => {
		// 	index += 1;
		// 	if (node.type == "decorator" && node.decorator == PythonAnnotator.annotatorName) {
		// 		annotatedCode.push(code[index + 1].toString());
		// 		return node;
		// 	}
		// });
		// // If no examples exist, return null
		// if (annotatedCode.length == 0) {
		// 	return null;
		// }
		// // Else, return the class code strings
		// return annotatedCode;
	}

	getClassCode(): DocstringDictionary[] | null {
		var parsed:javaAst.ParseTree = this.parseCode();
		if (parsed.children !== null) {
			for (let node of parsed.children!) {
				console.log(node);
			}
		} 
		return null;
	}
	// getConstructorCode(): DocstringDictionary[] | null {
	// 	return '';
	// }
	getFunctionCode(): DocstringDictionary[] | null {
		var parsed:javaAst.ParseTree = this.parseCode();
		return null;
	}
	getEnumCode(): DocstringDictionary[] | null {
		var parsed:javaAst.ParseTree = this.parseCode();
		return null;
	}
	// getMixinCode(): DocstringDictionary[] | null {
	// 	return '';
	// }
}

/// An implementation of RetrieveCode for javascript
export class RetrieveJavascriptCode extends RetrieveCode {
	parseCode(): DocstringDictionary[] | null {
		assert(this.document !== null);
		// Parse all the code
		var parsed = jsParser.parse(this.document.getText(undefined));
		return parsed;
		// var code:javaAst.CstChildrenDictionary = parsed
		// // Retrieve and return the code immediately following the decorators
		// var index:number = 0;
		// var annotatedCode:String[] = [];
		// var decorators:pythonParser.SyntaxNode[] = code.filter((node) => {
		// 	index += 1;
		// 	if (node.type == "decorator" && node.decorator == PythonAnnotator.annotatorName) {
		// 		annotatedCode.push(code[index + 1].toString());
		// 		return node;
		// 	}
		// });
		// // If no examples exist, return null
		// if (annotatedCode.length == 0) {
		// 	return null;
		// }
		// // Else, return the class code strings
		// return annotatedCode;
	}

	getClassCode(): DocstringDictionary[] | null {
		var parsed = this.parseCode();
		if (parsed !== null) {
			for (let node of parsed) {
				console.log(node);
			}
		}
		return null;
	}
	// getConstructorCode(): DocstringDictionary[] | null {
	// 	return '';
	// }
	getFunctionCode(): DocstringDictionary[] | null {
		var parsed = this.parseCode();
		return null;
	}
	getEnumCode(): DocstringDictionary[] | null {
		var parsed = this.parseCode();
		return null;
	}
	// getMixinCode(): DocstringDictionary[] | null {
	// 	return '';
	// }
}

/// An abstract function for generating the following docstring depending on the language
/*
export abstract class DocstringGenerator {
	codeRetriever: RetrieveCode;
	docstring: String | null;

	constructor(codeRetriever: RetrieveCode) {
		this.codeRetriever = codeRetriever;
		this.docstring = null;
	}

	/// A function for formatting the docstring depending on the language
	/// Returns a formatted version of the docstirng. 
	abstract public formatDocstring(): String;

	/// A function for composing the docstring out of the annotator decsription
	/// and retrieved code. Returns the docstring.
	public generateDocstring(): String | null {
		if (this.codeRetriever.code == null) {
			return;
		}
		this.docstring = this.codeRetriever.annotator.description + this.codeRetriever.;
	};

	/// A function for writing a docstring to the file
	/// With a proper offset and formatting  
	public writeDocstring(): void {
		// Open the file
		open(this.codeRetriever.document);
		// Write the docstring
		// Is there a universal way to do this?
		// TODO
	};
} 
*/

// Called when the extension is activated
export async function activate(context: vscode.ExtensionContext) {
	languageIds = await vscode.languages.getLanguages();

	/// Export the class so that it can be accessed from other parts of your extension
	// context.subscriptions.push(vscode.workspace.registerCompletionItemProvider(
	// 	{ language: 'dart' },
	// 	new RetrieveDartCode("dart", null, "myAnnotator", 'TEMP')
	//   ));

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "docstring-generator" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	let disposable = vscode.commands.registerCommand('docstring-generator.helloWorld', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		console.log("testing the console");
		vscode.window.showInformationMessage('Hello World from docstring_generator!');
	});

	context.subscriptions.push(disposable);

	let testDart = vscode.commands.registerCommand('docstring-generator.testDart', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		const activeFile = vscode.window.activeTextEditor?.document;
		const typedVariable: vscode.TextDocument | null = (activeFile === undefined) ? null : activeFile;
		new RetrieveDartCode("dart", typedVariable, null).getClassCode();
		vscode.window.showInformationMessage('Check console for dart class info');
	});

	context.subscriptions.push(testDart);

	let testPython = vscode.commands.registerCommand('docstring-generator.helloWorld', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		const activeFile = vscode.window.activeTextEditor?.document;
		const typedVariable: vscode.TextDocument | null = (activeFile === undefined) ? null : activeFile;
		new RetrievePythonCode("python", typedVariable, null).getClassCode();
		vscode.window.showInformationMessage('Check console for python class info');
	});

	context.subscriptions.push(testPython);

	let testJava = vscode.commands.registerCommand('docstring-generator.helloWorld', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		const activeFile = vscode.window.activeTextEditor?.document;
		const typedVariable: vscode.TextDocument | null = (activeFile === undefined) ? null : activeFile;
		new RetrieveJavaCode("java", typedVariable, null).getClassCode();
		vscode.window.showInformationMessage('Check console for java class info');
	});

	context.subscriptions.push(testJava);

	let testJavascript = vscode.commands.registerCommand('docstring-generator.helloWorld', () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		const activeFile = vscode.window.activeTextEditor?.document;
		const typedVariable: vscode.TextDocument | null = (activeFile === undefined) ? null : activeFile;
		new RetrieveJavascriptCode("javascript", typedVariable, null).getClassCode();
		vscode.window.showInformationMessage('Check console for js class info');
	});

	context.subscriptions.push(testJavascript);

	// let saveEvent = vscode.workspace.onWillSaveTextDocument((event) => {
	// 	// Check the language of the file
	// 	// Currently, only supporting the following languages
	// 	switch (event.document.languageId) {
	// 		case "dart": 
	// 			// Read and analyze dart file
	// 			event.document.
	// 			// Add dart docstring

	// 		case "python": 
	// 			// Read and analyze python file 

	// 			// Add python docstring

	// 		case "java": 
	// 			// Read and analyze java file

	// 			// Add java docstring

	// 		case "javascript": 
	// 			// Read and analyze js file
				
	// 			// Add js docstring
	// 	}
	// })
}

// Called when the extension is deactivated
export function deactivate() {}