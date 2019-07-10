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

function _objectSpread(target) {
  for (var i = 1; i < arguments.length; i++) {
    var source = arguments[i] != null ? arguments[i] : {};
    var ownKeys = Object.keys(source);
    if (typeof Object.getOwnPropertySymbols === "function") {
      ownKeys = ownKeys.concat(
        Object.getOwnPropertySymbols(source).filter(function(sym) {
          return Object.getOwnPropertyDescriptor(source, sym).enumerable;
        })
      );
    }
    ownKeys.forEach(function(key) {
      _defineProperty(target, key, source[key]);
    });
  }
  return target;
}

function _defineProperty(obj, key, value) {
  if (key in obj) {
    Object.defineProperty(obj, key, {
      value: value,
      enumerable: true,
      configurable: true,
      writable: true
    });
  } else {
    obj[key] = value;
  }
  return obj;
}

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

const addParamsToDefineCall = require("../../lib/addParamsToDefineCall");

const getInlineSourceMappingURL = require("./helpers/getInlineSourceMappingURL");

const getSourceMapInfo = require("./helpers/getSourceMapInfo");

const _require = require("./helpers/js"),
  isJsModule = _require.isJsModule,
  wrapModule = _require.wrapModule;

const _require2 = require("metro-source-map"),
  fromRawMappings = _require2.fromRawMappings;

function generateModules(sourceModules, graph, options) {
  const modules = [];
  const sourceMappingURLs = [];
  const sourceURLs = [];

  for (const module of sourceModules) {
    if (isJsModule(module)) {
      const code = _prepareModule(module, graph, options);

      const mapInfo = getSourceMapInfo(module, {
        excludeSource: false
      });
      sourceMappingURLs.push(
        getInlineSourceMappingURL(
          fromRawMappings([mapInfo]).toString(undefined, {
            excludeSource: false
          })
        )
      );
      sourceURLs.push(mapInfo.path);
      modules.push([options.createModuleId(module.path), code]);
    }
  }

  return {
    modules,
    sourceMappingURLs,
    sourceURLs
  };
}

function hmrJSBundle(delta, graph, options) {
  const _generateModules = generateModules(
      delta.added.values(),
      graph,
      options
    ),
    added = _generateModules.modules,
    addedSourceMappingURLs = _generateModules.sourceMappingURLs,
    addedSourceURLs = _generateModules.sourceURLs;

  const _generateModules2 = generateModules(
      delta.modified.values(),
      graph,
      options
    ),
    modified = _generateModules2.modules,
    modifiedSourceMappingURLs = _generateModules2.sourceMappingURLs,
    modifiedSourceURLs = _generateModules2.sourceURLs;

  return {
    added,
    modified,
    deleted: _toConsumableArray(delta.deleted).map(path =>
      options.createModuleId(path)
    ),
    addedSourceMappingURLs,
    addedSourceURLs,
    modifiedSourceMappingURLs,
    modifiedSourceURLs
  };
}

function _prepareModule(module, graph, options) {
  const code = wrapModule(
    module,
    _objectSpread({}, options, {
      dev: true
    })
  );

  const inverseDependencies = _getInverseDependencies(module.path, graph); // Transform the inverse dependency paths to ids.

  const inverseDependenciesById = Object.create(null);
  Object.keys(inverseDependencies).forEach(path => {
    inverseDependenciesById[options.createModuleId(path)] = inverseDependencies[
      path
    ].map(options.createModuleId);
  });
  return addParamsToDefineCall(code, inverseDependenciesById);
}
/**
 * Instead of adding the whole inverseDependncies object into each changed
 * module (which can be really huge if the dependency graph is big), we only
 * add the needed inverseDependencies for each changed module (we do this by
 * traversing upwards the dependency graph).
 */

function _getInverseDependencies(path, graph) {
  let inverseDependencies =
    arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};

  // Dependency alredy traversed.
  if (path in inverseDependencies) {
    return inverseDependencies;
  }

  const module = graph.dependencies.get(path);

  if (!module) {
    return inverseDependencies;
  }

  inverseDependencies[path] = [];

  for (const inverse of module.inverseDependencies) {
    inverseDependencies[path].push(inverse);

    _getInverseDependencies(inverse, graph, inverseDependencies);
  }

  return inverseDependencies;
}

module.exports = hmrJSBundle;
