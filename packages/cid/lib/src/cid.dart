// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:typed_data';

import 'package:base32/encodings.dart';
import 'package:cid/src/multicodec.dart';
import 'package:convert/convert.dart';

import 'package:base32/base32.dart';
import 'package:dart_multihash/dart_multihash.dart';
import 'package:multibase/multibase.dart';

enum BASE { base32, base58 }

final SHA2_256_HEX = hex.encode([multiCodecs[7].code]); // 0x12 => sha2-256
const SHA2_256_LENGTH = "20"; // 0x20 => 32 Byte => 256 Bits
const VERSION_0_PREFIX = "Qm";
const VERSION_1_PREFIX = "b";
const VERSION_1_HEX = "01";

class Cid {
  late Uint8List digest;
  late MultiCodec codec;

  Cid(String cid) {
    if (cid.length == 46 && cid.startsWith(VERSION_0_PREFIX)) {
      codec = cidV0Codec;
      final multibaseDecoded = multibaseDecode("z$cid");
      final multibaseDecodedHex = hex.encode(multibaseDecoded);
      if (multibaseDecodedHex.substring(0, 2) != SHA2_256_HEX &&
          multibaseDecodedHex.substring(0, 2) != SHA2_256_LENGTH) {
        throw Exception("Invalid Multihash.");
      }
      digest = Uint8List.fromList(multibaseDecoded.sublist(2));
    } else if (cid.startsWith(VERSION_1_PREFIX)) {
      final decoded = base32.decode(cid.substring(1).toUpperCase(),
          encoding: Encoding.standardRFC4648);
      final decodedHex = hex.encode(decoded);
      final ipldCodecs =
          multiCodecs.where((elem) => elem.tag == "ipld").toList();
      codec = ipldCodecs.firstWhere(
        (elem) {
          final hex = elem.code.toRadixString(16);
          var adaptedHex = hex;
          if (hex.length.isOdd) {
            adaptedHex = "0$hex";
          }
          if (adaptedHex.length == 2 &&
              adaptedHex == decodedHex.substring(2, 4)) {
            return true;
          }
          if (adaptedHex.length == 4 &&
              adaptedHex.substring(0, 2) == decodedHex.substring(2, 4) &&
              adaptedHex.substring(2, 4) == decodedHex.substring(4, 6)) {
            return true;
          }
          return false;
        },
        orElse: () => throw Exception("No supported CID codec!"),
      );
      if (!decodedHex.startsWith(VERSION_1_HEX) &&
          !decodedHex.startsWith(SHA2_256_HEX, 4) &&
          !decodedHex.startsWith(SHA2_256_LENGTH, 6)) {
        throw Exception("Invalid CID v1!");
      }
      digest = Uint8List.fromList(decoded.sublist(4));
    } else {
      throw Exception("Invalid CID!");
    }
  }

  String asV0String() {
    if (codec != cidV0Codec) {
      throw Exception("Cid not convertible to v0!");
    }

    final data = Multihash.encode("sha2-256", digest);
    final result = multibaseEncode(Multibase.base58btc, data);
    return result.substring(1);
  }

  String asV1String() {
    final version = hex.decode(VERSION_1_HEX);
    final multiHash = Multihash.encode("sha2-256", digest);
    final data = Uint8List.fromList([
      ...Uint8List.fromList(version),
      ...Uint8List.fromList([codec.code]),
      ...multiHash
    ]);
    final result = base32.encode(data);
    final formatted = "B${result.replaceAll("=", "")}".toLowerCase();
    return formatted;
  }
}
