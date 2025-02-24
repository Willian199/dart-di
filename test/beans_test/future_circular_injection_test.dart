import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void futureCircularDetection() {
  group('DDI Future Circular Injection Detection tests', () {
    test('Inject a Singleton bean depending from a bean that not exists yet',
        () {
      expectLater(
          () => DDI.instance.registerSingleton(
              () => Future.value(Father(mother: DDI.instance()))),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Inject a Application bean depending from a bean that not exists yet',
        () {
      //This works because it was just registered
      DDI.instance.registerApplication<Father>(() async =>
          Future.value(Father(mother: await DDI.instance.getAsync<Mother>())));
      DDI.instance.registerApplication<Mother>(() async =>
          Future.value(Mother(father: await DDI.instance.getAsync<Father>())));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Inject a Application bean with circular dependency', () {
      DDI.instance.registerApplication<Father>(() async =>
          Future.value(Father(mother: await DDI.instance.getAsync<Mother>())));
      DDI.instance.registerApplication<Mother>(() async =>
          Future.value(Mother(father: await DDI.instance.getAsync<Father>())));

      expectLater(() => DDI.instance.getAsync<Mother>(),
          throwsA(isA<ConcurrentCreationException>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Inject a Dependent bean with circular dependency', () {
      DDI.instance.registerDependent<Father>(() async =>
          Future.value(Father(mother: await DDI.instance.getAsync<Mother>())));

      DDI.instance.registerDependent<Mother>(() async =>
          Future.value(Mother(father: await DDI.instance.getAsync<Father>())));

      expectLater(() => DDI.instance.getAsync<Mother>(),
          throwsA(isA<ConcurrentCreationException>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Inject a Session bean with circular dependency', () {
      DDI.instance.registerSession<Father>(() async =>
          Future.value(Father(mother: await DDI.instance.getAsync<Mother>())));

      DDI.instance.registerSession<Mother>(() async =>
          Future.value(Mother(father: await DDI.instance.getAsync<Father>())));

      expectLater(() => DDI.instance.getAsync<Mother>(),
          throwsA(isA<ConcurrentCreationException>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Get the same Singleton bean 10 times', () async {
      await DDI.instance.registerSingleton(() => Future.value(C()));

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();
    });

    test('Get the same Application bean 10 times', () async {
      DDI.instance.registerApplication(() => Future.value(C()));

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();
    });

    test('Get the same Session bean 10 times', () async {
      DDI.instance.registerSession(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        return Future.value(C());
      });

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();
    });

    test('Get the same Dependent bean 10 times', () async {
      DDI.instance.registerDependent(() => Future.value(C()));

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();
    });
  });
}
