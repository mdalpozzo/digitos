enum OperationEnums { add, subtract, multiply, divide }

class Operations {
  static num handleOperation(OperationEnums operation, int a, int b) {
    switch (operation) {
      case OperationEnums.add:
        return add(a, b);
      case OperationEnums.subtract:
        return subtract(a, b);
      case OperationEnums.multiply:
        return multiply(a, b);
      case OperationEnums.divide:
        return divide(a, b);
      default:
        return 0;
    }
  }

  static int add(int a, int b) {
    return a + b;
  }

  static int subtract(int a, int b) {
    return a - b;
  }

  static int multiply(int a, int b) {
    return a * b;
  }

  static double divide(int a, int b) {
    return a / b;
  }
}
