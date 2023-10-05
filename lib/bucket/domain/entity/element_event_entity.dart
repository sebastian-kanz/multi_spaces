import 'package:equatable/equatable.dart';
import 'package:web3dart/web3dart.dart';

abstract class ElementEventEntity extends Equatable {
  const ElementEventEntity();

  @override
  List<Object> get props => [];
}

class CreateElementEventEntity extends ElementEventEntity {
  final EthereumAddress element;
  final int blockNumber;
  final EthereumAddress sender;

  const CreateElementEventEntity(this.element, this.blockNumber, this.sender);
}

class DeleteElementEventEntity extends ElementEventEntity {
  final EthereumAddress element;
  final int blockNumber;
  final EthereumAddress sender;

  const DeleteElementEventEntity(this.element, this.blockNumber, this.sender);
}

class UpdateElementEventEntity extends ElementEventEntity {
  final EthereumAddress previousElement;
  final EthereumAddress newElement;
  final int blockNumber;
  final EthereumAddress sender;

  const UpdateElementEventEntity(
    this.previousElement,
    this.newElement,
    this.blockNumber,
    this.sender,
  );
}

class UpdateParentElementEventEntity extends ElementEventEntity {
  final EthereumAddress previousElement;
  final EthereumAddress parent;
  final int blockNumber;
  final EthereumAddress sender;

  const UpdateParentElementEventEntity(
    this.previousElement,
    this.parent,
    this.blockNumber,
    this.sender,
  );
}

class ElementRequestEventEntity extends ElementEventEntity {
  final EthereumAddress element;
  final EthereumAddress requestor;
  final int block;

  const ElementRequestEventEntity(this.element, this.requestor, this.block);
}
