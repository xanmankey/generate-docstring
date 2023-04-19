/// Extension imports
import assert = require('assert');
import * as vscode from 'vscode';
import { spawn } from 'child_process';
const path = require('path');

/// The activate function runs once your extension has been activated
/// In my case, the activate function runs when the 'onDidSaveTextDocument' event is registered
export async function activate(context: vscode.ExtensionContext) {
	// Run code based on the 'onDidSaveTextDocument' activation event
	let listener = vscode.workspace.onDidSaveTextDocument((document: vscode.TextDocument) => {
		const savedFile:vscode.TextDocument = document;
		const filepath:string = document.uri.fsPath;
		const generatorPath = path.join(__dirname, '..', 'src', 'parser', 'docstring_generator', 'lib', 'src', 'docstring_generator.dart');
		// Generate docstrings depending on the language of the saved file
		switch (savedFile.languageId) {
			case 'dart':
				// Run the docstring generator on the file
				vscode.window.showInformationMessage('Generating docstrings for ' + filepath);
				const process = spawn('dart', [generatorPath, filepath]);
				process.stdout.on('data', (data) => {
					console.log(`stdout: ${data}`);
				});
				
				process.stderr.on('data', (data) => {
					console.error(`stderr: ${data}`);
				});

				process.on('close', (code) => {
					console.log(`child process exited with code ${code}`);
				});
				// Run the dart language formatter on the file
				vscode.commands.executeCommand('editor.action.formatDocument', vscode.Uri.file(filepath));
				break;
			case 'python':
				// UNIMPLEMENTED
				return;
			case 'java': 
				// UNIMPLEMENTED
				return;
			case 'javascript':
				// UNIMPLEMENTED
				return;
			default:
				// UNIMPLEMENTED
				return;
		}
	});
	context.subscriptions.push(listener);
}

/// Called when the extension is deactivated
export function deactivate() {}