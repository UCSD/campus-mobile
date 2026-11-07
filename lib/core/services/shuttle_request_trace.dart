import 'package:flutter/foundation.dart';

enum ShuttleRequestTrigger { startup, selectionChange, manualReload, unspecified }

enum ShuttleRequestEndpoint { catalog, arrivals }

enum ShuttleRequestTraceKind {
  providerOperationStarted,
  providerRequestStarted,
  providerRequestJoined,
  providerRequestSkipped,
  providerResultDiscarded,
  logicalRequestStarted,
  httpAttemptStarted,
  httpAttemptSucceeded,
  httpAttemptFailed,
  retryScheduled,
}

class ShuttleRequestContext {
  const ShuttleRequestContext({required this.operationId, required this.trigger});

  final int operationId;
  final ShuttleRequestTrigger trigger;
}

class ShuttleRequestTraceEvent {
  const ShuttleRequestTraceEvent({
    required this.kind,
    required this.context,
    this.endpoint,
    this.stopId,
    this.logicalRequestId,
    this.attempt,
    this.statusCode,
    this.elapsed,
    this.retryDelay,
  });

  final ShuttleRequestTraceKind kind;
  final ShuttleRequestContext context;
  final ShuttleRequestEndpoint? endpoint;
  final String? stopId;
  final int? logicalRequestId;
  final int? attempt;
  final int? statusCode;
  final Duration? elapsed;
  final Duration? retryDelay;

  @override
  String toString() =>
      'ShuttleRequestTraceEvent('
      'kind: ${kind.name}, '
      'operation: ${context.operationId}, '
      'trigger: ${context.trigger.name}, '
      'endpoint: ${endpoint?.name}, '
      'stopId: $stopId, '
      'logicalRequest: $logicalRequestId, '
      'attempt: $attempt, '
      'status: $statusCode, '
      'elapsedMs: ${elapsed?.inMilliseconds}, '
      'retryDelayMs: ${retryDelay?.inMilliseconds})';
}

typedef ShuttleRequestTraceObserver = void Function(ShuttleRequestTraceEvent event);

void debugLogShuttleRequestTrace(ShuttleRequestTraceEvent event) {
  if (kDebugMode) debugPrint(event.toString());
}
