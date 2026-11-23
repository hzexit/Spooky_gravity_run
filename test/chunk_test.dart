import 'package:flutter_test/flutter_test.dart';
import 'package:spooky_gravity_run/game/chunks.dart';

void main() {
  test('ทุก chunk ผ่านได้', () {
    for (final c in allChunks) {
      expect(checkRows(c.rows), isNull, reason: 'chunk "${c.name}"');
    }
  });

  test('ทุกคู่ chunk ที่ต่อกันผ่านได้', () {
    for (final a in allChunks) {
      for (final b in allChunks) {
        final joined = [for (var r = 0; r < 3; r++) a.rows[r] + b.rows[r]];
        expect(
          checkRows(joined),
          isNull,
          reason: '"${a.name}" ต่อด้วย "${b.name}"',
        );
      }
    }
  });

  test('ตรวจจับด่านที่ผ่านไม่ได้ได้จริง', () {
    // หนามคนละฝั่งห่างแค่ 2 คอลัมน์
    expect(checkRows(['..v....', '.......', '^......']), isNotNull);
    // หนามทั้งสองฝั่งคอลัมน์เดียวกัน
    expect(checkRows(['.v.', '...', '.^.']), isNotNull);
  });
}