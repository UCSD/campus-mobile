// Test file for formatting comparison
class TestFormatting {
  void testMethod() {
    // This is a very long line that should exceed 100 characters to test whether it gets automatically wrapped when we save the file
    String veryLongString =
        "This is an extremely long string that definitely exceeds the 100 character limit that we have set for our formatting standards and should be wrapped automatically if our formatting is working correctly";
    // Short line
    print("Hello");

    // Another long line for testing
    Map<String, dynamic> testMap = {
      "key1": "value1",
      "key2": "value2",
      "key3": "value3",
      "key4": "value4",
      "key5": "value5",
      "key6": "value6",
    };
  }
}
