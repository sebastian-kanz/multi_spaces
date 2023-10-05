enum EIP155Methods {
  personalSign,
  ethSignTransaction,
  // signTypedDataV4,
  ethSendTransaction,
  // walletRequestPermissions
}

enum EIP155Events {
  chainChanged,
  accountsChanged,
}

class EIP155 {
  static final Map<EIP155Methods, String> methods = {
    EIP155Methods.personalSign: 'personal_sign',
    EIP155Methods.ethSignTransaction: 'eth_signTransaction',
    // EIP155Methods.signTypedDataV4: 'eth_signTypedData_v4',
    EIP155Methods.ethSendTransaction: 'eth_sendTransaction',
    // EIP155Methods.walletRequestPermissions: 'wallet_requestPermissions',
  };

  static final Map<EIP155Events, String> events = {
    EIP155Events.chainChanged: 'chainChanged',
    EIP155Events.accountsChanged: 'accountsChanged',
  };
}
