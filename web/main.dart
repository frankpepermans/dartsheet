// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:dartsheet/dartsheet.dart';

Window mainWindow;

void main() {
  mainWindow = new Window('#spreadsheet-app')
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
}
