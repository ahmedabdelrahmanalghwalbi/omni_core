part of '../../../../omni_core.dart';

/// Operator of a derived or computed field.
///
/// The binary operators combine exactly two operands; the reducing ones apply
/// to the whole operand list and to the items of an aggregate.
enum CalculationOperator {
  add('add'),
  subtract('subtract'),
  multiply('multiply'),
  divide('divide'),
  sum('sum'),
  product('product'),
  min('min'),
  max('max'),
  avg('avg');

  const CalculationOperator(this.apiValue);

  final String apiValue;

  static CalculationOperator? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase().trim()) {
      case 'add':
      case 'plus':
      case '+':
        return CalculationOperator.add;
      case 'subtract':
      case 'minus':
      case '-':
        return CalculationOperator.subtract;
      case 'multiply':
      case 'times':
      case '*':
      case 'x':
        return CalculationOperator.multiply;
      case 'divide':
      case '/':
        return CalculationOperator.divide;
      case 'sum':
        return CalculationOperator.sum;
      case 'product':
        return CalculationOperator.product;
      case 'min':
      case 'minimum':
        return CalculationOperator.min;
      case 'max':
      case 'maximum':
        return CalculationOperator.max;
      case 'avg':
      case 'average':
      case 'mean':
        return CalculationOperator.avg;
      default:
        PackageLogger.warning('Unknown calculation operator: $value');
        return null;
    }
  }
}
