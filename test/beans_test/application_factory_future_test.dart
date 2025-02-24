import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/factory_parameter.dart';
import '../clazz_samples/multi_inject.dart';
import '../clazz_samples/undestroyable/future_application_factory_destroy_get.dart';
import 'payment_service.dart';

void applicationFactoryFuture() {
  group('DDI Factory Application Future Basic Tests', () {
    void registerApplicationBeans() {
      DDI.instance.register(factory: MultiInject.new.builder.asApplication());

      DDI.instance.register<A>(
        factory: ScopeFactory.application(
          builder: () async {
            return A(await DDI.instance.getAsync<B>());
          }.builder,
        ),
      );

      DDI.instance.register<B>(
        factory: ScopeFactory.application(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 20));
            return B(DDI.instance());
          }.builder,
        ),
      );
      DDI.instance.register(
        factory: C.new.builder.asApplication(),
      );
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<MultiInject>();
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Factory Application bean', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after a "child" bean is diposed',
        () async {
      registerApplicationBeans();

      final instance = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test(
        'Retrieve Factory Application bean after a second "child" bean is diposed',
        () async {
      registerApplicationBeans();

      final instance = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<B>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test(
        'Retrieve Factory Application bean after the last "child" bean is diposed',
        () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1.a, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 2 "child" bean is diposed',
        () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1.a, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 3 "child" bean is diposed',
        () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1.a, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve Factory Application bean after disposed', () async {
      DDI.instance.register(
        factory: () {
          return Future.value(C());
        }.builder.asApplication(),
      );

      final instance1 = await DDI.instance.getAsync<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.getAsync<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Factory Application bean after removed', () {
      DDI.instance.register(
        factory: () {
          return Future.value(C());
        }.builder.asApplication(),
      );

      DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.getAsync<C>(),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a Factory qualifier bean', () {
      DDI.instance.register(
        qualifier: 'typeC',
        factory: () {
          return Future.value(C());
        }.builder.asApplication(),
      );

      DDI.instance.getAsync(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.getAsync(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Factory Application bean', () async {
      DDI.instance.register(
        factory: ScopeFactory.application(
          canDestroy: false,
          builder: () {
            return Future.value(FutureApplicationFactoryDestroyGet());
          }.builder,
        ),
      );

      final instance1 =
          await DDI.instance.getAsync<FutureApplicationFactoryDestroyGet>();

      DDI.instance.destroy<FutureApplicationFactoryDestroyGet>();

      final instance2 =
          await DDI.instance.getAsync<FutureApplicationFactoryDestroyGet>();

      expect(instance1, same(instance2));
    });
    test('Register and retrieve Future Factory Application', () async {
      DDI.instance.register<A>(
        factory: ScopeFactory.application(
          builder: () async {
            return A(await DDI.instance.getAsync<B>());
          }.builder,
        ),
      );

      DDI.instance.register<B>(
        factory: ScopeFactory.application(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 20));
            return B(DDI.instance());
          }.builder,
        ),
      );
      DDI.instance.register(factory: C.new.builder.asApplication());

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

    test('Register and retrieve Future delayed Factory Application bean',
        () async {
      DDI.instance.register<C>(
        factory: ScopeFactory.application(
          builder: () async {
            final C value =
                await Future.delayed(const Duration(seconds: 1), C.new);
            return value;
          }.builder,
        ),
      );

      final C intance = await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      await expectLater(intance.value, 1);
    });

    test('Try to retrieve Factory Application bean using Future', () {
      DDI.instance.register(
        factory: ScopeFactory.application(
          builder: () async {
            return A(await DDI.instance.getAsync<B>());
          }.builder,
        ),
      );

      DDI.instance.register(
        factory: ScopeFactory.application(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 20));
            return B(DDI.instance());
          }.builder,
        ),
      );
      DDI.instance.register(factory: C.new.builder.asApplication());
      //This happens because A(await DDI.instance()) transform to A(await DDI.instance<FutureOr<B>>())
      expect(() => DDI.instance.getAsync<A>(),
          throwsA(isA<BeanNotFoundException>()));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Factory Application bean using FutureOr',
        () async {
      DDI.instance.register(
        factory: ScopeFactory.application(
          builder: () async {
            return A(await DDI.instance.getAsync());
          }.builder,
        ),
      );

      DDI.instance.register<B>(
        factory: ScopeFactory.application(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 20));
            return B(DDI.instance());
          }.builder,
        ),
      );

      DDI.instance.register(factory: C.new.builder.asApplication());

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
        'Retrieve Factory Application bean after a "child" bean is disposed using Future',
        () async {
      DDI.instance.register(
        factory: ScopeFactory.application(
          builder: () async {
            return A(await DDI.instance.getAsync());
          }.builder,
        ),
      );

      DDI.instance.register<B>(
        factory: ScopeFactory.application(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 10));
            return B(DDI.instance());
          }.builder,
        ),
      );

      DDI.instance.register(factory: C.new.builder.asApplication());

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

    test('Retrieve Factory Application bean Stream', () async {
      DDI.instance
          .register(factory: StreamController<C>.new.builder.asApplication());

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });

    test('Retrieve Factory Application with Custom Parameter', () async {
      DDI.instance.register(
        factory: ScopeFactory.application(
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

    test('Select an Application bean', () async {
      // Registering CreditCardPaymentService with a selector condition

      ddi.register<PaymentService>(
        factory: ScopeFactory.application(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 100));
            return CreditCardPaymentService();
          }.builder,
          selector: (paymentMethod) => paymentMethod == 'creditCard',
        ),
        qualifier: 'creditCard',
      );

      // Registering PayPalPaymentService with a selector condition
      ddi.register<PaymentService>(
        factory: ScopeFactory.application(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 100));
            return PayPalPaymentService();
          }.builder,
          selector: (paymentMethod) => paymentMethod == 'paypal',
        ),
        qualifier: 'paypal',
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
