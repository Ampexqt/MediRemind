/// Validation result for dose taking
class DoseValidationResult {
  final bool canTake;
  final String message;

  DoseValidationResult({required this.canTake, required this.message});
}
