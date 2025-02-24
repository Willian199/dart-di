import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';

void addDecorator() {
  group('DDI ADD Decorators Tests', () {
    void regraSoma() {
      final instance1 = DDI.instance.get<D>();

      expect(instance1.value, 'bcdfghi');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final instance2 = DDI.instance.get<D>();

      expect(instance2.value, 'bcdfghdef');
      expect(identical(instance1, instance2), false);
    }

    test('ADD Decorators to a Singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSingleton(
        () => D(),
        decorators: [
          (D instance) => E(instance),
          (D instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Application bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerApplication(
        () => D(),
        decorators: [
          (D instance) => E(instance),
          (D instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Session bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSession(
        () => D(),
        decorators: [
          (D instance) => E(instance),
          (D instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Dependent bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerDependent(
        () => D(),
        decorators: [
          (D instance) => E(instance),
          (D instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Bean not registered', () {
      expect(
          () => ddi.addDecorator<D>([
                (instance) => E(instance),
              ]),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
