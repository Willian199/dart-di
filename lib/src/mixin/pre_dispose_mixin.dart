import 'dart:async';

/// Mixin to help to execute some code before the instance is disposed
///
/// Example:
/// ```dart
/// class MyService with PreDispose {
///
///   @override
///   FutureOr<void> onPreDispose(){
///     print('do something before dispose');
///   }
/// }
/// ```
mixin PreDispose {
  /// Execute some code before the instance is disposed
  FutureOr<void> onPreDispose();
}
