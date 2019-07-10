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

const sourceMapGenerator = require("./sourceMapGenerator");

function sourceMapObject(modules, options) {
  return sourceMapGenerator(modules, options).toMap(undefined, {
    excludeSource: options.excludeSource
  });
}

module.exports = sourceMapObject;
