/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 *
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

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) {
  try {
    var info = gen[key](arg);
    var value = info.value;
  } catch (error) {
    reject(error);
    return;
  }
  if (info.done) {
    resolve(value);
  } else {
    Promise.resolve(value).then(_next, _throw);
  }
}

function _asyncToGenerator(fn) {
  return function() {
    var self = this,
      args = arguments;
    return new Promise(function(resolve, reject) {
      var gen = fn.apply(self, args);
      function _next(value) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value);
      }
      function _throw(err) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err);
      }
      _next(undefined);
    });
  };
}

const GraphNotFoundError = require("./IncrementalBundler/GraphNotFoundError");

const IncrementalBundler = require("./IncrementalBundler");

const RevisionNotFoundError = require("./IncrementalBundler/RevisionNotFoundError");

const debounceAsyncQueue = require("./lib/debounceAsyncQueue");

const formatBundlingError = require("./lib/formatBundlingError");

const getGraphId = require("./lib/getGraphId");

const hmrJSBundle = require("./DeltaBundler/Serializers/hmrJSBundle");

const nullthrows = require("nullthrows");

const parseOptionsFromUrl = require("./lib/parseOptionsFromUrl");

const splitBundleOptions = require("./lib/splitBundleOptions");

const transformHelpers = require("./lib/transformHelpers");

const url = require("url");

const _require = require("metro-core"),
  _require$Logger = _require.Logger,
  createActionStartEntry = _require$Logger.createActionStartEntry,
  createActionEndEntry = _require$Logger.createActionEndEntry,
  log = _require$Logger.log;

function send(sendFns, message) {
  const strMessage = JSON.stringify(message);
  sendFns.forEach(sendFn => sendFn(strMessage));
}
/**
 * The HmrServer (Hot Module Reloading) implements a lightweight interface
 * to communicate easily to the logic in the React Native repository (which
 * is the one that handles the Web Socket connections).
 *
 * This interface allows the HmrServer to hook its own logic to WS clients
 * getting connected, disconnected or having errors (through the
 * `onClientConnect`, `onClientDisconnect` and `onClientError` methods).
 */

class HmrServer {
  constructor(bundler, createModuleId, config) {
    this._config = config;
    this._bundler = bundler;
    this._createModuleId = createModuleId;
    this._clientGroups = new Map();
  }

  onClientConnect(clientUrl, sendFn) {
    var _this = this;

    return _asyncToGenerator(function*() {
      const urlObj = nullthrows(url.parse(clientUrl, true));
      const query = nullthrows(urlObj.query);
      let revPromise;

      if (query.bundleEntry != null) {
        // TODO(T34760695): Deprecate
        urlObj.pathname = query.bundleEntry.replace(/\.js$/, ".bundle");
        delete query.bundleEntry;

        const _parseOptionsFromUrl = parseOptionsFromUrl(
            url.format(urlObj),
            new Set(_this._config.resolver.platforms)
          ),
          options = _parseOptionsFromUrl.options;

        const _splitBundleOptions = splitBundleOptions(options),
          entryFile = _splitBundleOptions.entryFile,
          transformOptions = _splitBundleOptions.transformOptions;
        /**
         * `entryFile` is relative to projectRoot, we need to use resolution function
         * to find the appropriate file with supported extensions.
         */

        const resolutionFn = yield transformHelpers.getResolveDependencyFn(
          _this._bundler.getBundler(),
          transformOptions.platform
        );
        const resolvedEntryFilePath = resolutionFn(
          `${_this._config.projectRoot}/.`,
          entryFile
        );
        const graphId = getGraphId(resolvedEntryFilePath, transformOptions);
        revPromise = _this._bundler.getRevisionByGraphId(graphId);

        if (!revPromise) {
          send([sendFn], {
            type: "error",
            body: formatBundlingError(new GraphNotFoundError(graphId))
          });
          return null;
        }
      } else {
        const revisionId = query.revisionId;
        revPromise = _this._bundler.getRevision(revisionId);

        if (!revPromise) {
          send([sendFn], {
            type: "error",
            body: formatBundlingError(new RevisionNotFoundError(revisionId))
          });
          return null;
        }
      }

      const _ref = yield revPromise,
        graph = _ref.graph,
        id = _ref.id;

      const client = {
        sendFn,
        revisionId: id
      };

      let clientGroup = _this._clientGroups.get(id);

      if (clientGroup != null) {
        clientGroup.clients.add(client);
      } else {
        clientGroup = {
          clients: new Set([client]),
          unlisten: () => unlisten(),
          revisionId: id
        };

        _this._clientGroups.set(id, clientGroup);

        const unlisten = _this._bundler
          .getDeltaBundler()
          .listen(
            graph,
            debounceAsyncQueue(
              _this._handleFileChange.bind(_this, clientGroup),
              50
            )
          );
      }

      yield _this._handleFileChange(clientGroup);
      return client;
    })();
  }

  onClientError(client, e) {
    this._config.reporter.update({
      type: "hmr_client_error",
      error: e
    });

    this.onClientDisconnect(client);
  }

  onClientDisconnect(client) {
    const group = this._clientGroups.get(client.revisionId);

    if (group != null) {
      if (group.clients.size === 1) {
        this._clientGroups.delete(client.revisionId);

        group.unlisten();
      } else {
        group.clients.delete(client);
      }
    }
  }

  _handleFileChange(group) {
    var _this2 = this;

    return _asyncToGenerator(function*() {
      const processingHmrChange = log(
        createActionStartEntry({
          action_name: "Processing HMR change"
        })
      );

      const sendFns = _toConsumableArray(group.clients).map(
        client => client.sendFn
      );

      send(sendFns, {
        type: "update-start"
      });
      const message = yield _this2._prepareMessage(group);
      send(sendFns, message);
      send(sendFns, {
        type: "update-done"
      });
      log(
        _objectSpread({}, createActionEndEntry(processingHmrChange), {
          outdated_modules:
            message.type === "update"
              ? message.body.added.length + message.body.modified.length
              : undefined
        })
      );
    })();
  }

  _prepareMessage(group) {
    var _this3 = this;

    return _asyncToGenerator(function*() {
      try {
        const revPromise = _this3._bundler.getRevision(group.revisionId);

        if (!revPromise) {
          return {
            type: "error",
            body: formatBundlingError(
              new RevisionNotFoundError(group.revisionId)
            )
          };
        }

        const _ref2 = yield _this3._bundler.updateGraph(
            yield revPromise,
            false
          ),
          revision = _ref2.revision,
          delta = _ref2.delta;

        _this3._clientGroups.delete(group.revisionId);

        group.revisionId = revision.id;

        for (const client of group.clients) {
          client.revisionId = revision.id;
        }

        _this3._clientGroups.set(group.revisionId, group);

        const hmrUpdate = hmrJSBundle(delta, revision.graph, {
          createModuleId: _this3._createModuleId,
          projectRoot: _this3._config.projectRoot
        });
        return {
          type: "update",
          body: _objectSpread(
            {
              revisionId: revision.id
            },
            hmrUpdate
          )
        };
      } catch (error) {
        const formattedError = formatBundlingError(error);

        _this3._config.reporter.update({
          type: "bundling_error",
          error
        });

        return {
          type: "error",
          body: formattedError
        };
      }
    })();
  }
}

module.exports = HmrServer;
