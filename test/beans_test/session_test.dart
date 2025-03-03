import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/session_destroy_get.dart';
import '../clazz_samples/undestroyable/session_destroy_register.dart';

void session() {
  group('DDI Session Basic Tests', () {
    void registerSessionBeans() {
      DDI.instance.registerSession(() => A(DDI.instance()));
      DDI.instance.registerSession(() => B(DDI.instance()));
      DDI.instance.registerSession(() => C());
    }

    void removeSessionBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Session bean', () {
      registerSessionBeans();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after a "child" bean is diposed', () {
      registerSessionBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after a second "child" bean is diposed', () {
      registerSessionBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after the last "child" bean is diposed', () {
      registerSessionBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after 2 "child" bean is diposed', () {
      registerSessionBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after 3 "child" bean is diposed', () {
      registerSessionBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Try to retrieve Session bean after disposed', () {
      DDI.instance.registerSession(() => C());

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));
    });

    test('Try to retrieve Session bean after removed', () {
      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerSession(() => C(), qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Session bean', () {
      DDI.instance
          .registerSession(() => SessionDestroyGet(), canDestroy: false);

      final instance1 = DDI.instance.get<SessionDestroyGet>();

      DDI.instance.destroy<SessionDestroyGet>();

      final instance2 = DDI.instance.get<SessionDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Session bean', () {
      DDI.instance
          .registerSession(() => SessionDestroyRegister(), canDestroy: false);

      DDI.instance.get<SessionDestroyRegister>();

      DDI.instance.destroy<SessionDestroyRegister>();

      // expect(() => DDI.instance.registerSession(() => SessionDestroyRegister()), throwsA(isA<DuplicatedBean>()));
    });
  });
}
