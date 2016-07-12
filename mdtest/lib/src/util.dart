// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as path;

import 'globals.dart';

int minLength(List<String> elements) {
  if (elements == null || elements.isEmpty) return -1;
  return elements.map((String e) => e.length).reduce(min);
}

bool isSystemSeparator(String letter) {
  return letter == Platform.pathSeparator;
}

int beginOfDiff(List<String> elements) {
  if (elements.length == 1)
    return elements[0].lastIndexOf(Platform.pathSeparator) + 1;
  int minL = minLength(elements);
  int lastSlash = 0;
  for (int i = 0; i < minL; i++) {
    String letter = elements[0][i];
    if (isSystemSeparator(letter)) {
      lastSlash = i;
    }
    for (String element in elements) {
      if (letter != element[i]) {
        return lastSlash + 1;
      }
    }
  }
  return minL;
}

String normalizePath(
  String rootPath,
  [String relativePath1, relativePath2]
) {
  return path.normalize(
    path.join(rootPath, relativePath1, relativePath2)
  );
}

String generateTimeStamp() {
  return new DateTime.now().toIso8601String();
}

bool deleteDirectories(Iterable<String> dirPaths) {
  for (String dirPath in dirPaths) {
    try {
      new Directory(dirPath).deleteSync(recursive: true);
    } on FileSystemException {
      printError('Cannot delete directory $dirPath');
      return false;
    }
  }
  return true;
}

String repeatString(String str, int time) {
  StringBuffer sb = new StringBuffer();
  for (int i = 0; i < time; i++)
    sb.write(str);
  return sb.toString();
}
