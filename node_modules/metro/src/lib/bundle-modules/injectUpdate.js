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

function _slicedToArray(arr, i) {
  return (
    _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _nonIterableRest()
  );
}

function _nonIterableRest() {
  throw new TypeError("Invalid attempt to destructure non-iterable instance");
}

function _iterableToArrayLimit(arr, i) {
  var _arr = [];
  var _n = true;
  var _d = false;
  var _e = undefined;
  try {
    for (
      var _i = arr[Symbol.iterator](), _s;
      !(_n = (_s = _i.next()).done);
      _n = true
    ) {
      _arr.push(_s.value);
      if (i && _arr.length === i) break;
    }
  } catch (err) {
    _d = true;
    _e = err;
  } finally {
    try {
      if (!_n && _i["return"] != null) _i["return"]();
    } finally {
      if (_d) throw _e;
    }
  }
  return _arr;
}

function _arrayWithHoles(arr) {
  if (Array.isArray(arr)) return arr;
}

function injectModules(modules, sourceMappingURLs, sourceURLs) {
  modules.forEach((_ref, i) => {
    let _ref2 = _slicedToArray(_ref, 2),
      id = _ref2[0],
      code = _ref2[1];

    // In JSC we need to inject from native for sourcemaps to work
    // (Safari doesn't support `sourceMappingURL` nor any variant when
    // evaluating code) but on Chrome we can simply use eval.
    const injectFunction =
      typeof global.nativeInjectHMRUpdate === "function"
        ? global.nativeInjectHMRUpdate
        : eval; // eslint-disable-line no-eval
    // Fool regular expressions trying to remove sourceMappingURL comments from
    // source files, which would incorrectly detect and remove the inlined
    // version.

    const pragma = "sourceMappingURL";
    injectFunction(
      code + `\n//# ${pragma}=${sourceMappingURLs[i]}`,
      sourceURLs[i]
    );
  });
}

function injectUpdate(update) {
  injectModules(
    update.added,
    update.addedSourceMappingURLs,
    update.addedSourceURLs
  );
  injectModules(
    update.modified,
    update.modifiedSourceMappingURLs,
    update.modifiedSourceURLs
  );
}

module.exports = injectUpdate;
