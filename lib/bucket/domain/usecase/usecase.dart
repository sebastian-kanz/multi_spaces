export 'listen_bucket_events_usecase.dart';

/// Bucket Usecases:
/// - ListenBucketUseCase
///   This use case listens for changes
/// - SyncHistoryUseCase
///   This use case is responsible for comparing the local and the remote history and to sync it if the local is outdated.
///   It returns the history steps that were synced
/// - SyncElementsUseCase
///   It receives history steps and syncs the local elements.
/// 
/// Element Usecases:
/// - CreateElementUseCase (local / remote)
/// - UpdateElementUseCase (local / remote)
/// - RemoveElementUseCase (local / remote)
/// - SyncElementDataUseCase (remote)
///   This use case checks ipfs, if the data is available. If not (after x seconds) it requests data from the contract
/// - RemoveElementDataUseCase (local)
///   This use case checks ipfs, if the data is available. If not (after x seconds) it requests data from the contract
/// 