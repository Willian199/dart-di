import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/future_application_destroy_get.dart';
import 'payment_service.dart';

void applicationFuture() {
  group('DDI Application Future Basic Tests', () {
    void registerApplicationBeans() {
      DDI.instance.registerApplication<A>(
          () async => A(await DDI.instance.getAsync<B>()));
      DDI.instance.registerApplication<B>(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        return B(DDI.instance());
      });
      DDI.instance.registerApplication(C.new);
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Application bean', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a second "child" bean is diposed',
        () async {
      registerApplicationBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<B>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after the last "child" bean is diposed',
        () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 2 "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 3 "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve Application bean after disposed', () async {
      DDI.instance.registerApplication(() => Future.value(C()));

      final instance1 = await DDI.instance.getAsync<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.getAsync<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Application bean after removed', () {
      DDI.instance.registerApplication(() => Future.value(C()));

      DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.getAsync<C>(),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance
          .registerApplication(() => Future.value(C()), qualifier: 'typeC');

      DDI.instance.getAsync(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.getAsync(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Application bean', () async {
      DDI.instance.registerApplication(
          () => Future.value(FutureApplicationDestroyGet()),
          canDestroy: false);

      final instance1 =
          await DDI.instance.getAsync<FutureApplicationDestroyGet>();

      DDI.instance.destroy<FutureApplicationDestroyGet>();

      final instance2 =
          await DDI.instance.getAsync<FutureApplicationDestroyGet>();

      expect(instance1, same(instance2));
    });
    test('Register and retrieve Future Application', () async {
      DDI.instance
          .registerApplication(() async => A(await DDI.instance.getAsync<B>()));
      DDI.instance.registerApplication(() => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Future delayed Application bean', () async {
      DDI.instance.registerApplication<C>(() async {
        final C value = await Future.delayed(const Duration(seconds: 2), C.new);
        return value;
      });

      final C intance = await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      await expectLater(intance.value, 1);
    });

    test('Try to retrieve Application bean using Future', () {
      DDI.instance.registerApplication(() async => A(await DDI.instance()));
      DDI.instance.registerApplication(() => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

      //This happens because A(await DDI.instance()) transform to A(await DDI.instance<FutureOr<B>>())
      expect(() => DDI.instance.getAsync<A>(),
          throwsA(isA<BeanNotFoundException>()));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Application bean using FutureOr', () async {
      DDI.instance
          .registerApplication(() async => A(await DDI.instance.getAsync()));
      DDI.instance.registerApplication<B>(() => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });
    test(
        'Retrieve Application bean after a "child" bean is disposed using Future',
        () async {
      DDI.instance
          .registerApplication(() async => A(await DDI.instance.getAsync<B>()));
      DDI.instance.registerApplication<B>(() => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

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

    test('Retrieve Application bean Stream', () async {
      DDI.instance.registerApplication(StreamController<C>.new);

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });

    test('Select an Application bean', () async {
      // Registering CreditCardPaymentService with a selector condition
      ddi.registerApplication<PaymentService>(
        () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return CreditCardPaymentService();
        },
        qualifier: 'creditCard',
        selector: (paymentMethod) => paymentMethod == 'creditCard',
      );

      // Registering PayPalPaymentService with a selector condition
      ddi.registerApplication<PaymentService>(
        () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return PayPalPaymentService();
        },
        qualifier: 'paypal',
        selector: (paymentMethod) => paymentMethod == 'paypal',
      );

      expect(true, ddi.isRegistered(qualifier: 'creditCard'));
      expect(true, ddi.isRegistered(qualifier: 'paypal'));

      // Runtime value to determine the payment method
      const selectedPaymentMethod = 'creditCard'; // Could also be 'paypal'

      // Retrieve the appropriate PaymentService based on the selector condition
      final paymentService = await ddi.getAsync<PaymentService>(
        select: selectedPaymentMethod,
      );

      // Process a payment with the selected service
      expect(100, paymentService.value);

      ddi.destroyByType<PaymentService>();

      expect(false, ddi.isRegistered(qualifier: 'creditCard'));
      expect(false, ddi.isRegistered(qualifier: 'paypal'));
    });
  });
}
