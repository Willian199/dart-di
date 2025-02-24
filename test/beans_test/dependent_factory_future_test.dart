import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/factory_parameter.dart';

void dependentFactoryFuture() {
  group('DDI Dependent Factory Future Basic Tests', () {
    void registerDependentBeans() {
      DDI.instance.register<A>(
        factory: ScopeFactory.dependent(
          builder: () async {
            return A(await DDI.instance.getAsync<B>());
          }.builder,
        ),
      );

      DDI.instance.register<B>(
        factory: ScopeFactory.dependent(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return B(DDI.instance());
          }.builder,
        ),
      );

      C.new.builder.asDependent().register();
    }

    void removeDependentBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Dependent bean', () async {
      registerDependentBeans();

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a "child" bean is diposed', () async {
      registerDependentBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a second "child" bean is diposed',
        () async {
      registerDependentBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<B>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Try to retrieve Dependent bean after disposed', () async {
      DDI.instance.register(
        factory: () {
          return Future.value(C());
        }.builder.asDependent(),
      );

      final instance1 = await DDI.instance.getAsync<C>();

      DDI.instance.dispose<C>();

      final instance2 = await DDI.instance.getAsync<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Dependent bean after removed', () async {
      DDI.instance.register(
        factory: () {
          return Future.value(C());
        }.builder.asDependent(),
      );

      await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () async {
      DDI.instance.register(
        qualifier: 'typeC',
        factory: () {
          return Future.value(C());
        }.builder.asDependent(),
      );

      final instance1 = await DDI.instance.getAsync(qualifier: 'typeC');
      final instance2 = DDI.instance.getAsync(qualifier: 'typeC');

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register and retrieve Future delayed Dependent bean', () async {
      DDI.instance.register(
        factory: () async {
          final C value =
              await Future.delayed(const Duration(seconds: 2), C.new);
          return value;
        }.builder.asDependent(),
      );

      final C intance = await DDI.instance.getAsync<C>();

      await expectLater(intance.value, 1);

      DDI.instance.destroy<C>();
    });

    test('Retrieve Factory Dependent with Custom Parameter', () async {
      DDI.instance.register(
        factory: ScopeFactory.dependent(
          builder: (RecordParameter parameter) async {
            await Future.delayed(const Duration(milliseconds: 10));
            return FactoryParameter(parameter);
          }.builder,
        ),
      );

      final FactoryParameter instance =
          await DDI.instance.getAsyncWith(parameter: getRecordParameter);

      expect(instance, isA<FactoryParameter>());
      expect(instance.parameter, getRecordParameter);

      DDI.instance.destroy<FactoryParameter>();

      expectLater(() => DDI.instance.getAsync<FactoryParameter>(),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
