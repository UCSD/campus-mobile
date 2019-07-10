/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 *
 * @format
 */
"use strict";

function _toConsumableArray(arr) {
  return (
    _arrayWithoutHoles(arr) || _iterableToArray(arr) || _nonIterableSpread()
  );
}

function _nonIterableSpread() {
  throw new TypeError("Invalid attempt to spread non-iterable instance");
}

function _iterableToArray(iter) {
  if (
    Symbol.iterator in Object(iter) ||
    Object.prototype.toString.call(iter) === "[object Arguments]"
  )
    return Array.from(iter);
}

function _arrayWithoutHoles(arr) {
  if (Array.isArray(arr)) {
    for (var i = 0, arr2 = new Array(arr.length); i < arr.length; i++)
      arr2[i] = arr[i];
    return arr2;
  }
}

const getInlineSourceMappingURL = require("../DeltaBundler/Serializers/helpers/getInlineSourceMappingURL");

const nullthrows = require("nullthrows");

const sourceMapString = require("../DeltaBundler/Serializers/sourceMapString");

function getAppendScripts(entryPoint, modules, options) {
  const output = [];

  if (options.runModule) {
    const paths = _toConsumableArray(options.runBeforeMainModule).concat([
      entryPoint
    ]);

    for (const path of paths) {
      if (modules.some(module => module.path === path)) {
        output.push({
          path: `require-${path}`,
          dependencies: new Map(),
          getSource: () => Buffer.from(""),
          inverseDependencies: new Set(),
          output: [
            {
              type: "js/script/virtual",
              data: {
                code: options.getRunModuleStatement(
                  options.createModuleId(path)
                ),
                map: []
              }
            }
          ]
        });
      }
    }
  }

  if (options.inlineSourceMap || options.sourceMapUrl) {
    const sourceMappingURL = options.inlineSourceMap
      ? getInlineSourceMappingURL(
          sourceMapString(modules, {
            processModuleFilter: () => true,
            excludeSource: false
          })
        )
      : nullthrows(options.sourceMapUrl);
    output.push({
      path: "source-map",
      dependencies: new Map(),
      getSource: () => Buffer.from(""),
      inverseDependencies: new Set(),
      output: [
        {
          type: "js/script/virtual",
          data: {
            code: `//# sourceMappingURL=${sourceMappingURL}`,
            map: []
          }
        }
      ]
    });
  }

  return output;
}

module.exports = getAppendScripts;
