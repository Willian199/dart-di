import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/future_session_destroy_get.dart';

void sessionFuture() {
  group('DDI Session Future Basic Tests', () {
    void registerSessionBeans() {
      DDI.instance
          .registerSession(() async => A(await DDI.instance.getAsync()));
      DDI.instance.registerSession<B>(() => Future.value(B(DDI.instance())));
      DDI.instance.registerSession(C.new);
    }

    void removeSessionBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Session bean', () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after a "child" bean is diposed', () async {
      registerSessionBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after a second "child" bean is diposed',
        () async {
      registerSessionBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after the last "child" bean is diposed',
        () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after 2 "child" bean is diposed', () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after 3 "child" bean is diposed', () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Try to retrieve Session bean after disposed', () async {
      DDI.instance.registerSession(() => Future.value(C()));

      final instance1 = await DDI.instance.getAsync<C>();

      DDI.instance.dispose<C>();

      final instance2 = await DDI.instance.getAsync<C>();

      expect(false, identical(instance1, instance2));
      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Session bean after removed', () async {
      DDI.instance.registerSession(() => Future.value(C()));

      await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.getAsync<C>(),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerSession(() => Future.value(C()), qualifier: 'typeC');

      DDI.instance.getAsync(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.getAsync(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Session bean', () async {
      DDI.instance.registerSession(
          () => Future.value(FutureSessionDestroyGet()),
          canDestroy: false);

      final instance1 = await DDI.instance.getAsync<FutureSessionDestroyGet>();

      DDI.instance.destroy<FutureSessionDestroyGet>();

      final instance2 = await DDI.instance.getAsync<FutureSessionDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Register and retrieve Future delayed Session bean', () async {
      DDI.instance.registerSession(() async {
        final C value = await Future.delayed(const Duration(seconds: 2), C.new);
        return value;
      });

      final C intance = await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      await expectLater(intance.value, 1);
    });

    test('Retrieve Session bean after a "child" bean is disposed using Future',
        () async {
      DDI.instance
          .registerSession(() async => A(await DDI.instance.getAsync()));
      DDI.instance.registerSession<B>(() => B(DDI.instance()));
      DDI.instance.registerSession(C.new);

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Retrieve Session bean Stream', () async {
      DDI.instance.registerSession(StreamController<C>.new);

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });
  });
}
