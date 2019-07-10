/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 *  strict-local
 * @format
 */
"use strict";

const getSourceMapInfo = require("./helpers/getSourceMapInfo");

const _require = require("./helpers/js"),
  isJsModule = _require.isJsModule;

const _require2 = require("metro-source-map"),
  fromRawMappings = _require2.fromRawMappings;

function sourceMapGenerator(modules, options) {
  const sourceMapInfos = modules
    .filter(isJsModule)
    .filter(options.processModuleFilter)
    .map(module =>
      getSourceMapInfo(module, {
        excludeSource: options.excludeSource
      })
    );
  return fromRawMappings(sourceMapInfos);
}

module.exports = sourceMapGenerator;
