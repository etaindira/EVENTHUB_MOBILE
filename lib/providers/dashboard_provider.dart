import 'dart:async';

import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository = DashboardRepository();

  List<DashboardEventModel> _events = [];
  DashboardEventModel? _selectedEvent;
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _summary;
  List<CheckinGuestModel> _checkins = [];

  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  List<DashboardEventModel> get events => _events;
  DashboardEventModel? get selectedEvent => _selectedEvent;
  Map<String, dynamic>? get analytics => _analytics;
  Map<String, dynamic>? get summary => _summary;
  List<CheckinGuestModel> get checkins => _checkins;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardEvents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _events = await _dashboardRepository.getDashboardEvents();
      _summary = await _dashboardRepository.getDashboardSummary();

      if (_events.isNotEmpty && _selectedEvent == null) {
        _selectedEvent = _events.first;
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

  Future<void> selectEvent(DashboardEventModel event) async {
    _selectedEvent = event;
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

  void startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_selectedEvent != null) {
        fetchEventAnalytics(_selectedEvent!.id);
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
