import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/factory_parameter.dart';
import '../clazz_samples/multi_inject.dart';
import '../clazz_samples/undestroyable/future_singleton_factory_destroy_get.dart';

void singletonFactoryFuture() {
  group('DDI Singleton Factory Future Basic Tests', () {
    Future<void> registerBeans() async {
      DDI.instance.register(
        factory: C.new.builder.asSingleton(),
      );

      await DDI.instance.register<B>(
        factory: ScopeFactory.singleton(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return B(DDI.instance());
          }.builder,
        ),
      );

      await DDI.instance.register<A>(
        factory: ScopeFactory.singleton(
          builder: () async {
            return A(await DDI.instance.getAsync<B>());
          }.builder,
        ),
      );

      DDI.instance.register(factory: MultiInject.new.builder.asSingleton());
    }

    void removeSingletonBeans() {
      DDI.instance.destroy<MultiInject>();
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve a Factory singleton bean', () async {
      await registerBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve a Factory singleton bean after a "child" bean is diposed',
        () async {
      await registerBeans();

      final instance = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.destroy<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<MultiInject>();
    });

    test(
        'Retrieve a Factory singleton bean after a second "child" bean is diposed',
        () async {
      await registerBeans();

      final instance = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<MultiInject>();
    });

    test('Try to retrieve a Factory singleton bean after removed', () async {
      await DDI.instance.register<C>(
        factory: ScopeFactory.singleton(
          builder: () async {
            final C value =
                await Future.delayed(const Duration(seconds: 2), C.new);
            return value;
          }.builder,
        ),
      );

      DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.getAsync<C>(),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a Factory qualifier bean', () async {
      await DDI.instance.register<C>(
        factory: ScopeFactory.singleton(
          builder: () async {
            final C value =
                await Future.delayed(const Duration(seconds: 2), C.new);
            return value;
          }.builder,
        ),
        qualifier: 'typeC',
      );

      DDI.instance.getAsync(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.getAsync(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Factory Singleton bean', () async {
      await DDI.instance.register<FutureSingletonFactoryDestroyGet>(
        factory: ScopeFactory.singleton(
          canDestroy: false,
          builder: () async {
            final FutureSingletonFactoryDestroyGet value = await Future.delayed(
                const Duration(seconds: 2),
                FutureSingletonFactoryDestroyGet.new);
            return value;
          }.builder,
        ),
      );

      final instance1 =
          await DDI.instance.getAsync<FutureSingletonFactoryDestroyGet>();

      DDI.instance.destroy<FutureSingletonFactoryDestroyGet>();

      final instance2 =
          await DDI.instance.getAsync<FutureSingletonFactoryDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Retrieve Factory Singleton with Custom Parameter', () {
      expectLater(
          () => DDI.instance.register(
                factory: ScopeFactory.singleton(
                  builder: (RecordParameter parameter) async {
                    await Future.delayed(const Duration(milliseconds: 10));
                    return FactoryParameter(parameter);
                  }.builder,
                ),
              ),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
