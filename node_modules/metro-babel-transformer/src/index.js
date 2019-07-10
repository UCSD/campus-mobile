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

const _require = require("@babel/core"),
  transformSync = _require.transformSync;

function transform(_ref) {
  let filename = _ref.filename,
    options = _ref.options,
    plugins = _ref.plugins,
    src = _ref.src;
  const OLD_BABEL_ENV = process.env.BABEL_ENV;
  process.env.BABEL_ENV = options.dev
    ? "development"
    : process.env.BABEL_ENV || "production";

  try {
    const _transformSync = transformSync(src, {
        caller: {
          name: "metro",
          platform: options.platform
        },
        ast: true,
        babelrc: options.enableBabelRCLookup,
        code: false,
        highlightCode: true,
        filename,
        plugins,
        sourceType: "module"
      }),
      ast = _transformSync.ast;

    return {
      ast
    };
  } finally {
    process.env.BABEL_ENV = OLD_BABEL_ENV;
  }
}

module.exports = {
  transform
};
