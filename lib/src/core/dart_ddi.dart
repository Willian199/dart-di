import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/exception/factory_not_allowed.dart';
import 'package:dart_ddi/src/exception/future_not_accept.dart';
import 'package:dart_ddi/src/exception/module_not_found.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/utils/dispose_utils.dart';
import 'package:dart_ddi/src/utils/instance_factory_util.dart';
import 'package:dart_ddi/src/utils/scope_utils.dart';

part 'dart_ddi_impl.dart';

/// Shortcut for getting the shared instance of the [DDI] class.
/// The [DDI] class provides methods for managing beans.
final DDI ddi = DDI.instance;

/// [DDI] is an abstract class representing a Dependency Injection system.
/// It provides methods for managing beans.
abstract class DDI {
  /// Creates the shared instance of the [DDI] class.
  static final DDI _instance = _DDIImpl();

  /// Gets the shared instance of the [DDI] class.
  static DDI get instance => _instance;

  /// Get a new instance of the [DDI] class.
  static DDI get newInstance => _DDIImpl();

  /// Registers an Object.
  ///
  /// - `register`: The Object to be registered.
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  /// **Object Scope:**
  /// - Ensures that the registered Object is created and shared throughout the entire application.
  /// - Created once when registered.
  /// - Works like Singleton Scope.
  ///
  ///  **Use Case:**
  /// - Suitable for objects that are stateless or have shared state across the entire application.
  /// - Examples include application or device properties, like platform or dark mode.
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
  });

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
  Future<void> registerComponent<BeanT extends Object>({
    required BeanRegister<BeanT> clazzRegister,
    required Object moduleQualifier,
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    Set<Object>? interceptors,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    Set<Object>? children,
    FutureOr<bool> Function(Object)? selector,
  });

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
  });

  /// Verify if an instance is already registered in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isRegistered<BeanT extends Object>({Object? qualifier});

  /// Verify if the factory is a Future in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isFuture<BeanT extends Object>({Object? qualifier});

  /// Verify if the factory is ready in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isReady<BeanT extends Object>({Object? qualifier});

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  /// - `select`: Optional value to pass to distinguish between different instances of the same type.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  BeanT getWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
  });

  /// Gets an instance of the registered class in [DDI] from the specified [module].
  ///
  /// The [module] class requires to have DDIModule mixin.
  ///
  /// The [module] must be registered in [DDI].
  ///
  /// Also the [module] class could be the qualifier from the Module Bean.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  ///
  BeanT getComponent<BeanT extends Object>({
    required Object module,
    Object? qualifier,
  });

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  /// - `select`: Optional value to pass to distinguish between different instances of the same type.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  Future<BeanT> getAsyncWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
  });

  /// Retrieves a list of keys associated with objects of a specific type BeanT`.
  ///
  /// This method allows you to obtain all keys (qualifier names) that have been used to register objects of the specified type `BeanT`.
  List<Object> getByType<BeanT extends Object>();

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  FutureOr<void> destroy<BeanT extends Object>({Object? qualifier});

  /// Removes all the instance registered as Session Scope.
  void destroyAllSession();

  /// Removes all the instance registered as type `BeanT`.
  void destroyByType<BeanT extends Object>();

  /// Disposes of the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  Future<void> dispose<BeanT extends Object>({Object? qualifier});

  /// Disposes all the instance registered as Session Scope.
  void disposeAllSession();

  /// Disposes all the instance registered as type `BeanT`.
  void disposeByType<BeanT extends Object>();

  /// Allows to dynamically add a Decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  FutureOr<void> addDecorator<BeanT extends Object>(
      ListDecorator<BeanT> decorators,
      {Object? qualifier});

  /// Allows to dynamically add a Interceptor.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Scope:** Different scopes may have varying behaviors when adding interceptors.
  /// - **onCreate:** Won't work with Singletons Scope.
  /// - **Order of Execution:** Interceptor are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void addInterceptor<BeanT extends Object>(Set<Object>? interceptors,
      {Object? qualifier});

  /// Allows to dynamically refresh the Object.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void refreshObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
  });

  /// This function adds multiple child modules to a parent module.
  /// It takes a list of 'child' objects and an optional 'qualifier' for the parent module.
  void addChildrenModules<BeanT extends Object>(
      {required Set<Object> child, Object? qualifier});

  /// This function adds a single child module to a parent module.
  /// It takes a 'child' object and an optional 'qualifier' for the parent module.
  void addChildModules<BeanT extends Object>(
      {required Object child, Object? qualifier});

  Set<Object> getChildren<BeanT extends Object>({Object? qualifier});
}
