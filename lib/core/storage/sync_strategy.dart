import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SyncOperationType { insert, update, delete }

class SyncOperation {
  final String id;
  final String tableName;
  final SyncOperationType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  SyncOperation({
    required this.id,
    required this.tableName,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tableName': tableName,
        'type': type.toString().split('.').last,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'] as String,
        tableName: json['tableName'] as String,
        type: SyncOperationType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
        ),
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class SyncStrategy {
  final SupabaseClient _supabaseClient;
  final List<SyncOperation> _syncQueue = [];
  bool _isSyncing = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  SyncStrategy(this._supabaseClient) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncPendingOperations();
      }
    });
  }

  // Add operations to the sync queue for local offline persistence
  Future<void> queueOperation({
    required String tableName,
    required SyncOperationType type,
    required Map<String, dynamic> payload,
  }) async {
    final operation = SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableName: tableName,
      type: type,
      payload: payload,
      timestamp: DateTime.now(),
    );

    // Save locally to Drift/Hive here
    _syncQueue.add(operation);

    // Try to run sync immediately if we have a connection
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      syncPendingOperations();
    }
  }

  // Push pending actions to Supabase and handle conflicts
  Future<void> syncPendingOperations() async {
    if (_isSyncing || _syncQueue.isEmpty) return;

    _isSyncing = true;
    print('Legibris Sync: Starting background data synchronization... (${_syncQueue.length} operations)');

    List<SyncOperation> successfullySynced = [];

    try {
      // Order operations by oldest to newest to preserve logic
      _syncQueue.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      for (var op in _syncQueue) {
        final success = await _executeRemoteSync(op);
        if (success) {
          successfullySynced.add(op);
        } else {
          // Break synchronization if network drops midway
          break;
        }
      }

      // Remove successful sync elements from the queue
      _syncQueue.removeWhere((op) => successfullySynced.contains(op));
      print('Legibris Sync: Sync successfully completed. remaining: ${_syncQueue.length}');
    } catch (e) {
      print('Legibris Sync: Sync encountered errors: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _executeRemoteSync(SyncOperation op) async {
    try {
      final table = _supabaseClient.from(op.tableName);

      switch (op.type) {
        case SyncOperationType.insert:
          await table.insert(op.payload);
          break;
          
        case SyncOperationType.update:
          // Implement Last-Write-Wins validation comparing updatedAt before writing
          final recordId = op.payload['id'];
          if (recordId != null) {
            final existing = await table.select('updated_at').eq('id', recordId).maybeSingle();
            if (existing != null) {
              final remoteUpdated = DateTime.parse(existing['updated_at'] as String);
              if (remoteUpdated.isAfter(op.timestamp)) {
                // Ignore update if remote is newer (conflict resolved via LWW)
                print('Legibris Sync Conflict: Remote record is newer. Local update discarded.');
                return true;
              }
            }
            await table.update(op.payload).eq('id', recordId);
          }
          break;
          
        case SyncOperationType.delete:
          final recordId = op.payload['id'];
          if (recordId != null) {
            await table.delete().eq('id', recordId);
          }
          break;
      }
      return true;
    } catch (e) {
      print('Legibris Sync Error pushing table ${op.tableName}: $e');
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
