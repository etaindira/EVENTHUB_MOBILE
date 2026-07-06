import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      'https://eventhub-backend-lgpa.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
    });
  }

  void joinEventRoom(int eventId) {
    _socket?.emit('join_event_room', eventId);
  }

  void leaveEventRoom(int eventId) {
    _socket?.emit('leave_event_room', eventId);
  }

  void listenToRsvpUpdates(Function(dynamic data) callback) {
    _socket?.off('rsvp_updated');
    _socket?.on('rsvp_updated', callback);
  }

  void listenToInvitationStatusUpdates(Function(dynamic data) callback) {
    _socket?.off('invitation_status_updated');
    _socket?.on('invitation_status_updated', callback);
  }

  void listenToCheckInUpdates(Function(dynamic data) callback) {
    _socket?.off('checkin_updated');
    _socket?.on('checkin_updated', callback);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
