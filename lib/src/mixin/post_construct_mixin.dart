import 'dart:async';

/// Mixin to help to execute some code after the instance is constructed
///
/// Example:
/// ```dart
/// class MyService with PostConstruct {
///
///   @override
///   FutureOr<void> onPostConstruct(){
///     print('do something after construct');
///   }
/// }
/// ```
mixin PostConstruct {
  /// Is executed after the instance is constructed.
  FutureOr<void> onPostConstruct();
}
