import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationRepository {
  Future<String?> getAreaFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse"
        "?lat=$latitude&lon=$longitude&format=jsonv2",
      );

      final response = await http.get(
        url,
        headers: {
          "User-Agent": "hrms-attendance-app",
          "Accept-Language": "en",
        },
      );

      print(
        "\n==================== REVERSE GEOCODE RESPONSE =====================",
      );
      print("URL: $url");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print(
        "===================================================================\n",
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final address = data["address"];

      if (address == null) return null;

      // 🌍 Global locality priority
      final area =
          address["suburb"] ??
          address["neighbourhood"] ??
          address["city"] ??
          address["town"] ??
          address["village"] ??
          address["municipality"] ??
          address["county"];

      final state = address["state"];
      final country = address["country"];

      if (area == null && state == null && country == null) {
        return null;
      }

      // Build clean parts list
      List<String> parts = [];

      if (area != null && area.toString().isNotEmpty) {
        parts.add(_capitalize(area));
      }

      if (state != null && state.toString().isNotEmpty && state != area) {
        parts.add(_capitalize(state));
      }

      if (country != null &&
          country.toString().isNotEmpty &&
          country != state) {
        parts.add(_capitalize(country));
      }

      if (parts.isEmpty) return null;

      return parts.join(", ");
    } catch (_) {
      return null;
    }
  }

  String _capitalize(String input) {
    return input
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ');
  }
}
