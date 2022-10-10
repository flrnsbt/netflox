class NetfloxSSHConfig {
  final String hostName;
  final String username;
  final int port;

  const NetfloxSSHConfig(this.hostName, this.username, this.port);

  factory NetfloxSSHConfig.fromMap(Map<String, dynamic> map) {
    return NetfloxSSHConfig(map['hostname'], map['username'], map['port']);
  }

  @override
  String toString() {
    return 'SSHConfig(hostName: $hostName, username: $username, port: $port, )';
  }
}
