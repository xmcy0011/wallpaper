import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutterwin/services/logics.dart';
import 'package:test/scaffolding.dart';

// Annotation which generates the cat.mocks.dart library and the MockCat class.
@GenerateNiceMocks([MockSpec<PlayerLogic>()])
import 'player_test.mocks.dart';

void main() {
  test("add", () {
    var p = MockPlayerLogic();
    
    when(p.add("id"));
  });
}