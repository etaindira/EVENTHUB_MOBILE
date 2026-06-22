import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService _dashboardService = DashboardService();

  Future<List<DashboardEventModel>> getDashboardEvents() async {
    final data = await _dashboardService.getDashboardEvents();

    return data.map((json) {
      return DashboardEventModel.fromJson(json);
    }).toList();
  }

  Future<Map<String, dynamic>> getEventAnalytics(int eventId) async {
    return await _dashboardService.getEventAnalytics(eventId);
  }

  Future<List<CheckinGuestModel>> getEventCheckins(int eventId) async {
    final data = await _dashboardService.getEventCheckins(eventId);

    return data.map((json) {
      return CheckinGuestModel.fromJson(json);
    }).toList();
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    return await _dashboardService.getDashboardSummary();
  }
}
