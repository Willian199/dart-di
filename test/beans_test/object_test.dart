import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/factory_not_allowed.dart';
import 'package:test/test.dart';

void object() {
  group('DDI Object Basic Tests', () {
    test('Register and retrieve object bean', () {
      DDI.instance.registerObject('Willian Marchesan', qualifier: 'author');

      final instance1 = DDI.instance.get(qualifier: 'author');
      final instance2 = DDI.instance.get(qualifier: 'author');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.destroy(qualifier: 'author');
    });

    test('Try to retrieve object bean after removed', () {
      DDI.instance.registerObject('Willian Marchesan', qualifier: 'author');

      DDI.instance.get(qualifier: 'author');

      DDI.instance.destroy(qualifier: 'author');

      expect(() => DDI.instance.get(qualifier: 'author'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Object bean', () {
      DDI.instance.registerObject(
        'Willian Marchesan',
        qualifier: 'author',
        canDestroy: false,
      );

      final instance1 = DDI.instance.get(qualifier: 'author');

      DDI.instance.destroy(qualifier: 'author');

      final instance2 = DDI.instance.get(qualifier: 'author');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Object bean', () {
      DDI.instance.registerObject(
        'Willian Marchesan',
        qualifier: 'owner',
        canDestroy: false,
      );

      DDI.instance.get(qualifier: 'owner');

      DDI.instance.destroy(qualifier: 'owner');

      /*expect(
          () => DDI.instance.registerObject(
                'Willian Marchesan',
                qualifier: 'owner',
              ),
          throwsA(isA<DuplicatedBean>()));*/
    });

    test('Register, retrieve and refresh object bean', () {
      DDI.instance.registerObject('Willian Marchesan', qualifier: 'name');

      final instance1 = DDI.instance.get(qualifier: 'name');
      final instance2 = DDI.instance.get(qualifier: 'name');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.refreshObject('Will', qualifier: 'name');

      final instance3 = DDI.instance.get(qualifier: 'name');

      expect('Will', instance3);
      expect(false, identical(instance1, instance3));
      expect(false, identical(instance2, instance3));

      DDI.instance.destroy(qualifier: 'name');
    });

    test('Try to register an Object with default register function', () {
      expect(
          () => DDI.instance.register(
              factory: ScopeFactory.object(instanceHolder: 'Value test')),
          throwsA(isA<FactoryNotAllowedException>()));
    });

    test('Try to refresh an Object not registered', () {
      expect(() => DDI.instance.refreshObject("new value"),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
