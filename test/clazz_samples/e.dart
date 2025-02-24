import 'd.dart';

class E extends D {
  E(D instance) {
    super.value =
        '${instance.value.toString().replaceAll('a', '').replaceAll('i', '')}def';
  }
}
