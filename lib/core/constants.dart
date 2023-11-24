import 'package:web3dart/web3dart.dart';

// Padding
const double kPaddingS = 8.0;
const double kPaddingM = 16.0;
const double kPaddingL = 32.0;

// Spacing
const double kSpaceS = 8.0;
const double kSpaceM = 16.0;

// Animation
const Duration kButtonAnimationDuration = Duration(milliseconds: 600);
const Duration kCardAnimationDuration = Duration(milliseconds: 400);
const Duration kRippleAnimationDuration = Duration(milliseconds: 400);
const Duration kLoginAnimationDuration = Duration(milliseconds: 1500);

final EthereumAddress zeroAddress =
    EthereumAddress.fromHex('0x0000000000000000000000000000000000000000');

// Hive
const int hiveMetaModelTypeId = 1;
const int hiveElementModelTypeId = 2;
const int hiveOperationModelTypeId = 3;
const int hiveContainerModelTypeId = 4;
const int hiveEthereumAddressTypeId = 5;
