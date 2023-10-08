part of 'bucket_bloc.dart';

enum BucketStatus {
  initial,
  initialized,
  loading,
  success,
  ready,
  failure,
  waitingForParticipation,
  waitingForKeys
}

List<EthereumAddress> _requestorsFromJson(List<String> jsonList) =>
    jsonList.map((e) => EthereumAddress.fromHex(e)).toList();

List<String> _requestorsToJson(List<EthereumAddress> requestors) =>
    requestors.map((e) => e.hex).toList();

@JsonSerializable()
class BucketState extends Equatable {
  const BucketState({
    this.status = BucketStatus.initial,
    this.elements = const [],
    this.parents = const [],
    this.requestors = const [],
    this.nestedEvent,
    this.error,
    this.epoch,
  });

  factory BucketState.fromJson(Map<String, dynamic> json) =>
      _$BucketStateFromJson(json);

  final BucketStatus status;
  final List<FullElementEntity> elements;
  final List<FullElementEntity> parents;
  @JsonKey(fromJson: _requestorsFromJson, toJson: _requestorsToJson)
  final List<EthereumAddress> requestors;
  final CreateElementEvent? nestedEvent;
  final Object? error;
  final int? epoch;

  BucketState copyWith({
    BucketStatus? status,
    List<FullElementEntity>? elements,
    List<FullElementEntity>? parents,
    List<EthereumAddress>? requestors,
    CreateElementEvent? nestedEvent,
    Failure? error,
    int? epoch,
  }) {
    return BucketState(
      status: status ?? this.status,
      elements: elements ?? this.elements,
      parents: parents ?? this.parents,
      requestors: requestors ?? this.requestors,
      nestedEvent: nestedEvent ?? this.nestedEvent,
      error: error ?? this.error,
      epoch: epoch ?? this.epoch,
    );
  }

  Map<String, dynamic> toJson() => _$BucketStateToJson(this);

  @override
  List<Object?> get props => [
        status,
        elements,
        parents,
        requestors,
        nestedEvent,
        error,
        epoch,
      ];
}

// abstract class BucketState extends Equatable {
//   final List<FullElementEntity> elements;
//   final List<FullElementEntity> parents;
//   final List<EthereumAddress> requestors;
//   const BucketState(this.elements, this.parents, this.requestors);

//   @override
//   List<Object> get props => [elements];
// }

// class BucketStateInitial extends BucketState {
//   BucketStateInitial() : super([], [], []);
// }

// class BucketInitialized extends BucketState {
//   BucketInitialized() : super([], [], []);
// }

// class WaitingForParticipation extends BucketState {
//   final bool isInternal;
//   WaitingForParticipation(this.isInternal) : super([], [], []);
// }

// class BucketError extends BucketState {
//   final Object error;
//   BucketError(this.error) : super([], [], []);

//   @override
//   List<Object> get props => [elements, error];
// }

// class BucketLoaded extends BucketState {
//   const BucketLoaded(elements, parents, requestors)
//       : super(
//           elements,
//           parents,
//           requestors,
//         );
// }

// class BucketLoading extends BucketState {
//   BucketLoading(parents) : super([], parents, []);
// }

// class BucketReady extends BucketState {
//   final BucketEvent event;
//   const BucketReady(elements, parents, this.event, requestors)
//       : super(
//           elements,
//           parents,
//           requestors,
//         );

//   @override
//   List<Object> get props => [elements, event];
// }

// class WaitingForKeys extends BucketState {
//   final BucketEvent event;
//   final int epoch;
//   const WaitingForKeys(elements, parents, requestors, this.event, this.epoch)
//       : super(elements, parents, requestors);

//   @override
//   List<Object> get props => [elements, event, epoch];
// }
