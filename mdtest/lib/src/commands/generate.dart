// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import '../runner/mdtest_command.dart';
import '../globals.dart';
import '../report/test_report.dart';
import '../util.dart';

class GenerateCommand extends MDTestCommand {

  @override
  final String name = 'generate';

  @override
  final String description = 'Generate code coverage or test output web report';

  @override
  Future<int> runCore() async {
    printInfo('Running "mdtest generate command" ...');
    String reportDataPath = argResults['load-report'];
    String outputPath = argResults['output'];
    String reportType = argResults['report-type'];
    if (reportType == 'test') {
      TestReport testReport = new TestReport(reportDataPath, outputPath);
      testReport.writeReport();
    }
    if (reportType == 'coverage') {
      printInfo('Not supported.');
    }
    return 0;
  }

  void printGuide(String guide) {
    guide.split('\n').forEach((String line) => printInfo(line));
  }

  GenerateCommand() {
    usesSpecTemplateOption();
    usesTestTemplateOption();
    usesReportTypeOption();
    argParser.addOption(
      'load-report',
      defaultsTo: null,
      help:
        'Path to load the report data.  '
        'The report data could be either lcov format for code coverage, '
        'or JSON format for test output.'
    );
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: null,
      help:
        'Path to generate web report.  The path should either not exist or '
        'point to a directory.  If the path does not exist, a new directory '
        'will be created using that path.'
    );
  }
}