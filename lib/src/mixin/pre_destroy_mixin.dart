import 'dart:async';

/// Mixin to help to execute some code before the instance is destroyed
///
/// Example:
/// ```dart
/// class MyService with PreDestroy {
///
///   @override
///   FutureOr<void> onPreDestroy(){
///     print('do something before destroy');
///   }
/// }
/// ```
mixin PreDestroy {
  /// Executes before the instance is destroyed
  FutureOr<void> onPreDestroy();
}
