import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:blockchain_repository/blockchain_repository.dart';

class InternalBlockchainRepository extends BlockchainRepository {
  InternalBlockchainRepository(List<BlockchainProvider> providers)
      : super(providers);
}
