import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:web3dart/crypto.dart';

// The public key needs to be in uncompressed form starting with 0x04...
ECPublicKey hexToPublicKey(String publicKeyHex) {
  var adaptedKey = publicKeyHex;
  if (!publicKeyHex.startsWith("04")) {
    adaptedKey = "04$publicKeyHex";
  }
  final ecParams = ECCurve_secp256k1();
  final x = BigInt.parse(adaptedKey.substring(2, 66), radix: 16);
  final y = BigInt.parse(adaptedKey.substring(66), radix: 16);
  final ecPoint = ecParams.curve.createPoint(x, y);
  return ECPublicKey(ecPoint, ecParams);
}

ECPrivateKey hexToPrivateKey(String privateKeyHex) {
  final ecParams = ECCurve_secp256k1();
  final p = BigInt.parse(privateKeyHex, radix: 16);
  return ECPrivateKey(p, ecParams);
}

String publicKeyToHex(ECPublicKey publicKey) {
  final x = publicKey.Q!.x!.toBigInteger();
  final y = publicKey.Q!.y!.toBigInteger();
  final xHex = x!.toRadixString(16).padLeft(64, '0');
  final yHex = y!.toRadixString(16).padLeft(64, '0');
  return '04$xHex$yHex';
}

String privateKeyToHex(ECPrivateKey privateKey) {
  final d = privateKey.d!;
  return d.toRadixString(16).padLeft(64, '0');
}

BigInt calcSharedSecret(ECPrivateKey privateKey, ECPublicKey publicKey) {
  final agreement = ECDHBasicAgreement();
  agreement.init(privateKey);
  return agreement.calculateAgreement(publicKey);
}

class AESCombo {
  Uint8List key;
  Uint8List iv;
  AESCombo(this.key, this.iv);
}

AESCombo hexToAescombo(String hex) {
  final bytes = hexToBytes(hex);
  return bytesToAESCombo(bytes);
}

String aesComboToHex(AESCombo combo) {
  final builder = BytesBuilder();
  builder.add(combo.iv);
  builder.add(combo.key);
  final bytes = builder.toBytes();
  return bytesToHex(bytes);
}

Uint8List aesComboToBytes(AESCombo combo) {
  final builder = BytesBuilder();
  builder.add(combo.iv);
  builder.add(combo.key);
  return builder.toBytes();
}

AESCombo bytesToAESCombo(Uint8List bytes) {
  final ivBytes = bytes.sublist(0, 16);
  final keyBytes = bytes.sublist(16, 16 + 32);
  return AESCombo(keyBytes, ivBytes);
}

Uint8List generateRandomBytes(int length) {
  final random = FortunaRandom();
  final seedSource = Random.secure();
  final seed =
      Uint8List.fromList(List.generate(32, (_) => seedSource.nextInt(256)));
  random.seed(KeyParameter(seed));
  return random.nextBytes(length);
}

Uint8List bigIntToBytes(BigInt bigInt) {
  final byteCount = (bigInt.bitLength + 7) ~/ 8;
  final result = Uint8List(byteCount);
  for (var i = 0; i < byteCount; i++) {
    result[i] = bigInt.toUnsigned(8).toInt();
    bigInt = bigInt >> 8;
  }
  return result;
}

Uint8List writeBigInt(BigInt number) {
  // Not handling negative numbers. Decide how you want to do that.
  int bytes = (number.bitLength + 7) >> 3;
  var b256 = BigInt.from(256);
  var result = Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[i] = number.remainder(b256).toInt();
    number = number >> 8;
  }
  return result;
}

Uint8List aesEncrypt(Uint8List data, Uint8List key, Uint8List iv) {
  final CBCBlockCipher cbcCipher = CBCBlockCipher(AESEngine());
  final ParametersWithIV<KeyParameter> ivParams =
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
  final PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>
      paddingParams =
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
          ivParams, null);

  final PaddedBlockCipherImpl paddedCipher =
      PaddedBlockCipherImpl(PKCS7Padding(), cbcCipher);
  paddedCipher.init(true, paddingParams);
  final encrypted = paddedCipher.process(data);
  final decrypted = aesDecrypt(encrypted, key, iv);
  if (bytesToHex(data) != bytesToHex(decrypted)) {
    throw Exception("Decryption does not work!!!");
  }
  return encrypted;
}

Uint8List aesDecrypt(Uint8List data, Uint8List key, Uint8List iv) {
  final CBCBlockCipher cbcCipher = CBCBlockCipher(AESEngine());
  final ParametersWithIV<KeyParameter> ivParams =
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
  final PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>
      paddingParams =
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
    ivParams,
    null,
  );
  final PaddedBlockCipherImpl paddedCipher =
      PaddedBlockCipherImpl(PKCS7Padding(), cbcCipher);
  paddedCipher.init(false, paddingParams);

  return paddedCipher.process(data);
}
