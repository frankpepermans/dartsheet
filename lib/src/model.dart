library dartsheet.model;

import 'dart:async';
import 'dart:html';

import 'package:dart_flex/dart_flex.dart';
import 'package:observe/observe.dart';

part 'model/cell.dart';
part 'model/row.dart';
part 'model/formula.dart';

String toCellIdentity(int row, int col) {
  String id;
  
  if (col >= 26 ) id = new String.fromCharCodes(<int>[64 + col ~/ 26, 65 + col - 26 * (col ~/ 26)]);
  else id = new String.fromCharCode(65 + col);
  
  return '$id${row + 1}';
}