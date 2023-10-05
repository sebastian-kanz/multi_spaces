part of 'multi_spaces_bloc.dart';

abstract class MultiSpacesEvent extends Equatable {
  const MultiSpacesEvent();

  @override
  List<Object> get props => [];
}

class MultiSpacesStarted extends MultiSpacesEvent {
  const MultiSpacesStarted();
}

class CreateSpacePressed extends MultiSpacesEvent {
  const CreateSpacePressed();
}

class InternetConnectionLost extends MultiSpacesEvent {
  const InternetConnectionLost();
}

class SpaceCreated extends MultiSpacesEvent {
  final String spaceAddress;
  const SpaceCreated(this.spaceAddress);

  @override
  List<Object> get props => [spaceAddress];
}
