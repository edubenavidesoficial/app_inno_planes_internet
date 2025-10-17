import 'base_api_service.dart';
import '../../../data/models/menu_item_model.dart';

class MenuService extends BaseApiService {
  Future<List<MenuItemModel>> fetchMenu(String token) async {
    final data = await get('privilegios/modulos', headers: {
      'Authorization': 'Bearer $token',
    });

    return (data as List)
        .map((e) => MenuItemModel.fromJson(e))
        .toList();
  }
}
