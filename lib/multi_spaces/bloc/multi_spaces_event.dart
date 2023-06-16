part of 'multi_spaces_bloc.dart';

abstract class MultiSpacesEvent extends Equatable {
  const MultiSpacesEvent();

  @override
  List<Object> get props => [];
}

class MultiSpacesInitialized extends MultiSpacesEvent {
  const MultiSpacesInitialized();
}

class MultiSpacesStarted extends MultiSpacesEvent {
  const MultiSpacesStarted();
}

class CreateSpacePressed extends MultiSpacesEvent {
  const CreateSpacePressed();
}

class SpaceCreated extends MultiSpacesEvent {
  final String spaceAddress;
  const SpaceCreated(this.spaceAddress);

  @override
  List<Object> get props => [spaceAddress];
}
