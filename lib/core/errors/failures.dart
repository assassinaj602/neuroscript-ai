/// Base failure class for typed domain errors across the app.
abstract class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'A local database error occurred.']);
}

class SeedImportFailure extends Failure {
  const SeedImportFailure([super.message = 'Failed to load seed lesson data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'The content failed grounding score verification.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed. Please check your internet.']);
}
