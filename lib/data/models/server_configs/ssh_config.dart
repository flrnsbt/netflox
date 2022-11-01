class NetfloxSSHConfig {
  final String hostName;
  final int port;

  const NetfloxSSHConfig(this.hostName, this.port);

  factory NetfloxSSHConfig.fromMap(Map<String, dynamic> map) {
    return NetfloxSSHConfig(map['hostname'], map['port']);
  }

  @override
  String toString() {
    return 'SSHConfig(hostName: $hostName, port: $port, )';
  }
}
