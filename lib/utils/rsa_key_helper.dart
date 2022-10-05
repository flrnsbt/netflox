// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart'
    show Platform;
import 'package:asn1lib/asn1lib.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:pointycastle/export.dart'
    show
        AsymmetricKeyPair,
        FortunaRandom,
        HMac,
        KeyDerivator,
        KeyParameter,
        PBKDF2KeyDerivator,
        PKCS7Padding,
        PaddedBlockCipherImpl,
        PaddedBlockCipherParameters,
        ParametersWithIV,
        ParametersWithRandom,
        Pbkdf2Parameters,
        PrivateKey,
        PublicKey,
        RSAKeyGenerator,
        RSAKeyGeneratorParameters,
        RSAPrivateKey,
        RSAPublicKey,
        SHA256Digest;

enum EncryptionLevel {
  b1024,
  b2048,
  b4096,
  b8192;

  int toInt() => int.parse(name.substring(1));
}

enum CipherProcessType { encrypt, decrypt }

class RSAKeysHelper {
  static const cipher = SSHCipherType.aes256ctr;
  static const defaultSalt = "yd973gf!9ie2_?!dww3rb";
  static const repetition = 1024;
  static const blockSize = 32;

  static String encodedtoPem(String encoded,
      [String type = "OPENSSH PRIVATE KEY"]) {
    final builder = StringBuffer();
    builder.writeln('-----BEGIN $type-----');
    builder.writeln(encoded);
    builder.writeln('-----END $type-----');
    return builder.toString();
  }

  static FortunaRandom _fortunaRandom([int blockSize = blockSize]) =>
      FortunaRandom()
        ..seed(KeyParameter(
            Platform.instance.platformEntropySource().getBytes(blockSize)));
  static Future<AsymmetricKeyPair<RSAPublicKey, NetfloxRSAPrivateKey>> generate(
      {String? passphrase,
      EncryptionLevel encryptionLevel = EncryptionLevel.b4096}) async {
    final parameters = RSAKeyGeneratorParameters(
        BigInt.from(65537), encryptionLevel.toInt(), 5);
    final generator = RSAKeyGenerator()
      ..init(ParametersWithRandom(parameters, _fortunaRandom()));
    final keys = await compute<RSAKeyGenerator,
            AsymmetricKeyPair<PublicKey, PrivateKey>>(
        (generator) => generator.generateKeyPair(), generator);
    NetfloxRSAPrivateKey privateKey = keys.privateKey.toRSAPrivateKey();
    if (passphrase != null) {
      privateKey = await privateKey.encrypt(passphrase);
    }
    return AsymmetricKeyPair(keys.publicKey as RSAPublicKey, privateKey);
  }

  static Uint8List _deriveKey(DeriveKeyConfig deriveKeyConfig) {
    Pbkdf2Parameters params = Pbkdf2Parameters(deriveKeyConfig.saltBytes,
        deriveKeyConfig.iterationCount, deriveKeyConfig.derivedKeyLength);
    KeyDerivator keyDerivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    keyDerivator.init(params);
    return keyDerivator.process(deriveKeyConfig.passphraseBytes);
  }

  static Future<Uint8List> deriveKey(DeriveKeyConfig deriveKeyConfig) {
    return compute(_deriveKey, deriveKeyConfig);
  }

  static Future<Uint8List> cipherProcess(
          CipherProcessConfig cipherProcessConfig) =>
      compute(_cipherProcess, cipherProcessConfig);

  static Future<Uint8List> _cipherProcess(
      CipherProcessConfig cipherProcessConfig) async {
    final saltBytes = const Utf8Encoder().convert(cipherProcessConfig.salt);
    final passphraseBytes =
        const Utf8Encoder().convert(cipherProcessConfig.passphrase);
    final derivedPassphraseBytes =
        await deriveKey(DeriveKeyConfig(passphraseBytes, saltBytes));
    final ParametersWithIV<KeyParameter> ivParams =
        ParametersWithIV<KeyParameter>(
            KeyParameter(derivedPassphraseBytes), _iv());
    final paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            ivParams, null);
    final paddedCipher =
        PaddedBlockCipherImpl(PKCS7Padding(), cipher.cipherFactory());
    paddedCipher.init(
        cipherProcessConfig.type == CipherProcessType.encrypt ? true : false,
        paddingParams);
    return paddedCipher.process(cipherProcessConfig.blob);
  }

  static Uint8List _iv() {
    return Uint8List.view(
        Uint8List(RSAKeysHelper.cipher.keySize + RSAKeysHelper.cipher.ivSize)
            .buffer,
        RSAKeysHelper.cipher.keySize,
        RSAKeysHelper.cipher.ivSize);
  }
}

class DeriveKeyConfig {
  final Uint8List passphraseBytes;
  final Uint8List saltBytes;
  final int iterationCount;
  final int derivedKeyLength;

  const DeriveKeyConfig(this.passphraseBytes, this.saltBytes,
      {this.iterationCount = RSAKeysHelper.repetition,
      this.derivedKeyLength = RSAKeysHelper.blockSize});
}

class CipherProcessConfig {
  final CipherProcessType type;
  final Uint8List blob;
  final String passphrase;
  final String salt;

  const CipherProcessConfig(
      {this.type = CipherProcessType.encrypt,
      required this.blob,
      required this.passphrase,
      this.salt = RSAKeysHelper.defaultSalt});
}

extension RSAKeyConverter on RsaPrivateKey {
  Uint8List toBlob() {
    final sequence = ASN1Sequence();
    sequence.add(ASN1Integer(BigInt.from(0)));
    sequence.add(ASN1Integer(n));
    sequence.add(ASN1Integer(e));
    sequence.add(ASN1Integer(d));
    sequence.add(ASN1Integer(p));
    sequence.add(ASN1Integer(q));
    sequence.add(ASN1Integer(exponent1));
    sequence.add(ASN1Integer(exponent2));
    sequence.add(ASN1Integer(coefficient));
    return sequence.encodedBytes;
  }
}

extension NetfloxRsaPublicKey on RSAPublicKey {
  Uint8List get keyBlob {
    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(ASN1Integer(modulus!));
    topLevelSeq.add(ASN1Integer(exponent!));
    return topLevelSeq.encodedBytes;
  }

  String toPem() {
    return SSHPem('RSA PUBLIC KEY', {}, keyBlob).encode(64);
  }
}

class NetfloxRSAPrivateKey extends PrivateKey {
  final Uint8List keyblob;

  NetfloxRSAPrivateKey(this.keyblob);
  factory NetfloxRSAPrivateKey.encode(
      BigInt n, BigInt exponent, BigInt privateExponent, BigInt p, BigInt q) {
    final BigInt dP = privateExponent % (p - BigInt.from(1));
    final BigInt dQ = privateExponent % (q - BigInt.from(1));
    final BigInt iQ = q.modInverse(p);
    final sequence = ASN1Sequence();
    sequence.add(ASN1Integer(BigInt.from(0)));
    sequence.add(ASN1Integer(n));
    sequence.add(ASN1Integer(exponent));
    sequence.add(ASN1Integer(privateExponent));
    sequence.add(ASN1Integer(p));
    sequence.add(ASN1Integer(q));
    sequence.add(ASN1Integer(dP));
    sequence.add(ASN1Integer(dQ));
    sequence.add(ASN1Integer(iQ));
    return NetfloxRSAPrivateKey(sequence.encodedBytes);
  }

  factory NetfloxRSAPrivateKey.fromPem(String pem) {
    final sshPem = SSHPem.decode(pem);
    return NetfloxRSAPrivateKey(sshPem.content);
  }

  @override
  String toString() {
    return "privateKey: ${toBase64()}";
  }

  String toBase64() {
    return base64Encode(keyblob);
  }

  String toPem() {
    return SSHPem('RSA PRIVATE KEY', {}, keyblob).encode(64);
  }

  FutureOr<RsaPrivateKey> getPrivateKeys([String? passphrase]) async {
    if (passphrase != null) {
      final blob = await RSAKeysHelper.cipherProcess(CipherProcessConfig(
          blob: keyblob,
          passphrase: passphrase,
          type: CipherProcessType.decrypt));

      return RsaPrivateKey.decode(blob);
    }

    return RsaPrivateKey.decode(keyblob);
  }

  Future<NetfloxRSAPrivateKey> encrypt(String passphrase) async {
    final encryptedBlob = await RSAKeysHelper.cipherProcess(
        CipherProcessConfig(blob: keyblob, passphrase: passphrase));
    return NetfloxRSAPrivateKey(encryptedBlob);
  }
}

extension AsymetricKeyPairMapExporter
    on AsymmetricKeyPair<RSAPublicKey, NetfloxRSAPrivateKey> {
  Map<String, String> toMap() {
    return {"privateKey": privateKey.toPem(), "publicKey": publicKey.toPem()};
  }
}

extension NetfloxPrivateKey on PrivateKey {
  NetfloxRSAPrivateKey toRSAPrivateKey() {
    if (this is RSAPrivateKey) {
      final k = this as RSAPrivateKey;
      return NetfloxRSAPrivateKey.encode(
          k.n!, k.exponent!, k.privateExponent!, k.p!, k.q!);
    }
    throw ArgumentError('Not a valid RSAPrivateKey instance');
  }
}
