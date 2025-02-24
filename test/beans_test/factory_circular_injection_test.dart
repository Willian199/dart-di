import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:test/test.dart';

import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void factoryCircularDetection() {
  group('DDI Factory Circular Injection Detection tests', () {
    test(
        'Inject a Factory Singleton bean depending from a bean that not exists yet',
        () {
      expect(
          () => ddi.register(factory: Father.fromMother.builder.asSingleton()),
          throwsA(isA<BeanNotFoundException>()));
    });

    test(
        'Inject a Factory Application bean depending from a bean that not exists yet',
        () {
      //This works because it was just registered

      ddi.register(factory: Father.fromMother.builder.asApplication());
      ddi.register(factory: Mother.fromFather.builder.asApplication());

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Factory Application bean with circular dependency', () {
      ddi.register(factory: Father.fromMother.builder.asApplication());
      ddi.register(factory: Mother.fromFather.builder.asApplication());

      expect(
          () => ddi.get<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Factory Dependent bean with circular dependency', () {
      ddi.register(factory: Father.fromMother.builder.asDependent());
      ddi.register(factory: Mother.fromFather.builder.asDependent());

      expect(
          () => ddi.get<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test(
        'Inject a Factory Singleton bean depending from a bean that not exists yet',
        () {
      expect(
          () => ddi.register(
                factory: ScopeFactory.singleton(
                  builder: () {
                    return Future.delayed(const Duration(milliseconds: 10),
                        () => Father(mother: ddi()));
                  }.builder,
                ),
              ),
          throwsA(isA<BeanNotFoundException>()));
    });

    test(
        'Inject a Future Factory Application bean depending from a bean that not exists yet',
        () {
      //This works because it was just registered
      ddi.register<Father>(
        factory: ScopeFactory.application(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10),
                () async => Father(mother: await ddi.getAsync<Mother>()));
          }.builder,
        ),
      );

      ddi.register<Mother>(
        factory: ScopeFactory.application(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10),
                () async => Mother(father: await ddi.getAsync<Father>()));
          }.builder,
        ),
      );

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Future Factory Application bean with circular dependency',
        () async {
      ddi.register<Father>(
        factory: ScopeFactory.application(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10),
                () async => Father(mother: await ddi.getAsync<Mother>()));
          }.builder,
        ),
      );

      ddi.register<Mother>(
        factory: ScopeFactory.application(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10),
                () async => Mother(father: await ddi.getAsync<Father>()));
          }.builder,
        ),
      );

      await expectLater(() => ddi.getAsync<Mother>(),
          throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Future Factory Dependent bean with circular dependency',
        () async {
      ddi.register<Father>(
        factory: ScopeFactory.dependent(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10),
                () async => Father(mother: await ddi.getAsync<Mother>()));
          }.builder,
        ),
      );

      ddi.register<Mother>(
        factory: ScopeFactory.dependent(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10),
                () async => Mother(father: await ddi.getAsync<Father>()));
          }.builder,
        ),
      );

      await expectLater(() => ddi.getAsync<Mother>(),
          throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });
  });
}
