/// An annotator for generating docstrings for js
/// classes, enums, and functions 
/// Note that this is written in ts although it won't 
/// (have impact on the actual js code itself)
/// to provide more information for the developers  
export class GenerateDocstring {
    description: String;
    codeExample: String | null;
    annotatorName: String;

    constructor(description:String, codeExample:String | null) {
        this.description = description;
        this.codeExample = codeExample;
        this.annotatorName = "GenerateDocstring";
    }
}