# ROADMAP

- [ ] Create packages for each language's annotator
- [ ] Include these packages as dependencies
- [ ] Test whether the annotators can be imported and used in code
- [ ] Closely examine the output of language-specific parsers
- [ ] Rewrite and complete writing parser code. Decide on what information 
is important to include in each docstring (class, function, enum)
- [ ] Finish implementing the abstract DocstringGenerator class and complete the language-specific overrides of the class 
- [ ] Use the overrides of DocstringGenerator in combination with onSave of vscode
in the activate function to allow the extension to generate the docstrings
- [ ] Write some tests using the examples + figure out how to provide the examples
- [ ] Publish the package, and celebrate 🎉