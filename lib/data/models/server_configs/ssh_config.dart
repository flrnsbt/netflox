class NetfloxSSHConfig {
  final String hostName;
  final String username;
  final int port;

  final String remoteDirectoryPath;

  const NetfloxSSHConfig(
      this.hostName, this.username, this.port, this.remoteDirectoryPath);

  factory NetfloxSSHConfig.fromMap(Map<String, dynamic> map) {
    return NetfloxSSHConfig(map['hostname'], map['username'], map['port'],
        map['remote_directory_path']);
  }

  @override
  String toString() {
    return 'SSHConfig(hostName: $hostName, username: $username, port: $port, remoteDirectoryPath: $remoteDirectoryPath)';
  }
}
