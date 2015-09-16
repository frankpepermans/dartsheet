library dartsheet.model;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:dart_flex/dart_flex.dart';
import 'package:observe/observe.dart';

part 'model/cell.dart';
part 'model/row.dart';
part 'model/formula.dart';
part 'model/selector.dart';

String toColIdentity(int col) {
  if (col >= 26 ) return new String.fromCharCodes(<int>[64 + col ~/ 26, 65 + col - 26 * (col ~/ 26)]);
  
  return new String.fromCharCode(65 + col);
}

String toCellIdentity(int row, int col) => '${toColIdentity(col)}${row + 1}';