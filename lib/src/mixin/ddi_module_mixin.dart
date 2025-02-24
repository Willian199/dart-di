import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// Mixin to make it easy to create modules
///
/// Example:
/// ```dart
/// class MyModule with DDIModule {
///   @override
///   FutureOr<void> onPostConstruct(){
///     print('do something after construct or register the childrens beans');
///
///     registerApplication<MyService>(MyService.new);
///     registerSingleton<MyRepository>(MyRepository.new);
///     registerDependent<MyCase>(MyCase.new);
///   }
/// }
/// ```

mixin DDIModule implements PostConstruct {
  Object? _internalQualifier;

  Object get moduleQualifier => _internalQualifier ?? runtimeType;

  set moduleQualifier(Object value) {
    _internalQualifier = value;
  }

  Set<Object> get children => ddi.getChildren(qualifier: moduleQualifier);

  /// Registers an instance as a Singleton.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to vinculate multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> registerSingleton<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    Set<Object>? interceptors,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    Set<Object>? children,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.registerSingleton<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an instance as an Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to vinculate multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> registerApplication<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    Set<Object>? interceptors,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    Set<Object>? children,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.registerApplication<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an instance as a Session.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to vinculate multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> registerSession<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    Set<Object>? interceptors,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    Set<Object>? children,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.registerSession<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an instance as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to vinculate multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> registerDependent<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    Set<Object>? interceptors,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    Set<Object>? children,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.registerDependent<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an Object.
  ///
  /// - `register`: The Object to be registered.
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to vinculate multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> registerObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    Set<Object>? interceptors,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    Set<Object>? children,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.registerObject<BeanT>(
      register,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an instance as a Component.
  ///
  /// Registering the instance with this method means that "This instance is for this module only".
  ///
  /// To retrieve the instance, requires to use with `ddi.getComponent`
  ///
  /// Example:
  /// ```dart
  /// MyWidgetComponent get myWidget => ddi.getComponent(MyModule);
  /// ```
  ///
  /// Useful for Flutter apps where you want to reuse the same component or instance across specific routes or Widgets.
  /// Additionally, you can inject and retrieve the same component in each "SubModule" or even in a "SubModule" get the parent module instance.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to vinculate multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> registerComponent<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    Set<Object>? interceptors,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    Set<Object>? children,
    FutureOr<bool> Function(Object)? selector,
  }) {
    return ddi.registerComponent<BeanT>(
      clazzRegister: clazzRegister,
      moduleQualifier: moduleQualifier,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );
  }

  /// Registers a factory to create an instance of the class [BeanT].
  ///
  /// - `factory`: Factory to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `canRegister`: Optional function to conditionally register the instance.
  ///
  Future<void> register<BeanT extends Object>({
    required ScopeFactory<BeanT> factory,
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
  }) {
    final bean = ddi.register(
      factory: factory,
      qualifier: qualifier,
      canRegister: canRegister,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }
}
