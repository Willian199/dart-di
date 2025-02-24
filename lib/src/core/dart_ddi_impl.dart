part of 'dart_ddi.dart';

class _DDIImpl implements DDI {
  final Map<Object, ScopeFactory<Object>> _beans = {};

  @override
  Future<void> register<BeanT extends Object>({
    required ScopeFactory<BeanT> factory,
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
  }) async {
    if (factory.scopeType == Scopes.object ||
        factory.builder == null ||
        BeanT == Object) {
      throw FactoryNotAllowedException(BeanT.toString());
    }

    bool shouldRegister = true;

    if (canRegister != null) {
      if (canRegister is BoolCallback) {
        shouldRegister = canRegister();
      } else {
        shouldRegister = await canRegister();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        throw DuplicatedBeanException(effectiveQualifierName.toString());
      }

      // Force the type to be correct. Fixes the behavior with FutureOr and interfaces
      if (factory.type != BeanT) {
        factory = factory.cast<BeanT>();
      }

      if (factory.scopeType == Scopes.singleton) {
        return _applySingleton<BeanT>(factory, effectiveQualifierName);
      } else {
        _beans[effectiveQualifierName] = factory;
      }
    }
  }

  Future<void> _applySingleton<BeanT extends Object>(
      ScopeFactory<BeanT> factory, Object effectiveQualifierName) async {
    final FutureOr<BeanT> execInstance =
        InstanceFactoryUtil.create(builder: factory.builder!);

    BeanT clazz = /*factory.builder!.isFuture &&*/
        execInstance is Future ? await execInstance : execInstance;

    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        if (isFuture(qualifier: interceptor)) {
          final instance =
              await ddi.getAsync(qualifier: interceptor) as DDIInterceptor;

          clazz = (await instance.onCreate(clazz)) as BeanT;
        } else {
          final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

          final newInstance = instance.onCreate(clazz);
          if (newInstance is Future) {
            clazz = (await newInstance) as BeanT;
          } else {
            clazz = newInstance as BeanT;
          }
        }
      }
    }

    clazz = DartDDIUtils.executarDecorators<BeanT>(clazz, factory.decorators);

    factory.postConstruct?.call();

    if (clazz is DDIModule) {
      clazz.moduleQualifier = effectiveQualifierName;
    }

    _beans[effectiveQualifierName] = ScopeFactory<BeanT>.singleton(
      instanceHolder: clazz,
      builder: factory.builder,
      interceptors: factory.interceptors,
      canDestroy: factory.canDestroy,
      children: factory.children,
    );

    if (clazz is PostConstruct) {
      return clazz.onPostConstruct();
    } else if (clazz is Future<PostConstruct>) {
      return DartDDIUtils.runFutureOrPostConstruct(clazz);
    }
  }

  @override
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
  }) async {
    bool shouldRegister = true;

    if (canRegister != null) {
      if (canRegister is BoolCallback) {
        shouldRegister = canRegister();
      } else {
        shouldRegister = await canRegister();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        throw DuplicatedBeanException(effectiveQualifierName.toString());
      }

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          final instance = (ddi.isFuture(qualifier: interceptor)
              ? (await getAsync(qualifier: interceptor))
              : ddi.get(qualifier: interceptor)) as DDIInterceptor;

          final exec = instance.onCreate(register);

          register = (exec is Future ? await exec : exec) as BeanT;
        }
      }

      register = DartDDIUtils.executarDecorators<BeanT>(register, decorators);

      postConstruct?.call();

      if (register is DDIModule) {
        register.moduleQualifier = effectiveQualifierName;
      }

      _beans[effectiveQualifierName] = ScopeFactory<BeanT>.object(
        instanceHolder: register,
        interceptors: interceptors,
        canDestroy: canDestroy,
        children: children,
        selector: selector,
      );

      if (register is PostConstruct) {
        return register.onPostConstruct();
      } else if (register is Future<PostConstruct>) {
        return DartDDIUtils.runFutureOrPostConstruct(register);
      }
    }
  }

  @override
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
  }) {
    final Object effectiveQualifierName =
        '$moduleQualifier${qualifier ?? BeanT}';

    if (_beans[moduleQualifier] case final ScopeFactory<DDIModule> _?) {
      final bean = registerApplication<BeanT>(
        clazzRegister,
        qualifier: effectiveQualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
        canDestroy: canDestroy,
        canRegister: canRegister,
        children: children,
        selector: selector,
      );

      addChildModules(
          child: effectiveQualifierName, qualifier: moduleQualifier);

      return bean;
    }

    throw ModuleNotFoundException(moduleQualifier.toString());
  }

  @override
  bool isRegistered<BeanT extends Object>({Object? qualifier}) {
    return _beans.containsKey(qualifier ?? BeanT);
  }

  @override
  bool isFuture<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      return factory.builder?.isFuture ?? false;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  bool isReady<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      return factory.instanceHolder != null;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  BeanT getWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      if (factory.scopeType != Scopes.object &&
          factory.builder!.isFuture &&
          // If the instance is already created
          // We allow get it
          factory.instanceHolder == null) {
        throw const FutureNotAcceptException();
      }

      return ScopeUtils.executar<BeanT, ParameterT>(
        factory: factory,
        effectiveQualifierName: effectiveQualifierName,
        parameter: parameter,
      );
    } else if (select != null && BeanT != Object) {
      // Try to find a bean with the selector
      for (final MapEntry(key: _, :value) in _beans.entries) {
        if (value.type == BeanT &&
            (value.selector?.call(select) ?? false) as bool) {
          return ScopeUtils.executar<BeanT, ParameterT>(
            factory: value as ScopeFactory<BeanT>,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
          );
        }
      }
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  BeanT getComponent<BeanT extends Object>({
    required Object module,
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = '$module${qualifier ?? BeanT}';
    if (_beans[module] case final ScopeFactory<DDIModule> factoryModuleClazz?
        when factoryModuleClazz.children?.contains(effectiveQualifierName) ??
            false) {
      return get<BeanT>(qualifier: effectiveQualifierName);
    }

    throw ModuleNotFoundException(module.toString());
  }

  @override
  Future<BeanT> getAsyncWith<BeanT extends Object, ParameterT extends Object>(
      {ParameterT? parameter, Object? qualifier, Object? select}) async {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      return ScopeUtils.executarAsync<BeanT, ParameterT>(
        factory: factory,
        effectiveQualifierName: effectiveQualifierName,
        parameter: parameter,
      );
    } else if (select != null && BeanT != Object) {
      // Try to find a bean with the selector
      for (final MapEntry(key: _, :value) in _beans.entries) {
        if (value.type == BeanT &&
            value.selector != null &&
            await (value.selector?.call(select) ?? false)) {
          return ScopeUtils.executarAsync<BeanT, ParameterT>(
            factory: value as ScopeFactory<BeanT>,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
          );
        }
      }
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  List<Object> getByType<BeanT extends Object>() {
    final Type type = BeanT;

    return _beans.entries
        .where((element) => element.value.type == type)
        .map((e) => e.key)
        .toList();
  }

  @override
  FutureOr<void> destroy<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    return _destroy<BeanT>(effectiveQualifierName);
  }

  FutureOr<void> _destroyChildren<BeanT extends Object>(Set<Object>? children) {
    if (children?.isNotEmpty ?? false) {
      for (final Object child in children!) {
        _destroy(child);
      }
    }
  }

  Future<void> _destroyChildrenAsync<BeanT extends Object>(
      Set<Object>? children) async {
    if (children?.isNotEmpty ?? false) {
      for (final Object child in children!) {
        await _destroy(child);
      }
    }
  }

  FutureOr<void> _destroy<BeanT extends Object>(
      Object effectiveQualifierName) async {
    if (_beans[effectiveQualifierName] case final factory?
        when factory.canDestroy) {
      // Only destroy if canDestroy was registered with true
      // Should call interceptors even if the instance is null
      if (factory.interceptors case final inter? when inter.isNotEmpty) {
        for (final interceptor in inter) {
          if (isFuture(qualifier: interceptor)) {
            final instance =
                (await getAsync(qualifier: interceptor)) as DDIInterceptor;

            await instance.onDestroy(factory.instanceHolder);
          } else {
            final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

            instance.onDestroy(factory.instanceHolder as BeanT?);
          }
        }
      }

      if (factory.instanceHolder case final clazz? when clazz is PreDestroy) {
        return _runFutureOrPreDestroy(factory, clazz, effectiveQualifierName);
      }

      _destroyChildren(factory.children);
      _beans.remove(effectiveQualifierName);
    }
  }

  Future<void> _runFutureOrPreDestroy<BeanT extends Object>(
      ScopeFactory<BeanT> factory,
      PreDestroy clazz,
      Object effectiveQualifierName) async {
    await _destroyChildrenAsync(factory.children);

    await clazz.onPreDestroy();

    _beans.remove(effectiveQualifierName);

    return Future.value();
  }

  @override
  void destroyAllSession() {
    final keys = _beans.entries
        .where((element) =>
            element.value.scopeType == Scopes.session &&
            element.value.canDestroy)
        .map((e) => e.key)
        .toList();

    for (final key in keys) {
      _destroy(key);
    }
  }

  @override
  void destroyByType<BeanT extends Object>() {
    final keys = getByType<BeanT>();

    for (final key in keys) {
      _destroy(key);
    }
  }

  @override
  Future<void> dispose<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      //Singleton e Object only can destroy
      //Dependent doesn't have instance
      switch (factory.scopeType) {
        case Scopes.application:
        case Scopes.session:
          return DisposeUtils.disposeBean<BeanT>(factory);
        default:
          return DisposeUtils.disposeChildrenAsync<BeanT>(factory.children);
      }
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  void disposeAllSession() {
    for (final MapEntry(key: _, :value) in _beans.entries) {
      if (value.scopeType == Scopes.session) {
        DisposeUtils.disposeBean(value);
      }
    }
  }

  @override
  void disposeByType<BeanT extends Object>() {
    final List<Scopes> allowedScopes = [Scopes.application, Scopes.session];

    final clazz = _beans.entries
        .where((element) =>
            element.value.type is BeanT &&
            allowedScopes.contains(element.value.scopeType))
        .toList();

    for (final MapEntry(key: _, :value) in clazz) {
      DisposeUtils.disposeBean(value);
    }
  }

  @override
  FutureOr<void> addDecorator<BeanT extends Object>(
    List<BeanT Function(BeanT)> decorators, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final ScopeFactory<BeanT>? factory =
        _beans[effectiveQualifierName] as ScopeFactory<BeanT>?;

    if (factory == null) {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }

    switch (factory.scopeType) {
      //Singleton Scopes already have a instance
      case Scopes.singleton:
      case Scopes.object:
        factory.instanceHolder = DartDDIUtils.executarDecorators<BeanT>(
            factory.instanceHolder!, decorators);
        break;
      //Application and Session Scopes may  have a instance created
      case Scopes.application:
      case Scopes.session:
        if (factory.instanceHolder case final clazz?) {
          factory.instanceHolder =
              DartDDIUtils.executarDecorators<BeanT>(clazz, decorators);
        }

      //Dependent Scopes always require a new instance
      case Scopes.dependent:
        factory.decorators = [...factory.decorators ?? [], ...decorators];

        break;
    }
  }

  @override
  void addInterceptor<BeanT extends Object>(
    Set<Object>? interceptors, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      factory.interceptors = {
        ...factory.interceptors ?? {},
        ...interceptors ?? {}
      };
    } else {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  void refreshObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      factory.instanceHolder =
          DartDDIUtils.executarDecorators<BeanT>(register, factory.decorators);
      return;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  void addChildModules<BeanT extends Object>(
      {required Object child, Object? qualifier}) {
    addChildrenModules<BeanT>(child: {child}, qualifier: qualifier);
  }

  @override
  void addChildrenModules<BeanT extends Object>({
    required Set<Object> child,
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final ScopeFactory<BeanT> factory?) {
      factory.children = {...factory.children ?? {}, ...child};
    } else {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  Set<Object> getChildren<BeanT extends Object>({Object? qualifier}) {
    return _beans[qualifier ?? BeanT]?.children ?? {};
  }
}
