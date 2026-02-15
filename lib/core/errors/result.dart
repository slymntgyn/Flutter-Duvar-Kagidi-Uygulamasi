import 'failures.dart';

/// Basarili veya hatali sonuclari temsil eden sealed class.
/// Repository katmaninda kullanilir.
sealed class Result<T> {
  const Result();
}

/// Basarili sonuc, veriyi icerir.
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Hatali sonuc, Failure icerir.
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
