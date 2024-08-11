// Import necessary packages
// ignore_for_file: unreachable_from_main, avoid_print

import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

// Define a custom service class
class MyService with PostConstruct, PreDispose {
  MyService(this.name);
  // Variables to demonstrate lifecycle methods
  final String name;

  @override
  void onPostConstruct() {
    print('MyService $name initialized.');
  }

  void doSomething() {
    print('MyService $name is doing something...');
  }

  @override
  void onPreDispose() {
    print('MyService $name is about to be disposed.');
  }
}

// Define a custom service class with PostConstruct
class MyLoggingService with PostConstruct {
  MyLoggingService(this.service);
  // Variables to demonstrate dependency injection
  final MyService service;

  @override
  void onPostConstruct() {
    print('MyLoggingService initialized.');
  }

  void logSomething() {
    print('MyLoggingService logging: ${service.name}');
  }
}

// Define a module that contains multiple services
class MyModule with DDIModule, PreDestroy {
  void executar(String value) => print(value);

  @override
  Future<void> onPostConstruct() async {
    // Register MyService with a custom qualifier
    registerSingleton<MyService>(
      () => MyService('1st Instance'),
      qualifier: 'MyService1',
    );

    // Register another instance of MyService with a different qualifier
    registerApplication<MyService>(
      () => MyService('2nd Instance'),
      qualifier: 'MyService2',
    );

    // Register MyLoggingService with dependency on MyService1
    registerSession<MyLoggingService>(
      () => MyLoggingService(ddi.get(qualifier: 'MyService1')),
      qualifier: 'MyLoggingSession',
      interceptors: [CustomInterceptor.new],
    );

    // Register MyLoggingService with dependency on MyService2
    registerDependent<MyLoggingService>(
      () => MyLoggingService(ddi.get(qualifier: 'MyService2')),
      qualifier: 'MyLoggingDependent',
      interceptors: [CustomInterceptor.new],
    );

    // For events and streams, use the `ddiEvent` and `ddiStream` respectively
    ddiEvent.subscribe<String>(
      executar,
      qualifier: 'EventService',
    );

    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  FutureOr<void> onPreDestroy() {
    ddiEvent.unsubscribe(
      executar,
      qualifier: 'EventService',
    );
  }
}

class CustomInterceptor extends DDIInterceptor<MyLoggingService> {
  @override
  MyLoggingService aroundConstruct(MyLoggingService instance) {
    ddiEvent.fire<String>(
      'Construct Intercepted: $instance',
      qualifier: 'EventService',
    );

    return instance;
  }

  @override
  void aroundDispose(MyLoggingService? instance) {
    ddiEvent.fire<String>(
      'Disposing: $instance',
      qualifier: 'EventService',
    );
  }

  @override
  void aroundDestroy(MyLoggingService? instance) {
    ddiEvent.fire<String>(
      'Destroyed: $instance',
      qualifier: 'EventService',
    );
  }
}

// Main function where the code execution starts
void main() async {
  // Register services from MyModule
  await ddi.registerSingleton(MyModule.new);

  // Get an instance of MyService with qualifier
  final MyService myService1 = ddi.get(qualifier: 'MyService1');

  // Call a method on the MyService instance
  myService1.doSomething();

  // Get another instance of MyService with different qualifier
  final myService2 = ddi.get<MyService>(qualifier: 'MyService2');
  myService2.doSomething();

  // Get an instance of MyLoggingService with qualifier
  final MyLoggingService myLoggingSession =
      ddi.get(qualifier: 'MyLoggingSession');

  // Call a method on the MyLoggingService instance
  myLoggingSession.logSomething();

  // Get another instance of MyLoggingService with different qualifier
  final MyLoggingService myLoggingDependent =
      ddi.get(qualifier: 'MyLoggingDependent');
  myLoggingDependent.logSomething();

  // Add a decorator to uppercase strings
  String uppercaseDecorator(String str) => str.toUpperCase();
  ddi.registerObject('Hello World',
      qualifier: 'authored', decorators: [uppercaseDecorator]);

  // Will return HELLO WORLD
  print(ddi.get(qualifier: 'authored'));

  // Dispose of the MyModule instance, will also dispose of MyService.
  // MyLoggingService will not be disposed. Because it is a Dependent bean
  await ddi.dispose<MyModule>();

  // Destroy of the MyModule instance, will also destroy MyService and MyLoggingService
  await ddi.destroy<MyModule>();

  await Future.delayed(const Duration(seconds: 1));
}
