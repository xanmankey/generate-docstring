package GenerateDocstring.java;
/// An annotator for generating docstrings for java
/// classes, enums, and functions 
public class GenerateDocstring {
    String description;
    String codeExample = null;
    String annotatorName;

    public GenerateDocstring(String description, String codeExample) {
        this.description = description;
        this.codeExample = codeExample;
        this.annotatorName = "GenerateDocstring";
    }
}