local M = {}
print("LOADING java keyword help")

-- Java keyword documentation in jdtls style
local help_text = {
  -- Keywords
  ['enum'] = {
    lines = {
      "enum",
      "",
      "Declares an enumeration type (a special class type that represents a group of constants).",
      "",
      "public enum Color {",
      "    RED, GREEN, BLUE",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['class'] = {
    lines = {
      "class",
      "",
      "Defines a class, the basic building block of object-oriented programming in Java.",
      "",
      "public class MyClass {",
      "    // fields and methods",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['interface'] = {
    lines = {
      "interface",
      "",
      "Defines a contract that classes can implement. All methods are implicitly public and abstract.",
      "",
      "public interface Drawable {",
      "    void draw();",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  -- Access Modifiers
  ['public'] = {
    lines = {
      "public - Access Modifier",
      "",
      "The member is accessible from any other class.",
      "",
      "Can be applied to:",
      "  - Classes",
      "  - Methods",
      "  - Fields",
      "  - Constructors",
    },
  },

  ['private'] = {
    lines = {
      "private - Access Modifier",
      "",
      "The member is accessible only within the same class.",
      "",
      "Can be applied to:",
      "  - Methods",
      "  - Fields",
      "  - Constructors",
      "  - Nested classes",
    },
  },

  ['protected'] = {
    lines = {
      "protected - Access Modifier",
      "",
      "The member is accessible within the same package and by subclasses.",
      "",
      "Can be applied to:",
      "  - Methods",
      "  - Fields",
      "  - Constructors",
    },
  },

  -- Non-access Modifiers
  ['static'] = {
    lines = {
      "static - Modifier",
      "",
      "Indicates that the member belongs to the class itself rather than to instances of the class.",
      "",
      "Can be applied to:",
      "  - Fields (class variables)",
      "  - Methods (class methods)",
      "  - Nested classes",
      "  - Initialization blocks",
      "",
      "public static final int MAX_VALUE = 100;",
      "public static void main(String[] args) { }",
    },
    code_start = 11,
    code_end = 12,
  },

  ['final'] = {
    lines = {
      "final - Modifier",
      "",
      "Prevents modification, extension, or overriding.",
      "",
      "When applied to:",
      "  - Variables: Cannot be reassigned (constant)",
      "  - Methods: Cannot be overridden by subclasses",
      "  - Classes: Cannot be extended",
      "",
      "public final class ImmutableClass { }",
      "public final int CONSTANT = 42;",
    },
    code_start = 10,
    code_end = 11,
  },

  ['abstract'] = {
    lines = {
      "abstract - Modifier",
      "",
      "Declares that something is incomplete and must be implemented or extended.",
      "",
      "Can be applied to:",
      "  - Classes: Cannot be instantiated, may contain abstract methods",
      "  - Methods: Must be implemented by subclasses",
      "",
      "public abstract class Shape {",
      "    public abstract double area();",
      "}",
    },
    code_start = 9,
    code_end = 11,
  },

  ['synchronized'] = {
    lines = {
      "synchronized - Modifier",
      "",
      "Ensures thread-safe access. Only one thread can execute the synchronized block at a time.",
      "",
      "Can be applied to:",
      "  - Methods",
      "  - Code blocks",
      "",
      "public synchronized void increment() {",
      "    count++;",
      "}",
    },
    code_start = 9,
    code_end = 11,
  },

  ['volatile'] = {
    lines = {
      "volatile - Modifier",
      "",
      "Indicates that a variable's value may be modified by different threads.",
      "Ensures visibility of changes across threads and prevents caching.",
      "",
      "private volatile boolean running = true;",
    },
    code_start = 6,
    code_end = 6,
  },

  ['transient'] = {
    lines = {
      "transient - Modifier",
      "",
      "Indicates that a field should not be serialized.",
      "Used with Serializable classes to exclude sensitive or derivable data.",
      "",
      "private transient String password;",
    },
    code_start = 6,
    code_end = 6,
  },

  ['native'] = {
    lines = {
      "native - Modifier",
      "",
      "Indicates that a method is implemented in platform-specific code (typically C/C++).",
      "",
      "public native void performNativeOperation();",
    },
    code_start = 5,
    code_end = 5,
  },

  -- Class Relationships
  ['extends'] = {
    lines = {
      "extends",
      "",
      "Establishes inheritance. A class inherits fields and methods from its superclass.",
      "",
      "public class Dog extends Animal {",
      "    // Dog inherits from Animal",
      "}",
      "",
      "Note: Java supports single inheritance only.",
    },
    code_start = 5,
    code_end = 7,
  },

  ['implements'] = {
    lines = {
      "implements",
      "",
      "Indicates that a class provides implementations for all methods of an interface.",
      "",
      "public class Circle implements Shape {",
      "    public double area() {",
      "        return Math.PI * radius * radius;",
      "    }",
      "}",
      "",
      "Note: A class can implement multiple interfaces.",
    },
    code_start = 5,
    code_end = 9,
  },

  -- Exception Handling
  ['throw'] = {
    lines = {
      "throw",
      "",
      "Explicitly throws an exception.",
      "",
      "if (age < 0) {",
      "    throw new IllegalArgumentException(\"Age cannot be negative\");",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['throws'] = {
    lines = {
      "throws",
      "",
      "Declares that a method may throw one or more checked exceptions.",
      "",
      "public void readFile(String path) throws IOException {",
      "    // method implementation",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['try'] = {
    lines = {
      "try",
      "",
      "Begins an exception handling block. Code that may throw exceptions is placed here.",
      "",
      "try {",
      "    // code that may throw exception",
      "} catch (Exception e) {",
      "    // handle exception",
      "}",
    },
    code_start = 5,
    code_end = 9,
  },

  ['catch'] = {
    lines = {
      "catch",
      "",
      "Handles specific exceptions thrown in the try block.",
      "",
      "try {",
      "    // risky code",
      "} catch (IOException e) {",
      "    System.err.println(\"IO Error: \" + e.getMessage());",
      "}",
      "",
      "Note: Multiple catch blocks can handle different exception types.",
    },
    code_start = 5,
    code_end = 9,
  },

  ['finally'] = {
    lines = {
      "finally",
      "",
      "Always executes after try/catch blocks, regardless of whether an exception occurred.",
      "Typically used for cleanup operations.",
      "",
      "try {",
      "    // open resource",
      "} finally {",
      "    // close resource (always executed)",
      "}",
    },
    code_start = 6,
    code_end = 10,
  },

  -- Control Flow
  ['if'] = {
    lines = {
      "if",
      "",
      "Conditional statement that executes code if the condition evaluates to true.",
      "",
      "if (x > 0) {",
      "    System.out.println(\"Positive\");",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['else'] = {
    lines = {
      "else",
      "",
      "Provides an alternative branch when the if condition is false.",
      "",
      "if (x > 0) {",
      "    System.out.println(\"Positive\");",
      "} else {",
      "    System.out.println(\"Non-positive\");",
      "}",
    },
    code_start = 5,
    code_end = 9,
  },

  ['switch'] = {
    lines = {
      "switch",
      "",
      "Multi-way branch statement that selects one of many code blocks to execute.",
      "",
      "switch (day) {",
      "    case MONDAY:",
      "        System.out.println(\"Start of week\");",
      "        break;",
      "    case FRIDAY:",
      "        System.out.println(\"End of week\");",
      "        break;",
      "    default:",
      "        System.out.println(\"Midweek\");",
      "}",
    },
    code_start = 5,
    code_end = 14,
  },

  ['case'] = {
    lines = {
      "case",
      "",
      "Defines a branch in a switch statement.",
      "",
      "case 1:",
      "    doSomething();",
      "    break;",
    },
    code_start = 5,
    code_end = 7,
  },

  ['default'] = {
    lines = {
      "default",
      "",
      "Defines the default branch in a switch statement, executed when no case matches.",
      "",
      "default:",
      "    handleDefault();",
    },
    code_start = 5,
    code_end = 6,
  },

  ['for'] = {
    lines = {
      "for",
      "",
      "Loop with initialization, condition, and update expressions.",
      "",
      "for (int i = 0; i < 10; i++) {",
      "    System.out.println(i);",
      "}",
      "",
      "Enhanced for loop (for-each):",
      "for (String item : collection) {",
      "    System.out.println(item);",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['while'] = {
    lines = {
      "while",
      "",
      "Loop that executes while the condition is true. Checks condition before each iteration.",
      "",
      "while (i < 10) {",
      "    System.out.println(i);",
      "    i++;",
      "}",
    },
    code_start = 5,
    code_end = 8,
  },

  ['do'] = {
    lines = {
      "do",
      "",
      "Loop that executes at least once, then continues while the condition is true.",
      "",
      "do {",
      "    System.out.println(i);",
      "    i++;",
      "} while (i < 10);",
    },
    code_start = 5,
    code_end = 8,
  },

  ['break'] = {
    lines = {
      "break",
      "",
      "Exits from the innermost loop or switch statement.",
      "",
      "for (int i = 0; i < 10; i++) {",
      "    if (i == 5) break;",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['continue'] = {
    lines = {
      "continue",
      "",
      "Skips the rest of the current iteration and continues with the next iteration.",
      "",
      "for (int i = 0; i < 10; i++) {",
      "    if (i % 2 == 0) continue;",
      "    System.out.println(i);  // only odd numbers",
      "}",
    },
    code_start = 5,
    code_end = 8,
  },

  -- Return and Value
  ['void'] = {
    lines = {
      "void",
      "",
      "Indicates that a method does not return a value.",
      "",
      "public void printMessage() {",
      "    System.out.println(\"Hello\");",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  ['return'] = {
    lines = {
      "return",
      "",
      "Exits from the current method and optionally returns a value.",
      "",
      "public int sum(int a, int b) {",
      "    return a + b;",
      "}",
    },
    code_start = 5,
    code_end = 7,
  },

  -- Object Creation
  ['new'] = {
    lines = {
      "new",
      "",
      "Creates a new instance of a class (object) or array.",
      "",
      "MyClass obj = new MyClass();",
      "int[] array = new int[10];",
    },
    code_start = 5,
    code_end = 6,
  },

  ['this'] = {
    lines = {
      "this",
      "",
      "References the current object instance.",
      "",
      "Common uses:",
      "  - Distinguish instance variables from parameters",
      "  - Call other constructors",
      "  - Pass current object as parameter",
      "",
      "public MyClass(int value) {",
      "    this.value = value;  // distinguish field from parameter",
      "}",
    },
    code_start = 10,
    code_end = 12,
  },

  ['super'] = {
    lines = {
      "super",
      "",
      "References the parent class.",
      "",
      "Common uses:",
      "  - Call parent class constructor",
      "  - Access parent class methods",
      "  - Access parent class fields",
      "",
      "public class Dog extends Animal {",
      "    public Dog() {",
      "        super();  // call parent constructor",
      "    }",
      "}",
    },
    code_start = 10,
    code_end = 14,
  },

  -- Special Values
  ['null'] = {
    lines = {
      "null",
      "",
      "Represents the absence of an object reference.",
      "",
      "String str = null;",
      "if (obj == null) {",
      "    // handle null case",
      "}",
      "",
      "Note: Attempting to use null references causes NullPointerException.",
    },
    code_start = 5,
    code_end = 8,
  },

  ['true'] = {
    lines = {
      "true - boolean literal",
      "",
      "Represents the boolean value true.",
      "",
      "boolean flag = true;",
      "if (true) {",
      "    // always executes",
      "}",
    },
    code_start = 5,
    code_end = 8,
  },

  ['false'] = {
    lines = {
      "false - boolean literal",
      "",
      "Represents the boolean value false.",
      "",
      "boolean flag = false;",
      "if (false) {",
      "    // never executes",
      "}",
    },
    code_start = 5,
    code_end = 8,
  },

  -- Package and Import
  ['package'] = {
    lines = {
      "package",
      "",
      "Declares the package to which the class belongs.",
      "Must be the first statement in a Java file (except comments).",
      "",
      "package com.example.myapp;",
    },
    code_start = 6,
    code_end = 6,
  },

  ['import'] = {
    lines = {
      "import",
      "",
      "Imports classes or entire packages for use in the current file.",
      "",
      "import java.util.List;",
      "import java.util.ArrayList;",
      "import java.util.*;  // import all classes from package",
    },
    code_start = 5,
    code_end = 7,
  },

  -- Primitive Types
  ['int'] = {
    lines = {
      "int - Primitive Type",
      "",
      "32-bit signed integer.",
      "",
      "Range: -2,147,483,648 to 2,147,483,647",
      "Default value: 0",
      "",
      "int count = 42;",
    },
    code_start = 8,
    code_end = 8,
  },

  ['long'] = {
    lines = {
      "long - Primitive Type",
      "",
      "64-bit signed integer.",
      "",
      "Range: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807",
      "Default value: 0L",
      "Literal suffix: L or l",
      "",
      "long bigNumber = 9876543210L;",
    },
    code_start = 9,
    code_end = 9,
  },

  ['short'] = {
    lines = {
      "short - Primitive Type",
      "",
      "16-bit signed integer.",
      "",
      "Range: -32,768 to 32,767",
      "Default value: 0",
      "",
      "short smallNumber = 1000;",
    },
    code_start = 8,
    code_end = 8,
  },

  ['byte'] = {
    lines = {
      "byte - Primitive Type",
      "",
      "8-bit signed integer.",
      "",
      "Range: -128 to 127",
      "Default value: 0",
      "",
      "byte b = 100;",
    },
    code_start = 8,
    code_end = 8,
  },

  ['float'] = {
    lines = {
      "float - Primitive Type",
      "",
      "32-bit IEEE 754 floating point.",
      "",
      "Precision: ~6-7 decimal digits",
      "Default value: 0.0f",
      "Literal suffix: F or f",
      "",
      "float temperature = 98.6f;",
    },
    code_start = 9,
    code_end = 9,
  },

  ['double'] = {
    lines = {
      "double - Primitive Type",
      "",
      "64-bit IEEE 754 floating point.",
      "",
      "Precision: ~15 decimal digits",
      "Default value: 0.0d",
      "Literal suffix: D or d (optional)",
      "",
      "double pi = 3.14159265359;",
    },
    code_start = 9,
    code_end = 9,
  },

  ['char'] = {
    lines = {
      "char - Primitive Type",
      "",
      "16-bit Unicode character.",
      "",
      "Range: '\\u0000' to '\\uffff' (0 to 65,535)",
      "Default value: '\\u0000' (null character)",
      "",
      "char letter = 'A';",
      "char unicode = '\\u0041';  // also 'A'",
    },
    code_start = 8,
    code_end = 9,
  },

  ['boolean'] = {
    lines = {
      "boolean - Primitive Type",
      "",
      "Represents true or false values.",
      "",
      "Values: true, false",
      "Default value: false",
      "",
      "boolean isValid = true;",
    },
    code_start = 8,
    code_end = 8,
  },

  -- Special Keywords
  ['instanceof'] = {
    lines = {
      "instanceof - Type Comparison Operator",
      "",
      "Tests whether an object is an instance of a specific class or interface.",
      "Returns boolean (true or false).",
      "",
      "if (obj instanceof String) {",
      "    String str = (String) obj;",
      "}",
    },
    code_start = 6,
    code_end = 8,
  },

  ['assert'] = {
    lines = {
      "assert",
      "",
      "Tests assumptions during development. Throws AssertionError if condition is false.",
      "Disabled by default; enable with `-ea` JVM flag.",
      "",
      "assert value >= 0 : \"Value must be non-negative\";",
    },
    code_start = 6,
    code_end = 6,
  },
}

-- List of all keywords to check
M.keywords = {
  'enum', 'class', 'interface', 'public', 'private', 'protected',
  'static', 'final', 'abstract', 'synchronized', 'volatile', 'transient', 'native',
  'extends', 'implements', 'throw', 'throws', 'try', 'catch', 'finally',
  'if', 'else', 'switch', 'case', 'default', 'for', 'while', 'do', 'break', 'continue',
  'void', 'return', 'new', 'this', 'super', 'null', 'true', 'false',
  'package', 'import',
  'int', 'long', 'short', 'byte', 'float', 'double', 'char', 'boolean',
  'instanceof', 'assert'
}

local function to_markdown(help)
  local out = {}

  -- Header (symbol + title)
  table.insert(out, " **" .. help.lines[1] .. "**")
  table.insert(out, "")

  local in_code = false

  for i = 2, #help.lines do
    if help.code_start and i == help.code_start then
      table.insert(out, "```java")
      in_code = true
    end

    table.insert(out, help.lines[i])

    if help.code_end and i == help.code_end then
      table.insert(out, "```")
      in_code = false
    end
  end

  return out
end

-- Show help in a floating window (true JDTLS parity)
function M.show_help(word)
  local help = help_text[word]
  if not help then
    return false
  end

  local md_lines = to_markdown(help)

  local win, buf = vim.lsp.util.open_floating_preview(
    md_lines,
    "markdown",
    {
      border = "rounded",
      focusable = false,
      close_events = {
        "CursorMoved",
        "CursorMovedI",
        "BufLeave",
        "InsertEnter",
      },
    }
  )

  return true
end

function M.try_show_keyword()
  local word = vim.fn.expand("<cword>")
  if vim.tbl_contains(M.keywords, word) then
    return M.show_help(word)
  end
  return false
end

return M
