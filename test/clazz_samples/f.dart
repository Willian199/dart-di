import 'd.dart';

class F extends D {
  F(D instance) {
    super.value = '${instance.value.toString().replaceAll('e', '')}ghi';
  }
}
