/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 *
 * @format
 */
"use strict"; // $FlowFixMe it exists!

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

const Module = require("module");

const path = require("path");

const builtinModules = new Set( // $FlowFixMe "process.binding" exists
  Module.builtinModules || Object.keys(process.binding("natives"))
);

module.exports = pnp => (context, request, platform) => {
  // We don't support builtin modules, so we force pnp to resolve those
  // modules as regular npm packages by appending a `/` character
  if (builtinModules.has(request)) {
    request += "/";
  }

  const unqualifiedPath = pnp.resolveToUnqualified(
    request,
    context.originModulePath
  );
  const baseExtensions = context.sourceExts.map(extension => `.${extension}`);

  let finalExtensions = _toConsumableArray(baseExtensions);

  if (context.preferNativePlatform) {
    finalExtensions = _toConsumableArray(
      baseExtensions.map(extension => `.native${extension}`)
    ).concat(_toConsumableArray(finalExtensions));
  }

  if (platform) {
    // We must keep a const reference to make Flow happy
    const p = platform;
    finalExtensions = _toConsumableArray(
      baseExtensions.map(extension => `.${p}${extension}`)
    ).concat(_toConsumableArray(finalExtensions));
  }

  try {
    return {
      type: "sourceFile",
      filePath: pnp.resolveUnqualified(unqualifiedPath, {
        extensions: finalExtensions
      })
    };
  } catch (error) {
    // Only catch the error if it was caused by the resolution process
    if (error.code !== "QUALIFIED_PATH_RESOLUTION_FAILED") {
      throw error;
    }

    const dirname = path.dirname(unqualifiedPath);
    const basename = path.basename(unqualifiedPath);
    const assetResolutions = context.resolveAsset(dirname, basename, platform);

    if (assetResolutions) {
      return {
        type: "assetFiles",
        filePaths: assetResolutions.map(name => `${dirname}/${name}`)
      };
    } else {
      throw error;
    }
  }
};
