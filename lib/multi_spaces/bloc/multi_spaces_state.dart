part of 'multi_spaces_bloc.dart';

abstract class MultiSpaceState extends Equatable {
  const MultiSpaceState();

  @override
  List<Object> get props => [];
}

class MultiSpacesLoading extends MultiSpaceState {}

class NoSpaceExisting extends MultiSpaceState {}

class NoInternetConnectionAvailable extends MultiSpaceState {}

class SpaceCreationInProgress extends MultiSpaceState {
  final String transactionHash;
  const SpaceCreationInProgress(this.transactionHash);

  @override
  List<Object> get props => [transactionHash];
}

class MultiSpacesReady extends MultiSpaceState {
  final EthereumAddress paymentManagerAddress;
  final EthereumAddress spaceAddress;

  const MultiSpacesReady(this.spaceAddress, this.paymentManagerAddress);

  @override
  List<Object> get props => [spaceAddress];

  MultiSpacesReady fromJson(Map<String, dynamic> json) {
    final spaceAddress = json['spaceAddress'];
    final paymentManagerAddress = json['paymentManagerAddress'];
    if (spaceAddress != null) {
      return MultiSpacesReady(spaceAddress, paymentManagerAddress);
    }
    throw Exception("Missing value for " + spaceAddress);
  }

  Map<String, dynamic> toJson(MultiSpacesReady state) => {
        'spaceAddress': state.spaceAddress,
        'paymentManagerAddress': state.paymentManagerAddress,
      };
}
