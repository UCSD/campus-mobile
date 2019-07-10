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

const nullthrows = require("nullthrows");

const parseCustomTransformOptions = require("./parseCustomTransformOptions");

const parsePlatformFilePath = require("../node-haste/lib/parsePlatformFilePath");

const url = require("url");

const _require = require("../IncrementalBundler"),
  revisionIdFromString = _require.revisionIdFromString;

function getBoolOptionFromQuery(query, opt, defaultVal) {
  if (query[opt] == null) {
    return defaultVal;
  }

  return query[opt] === "true" || query[opt] === "1";
}

function parseOptionsFromUrl(reqUrl, platforms) {
  // `true` to parse the query param as an object.
  const urlObj = nullthrows(url.parse(reqUrl, true));
  const urlQuery = nullthrows(urlObj.query);
  const pathname =
    urlObj.pathname != null ? decodeURIComponent(urlObj.pathname) : "";
  let bundleType = "bundle"; // Backwards compatibility. Options used to be as added as '.' to the
  // entry module name. We can safely remove these options.

  const entryFileRelativeToProjectRoot = pathname
    .replace(/^(?:\.?\/)?/, "./") // We want to produce a relative path to project root
    .split(".")
    .filter((part, i) => {
      if (part === "delta" || part === "map" || part === "meta") {
        bundleType = part;
        return false;
      }

      if (
        part === "includeRequire" ||
        part === "runModule" ||
        part === "bundle" ||
        part === "assets"
      ) {
        return false;
      }

      return true;
    })
    .join("."); // try to get the platform from the url

  const platform =
    urlQuery.platform || parsePlatformFilePath(pathname, platforms).platform;
  const revisionId = urlQuery.revisionId || urlQuery.deltaBundleId || null;
  const dev = getBoolOptionFromQuery(urlQuery, "dev", true);
  const minify = getBoolOptionFromQuery(urlQuery, "minify", false);
  const excludeSource = getBoolOptionFromQuery(
    urlQuery,
    "excludeSource",
    false
  );
  const inlineSourceMap = getBoolOptionFromQuery(
    urlQuery,
    "inlineSourceMap",
    false
  );
  const runModule = getBoolOptionFromQuery(urlQuery, "runModule", true);
  const customTransformOptions = parseCustomTransformOptions(urlObj);
  return {
    revisionId: revisionId != null ? revisionIdFromString(revisionId) : null,
    options: {
      customTransformOptions,
      dev,
      hot: true,
      minify,
      platform,
      onProgress: null,
      entryFile: entryFileRelativeToProjectRoot,
      bundleType,
      sourceMapUrl: url.format(
        _objectSpread({}, urlObj, {
          // The remote chrome debugger loads bundles via Blob urls, whose
          // protocol is blob:http. This breaks loading source maps through
          // protocol-relative URLs, which is why we must force the HTTP protocol
          // when loading the bundle for either iOS or Android.
          protocol:
            platform != null && platform.match(/^(android|ios)$/) ? "http" : "",
          pathname: pathname.replace(/\.(bundle|delta)$/, ".map")
        })
      ),
      runModule,
      excludeSource,
      inlineSourceMap
    }
  };
}

module.exports = parseOptionsFromUrl;
