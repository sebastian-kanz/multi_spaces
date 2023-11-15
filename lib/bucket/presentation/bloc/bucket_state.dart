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

Failure _errorFromJson(Map<String, dynamic> json) =>
    BlocFailure(json['error'] ?? "");

Map<String, dynamic> _errorToJson(Failure? error) =>
    {'error': error?.failure ?? ""};

@JsonSerializable()
class BucketState extends Equatable {
  const BucketState({
    this.status = BucketStatus.initial,
    this.elements = const [],
    this.parents = const [],
    this.requestors = const [],
    this.isExternal = false,
    this.participationFulfilled = false,
    this.nestedEvent,
    this.error,
    this.epoch,
    this.newElement = null,
    this.confirmTx = false,
  });

  factory BucketState.fromJson(Map<String, dynamic> json) =>
      _$BucketStateFromJson(json);

  final BucketStatus status;
  final List<FullElementEntity> elements;
  final List<FullElementEntity> parents;
  @JsonKey(fromJson: _requestorsFromJson, toJson: _requestorsToJson)
  final List<EthereumAddress> requestors;
  final bool isExternal;
  final bool participationFulfilled;
  final CreateElementEvent? nestedEvent;
  @JsonKey(fromJson: _errorFromJson, toJson: _errorToJson)
  final Failure? error;
  final int? epoch;
  final String? newElement;
  final bool? confirmTx;

  BucketState copyWith(
      {BucketStatus? status,
      List<FullElementEntity>? elements,
      List<FullElementEntity>? parents,
      List<EthereumAddress>? requestors,
      CreateElementEvent? nestedEvent,
      Failure? error,
      int? epoch,
      bool? isExternal,
      bool? participationFulfilled,
      String? newElement,
      bool? confirmTx}) {
    return BucketState(
      status: status ?? this.status,
      elements: elements ?? this.elements,
      parents: parents ?? this.parents,
      requestors: requestors ?? this.requestors,
      isExternal: isExternal ?? this.isExternal,
      participationFulfilled:
          participationFulfilled ?? this.participationFulfilled,
      nestedEvent: nestedEvent ?? this.nestedEvent,
      error: error ?? this.error,
      epoch: epoch ?? this.epoch,
      newElement: newElement ?? this.newElement,
      confirmTx: confirmTx ?? this.confirmTx,
    );
  }

  Map<String, dynamic> toJson() => _$BucketStateToJson(this);

  @override
  List<Object?> get props => [
        status,
        elements,
        parents,
        requestors,
        isExternal,
        participationFulfilled,
        nestedEvent,
        error,
        epoch,
        newElement,
      ];
}
