const _defaultMessage = 'PreConditionException not met.';

class PreConditionFailedException implements Exception {
  const PreConditionFailedException(this.message);

  final String? message;

  static String formattedMessage() => '$_defaultMessage {message}';

  @override
  String toString() => '$_defaultMessage $message';
}
