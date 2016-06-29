// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../mobile/device.dart';
import '../mobile/device_spec.dart';
import '../mobile/haskey.dart';
import '../coverage/coverage.dart';
import '../match/match_util.dart';
import '../globals.dart';
import '../commands/run.dart';
import '../runner/mdtest_command.dart';

class AutoCommand extends MDTestCommand {
  @override
  final String name = 'auto';

  @override
  final String description
    = 'Automatically run applications based on a subset of spec to device '
      'settings that maximize the device coverage';

  dynamic _specs;

  List<Device> _devices;

  @override
  Future<int> runCore() async {
    print('Running "mdtest auto command" ...');

    this._specs = await loadSpecs(argResults['specs']);

    this._devices = await getDevices();
    if (_devices.isEmpty) {
      printError('No device found.');
      return 1;
    }

    List<DeviceSpec> allDeviceSpecs
      = await constructAllDeviceSpecs(_specs['devices']);
    Map<DeviceSpec, Set<Device>> individualMatches
      = findIndividualMatches(allDeviceSpecs, _devices);
    List<Map<DeviceSpec, Device>> allDeviceMappings
      = findAllMatchingDeviceMappings(allDeviceSpecs, individualMatches);
    if(allDeviceMappings == null) {
      printError('No device specs to devices mapping is found.');
      return 1;
    }

    Map<String, List<Device>> deviceClusters = buildCluster(_devices);
    Map<String, List<DeviceSpec>> deviceSpecClusters
      = buildCluster(allDeviceSpecs);

    init(deviceClusters, deviceSpecClusters);
    Map<Coverage, Map<DeviceSpec, Device>> cov2match
      = buildCoverage2MatchMapping(allDeviceMappings);
    Set<Map<DeviceSpec, Device>> chosenMappings
      = findMinimumMappings(cov2match);
    printMatches(chosenMappings);

    List<int> errRounds = [];
    int roundNum = 1;
    for (Map<DeviceSpec, Device> deviceMapping in chosenMappings) {
      if (await runAllApps(deviceMapping) != 0) {
        printError('Error when running applications');
        if (!errRounds.contains(roundNum)) errRounds.add(roundNum);
      }

      await storeMatches(deviceMapping);

      if (await runTest(_specs['test-path']) != 0) {
        printError('Test execution exit with error.');
        if (!errRounds.contains(roundNum)) errRounds.add(roundNum);
      }
    }

    if (errRounds.isNotEmpty) {
      printError('Error in Round #${errRounds.join(", #")}');
      return 1;
    }

    return 0;
  }

  AutoCommand() {
    usesSpecsOption();
  }
}
