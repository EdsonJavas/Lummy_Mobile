/// Simple Result/Either type for success/failure propagation without exceptions.
abstract class Result<T> {
  const Result();

  R when<R>({required R Function(T) success, required R Function(Failure) failure}) {
    final self = this;
    if (self is Success<T>) return success(self.value);
    if (self is FailureResult<T>) return failure(self.error);
    throw StateError('Unknown Result subtype');
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class FailureResult<T> extends Result<T> {
  final Failure error;
  const FailureResult(this.error);
}

/// Domain-level failure descriptor.
class Failure {
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.code, this.cause, this.stackTrace});

  @override
  String toString() => 'Failure(code: ' + (code ?? '-') + ', message: ' + message + ')';
}


