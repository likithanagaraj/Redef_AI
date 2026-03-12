import 'package:flutter_timezone/flutter_timezone.dart';
void main() async {
  var t = await FlutterTimezone.getLocalTimezone();
  print(t.runtimeType);
  try {
    print((t as dynamic).name);
  } catch(e) {}
  try {
    print((t as dynamic).timezone);
  } catch(e) {}
  print(t);
}
