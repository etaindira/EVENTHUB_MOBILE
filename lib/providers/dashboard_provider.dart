import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../repositories/dashboard_repository.dart';
import '../services/socket_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository = DashboardRepository();

  SocketService? _socketService;

  List<DashboardEventModel> _events = [];
  DashboardEventModel? _selectedEvent;
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _summary;
  List<CheckinGuestModel> _checkins = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<DashboardEventModel> get events => _events;
  DashboardEventModel? get selectedEvent => _selectedEvent;
  Map<String, dynamic>? get analytics => _analytics;
  Map<String, dynamic>? get summary => _summary;
  List<CheckinGuestModel> get checkins => _checkins;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void initializeSocket(SocketService socketService) {
    _socketService = socketService;

    _socketService!.connect();

    _socketService!.listenToRsvpUpdates((data) {
      debugPrint("Analytics RSVP update: $data");
      refreshSelectedEvent();
    });

    _socketService!.listenToInvitationStatusUpdates((data) {
      debugPrint("Analytics invitation update: $data");
      refreshSelectedEvent();
      fetchDashboardSummary();
    });

    _socketService!.listenToCheckInUpdates((data) {
      debugPrint("Analytics check-in update: $data");
      refreshSelectedEvent();
    });

    if (_selectedEvent != null) {
      _socketService!.joinEventRoom(_selectedEvent!.id);
    }
  }

  Future<void> fetchDashboardEvents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _events = await _dashboardRepository.getDashboardEvents();
      _summary = await _dashboardRepository.getDashboardSummary();

      if (_events.isNotEmpty && _selectedEvent == null) {
        _selectedEvent = _events.first;
        _socketService?.joinEventRoom(_selectedEvent!.id);
        await fetchEventAnalytics(_selectedEvent!.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> fetchDashboardSummary() async {
    try {
      _summary = await _dashboardRepository.getDashboardSummary();
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> selectEvent(DashboardEventModel event) async {
    if (_selectedEvent != null) {
      _socketService?.leaveEventRoom(_selectedEvent!.id);
    }

    _selectedEvent = event;

    _socketService?.connect();
    _socketService?.joinEventRoom(event.id);

    notifyListeners();

    await fetchEventAnalytics(event.id);
  }

  Future<void> fetchEventAnalytics(int eventId) async {
    try {
      _errorMessage = null;

      _analytics = await _dashboardRepository.getEventAnalytics(eventId);
      _checkins = await _dashboardRepository.getEventCheckins(eventId);

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> refreshSelectedEvent() async {
    if (_selectedEvent == null) return;

    await fetchEventAnalytics(_selectedEvent!.id);
  }

  @override
  void dispose() {
    if (_selectedEvent != null) {
      _socketService?.leaveEventRoom(_selectedEvent!.id);
    }

    super.dispose();
  }
}
