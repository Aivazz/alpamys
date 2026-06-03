import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OpenRouterService {
  // =========================================================================
  // API KEY CONFIGURATION
  // =========================================================================
  // Paste your OpenRouter API key here:
  static const String apiKey = "YOUR_OPENROUTER_API_KEY"; 
  // =========================================================================

  static const String endpoint = "https://openrouter.ai/api/v1/chat/completions";
  static const String defaultModel = "google/gemini-2.5-flash"; // Fast and smart

  Future<String> getChatResponse(List<Map<String, String>> conversationHistory) async {
    if (apiKey.isEmpty || apiKey.startsWith("YOUR_")) {
      return "Lütfen OpenRouter API anahtarını `openrouter_service.dart` dosyasına ekleyin.";
    }

    try {
      final List<Map<String, String>> messages = [
        {
          "role": "system",
          "content": "Sen AlpamysAI adında uzman bir spor, fitness ve beslenme asistanısın. "
              "Egzersiz programları, antrenman teknikleri, sağlıklı beslenme, kalori/makro hesaplama, sporcu gıdaları ve sağlıklı yaşam konularında derin bilgiye sahipsin. "
              "Kullanıcıya HER ZAMAN TÜRKÇE dilinde yanıt vermelisin. "
              "Kullanıcı spor, egzersiz, fitness, diyet veya beslenme DIŞINDA bir soru sorarsa, kibarca bu konuların dışına çıkamayacağını belirt ve konuyu tekrar spor/beslenmeye yönlendir. "
              "Yanıtların profesyonel, motive edici, net ve detaylı olmalıdır. Maddeler halinde (bullet points) yapılandırılmış yanıtlar tercih edilir."
        },
        ...conversationHistory
      ];

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
          "HTTP-Referer": "https://alpamys-fitness-app.com", // Optional site metadata
          "X-Title": "Alpamys Pass Fitness App",
        },
        body: jsonEncode({
          "model": defaultModel,
          "messages": messages,
          "temperature": 0.7,
          "max_tokens": 1000,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String reply = data['choices'][0]['message']['content']?.toString() ?? "";
        if (reply.isNotEmpty) {
          return reply;
        }
      } else {
        debugPrint("OpenRouter Error: ${response.statusCode} - ${response.body}");
        return "Özür dilerim, şu anda yanıt oluşturamıyorum. Hata Kodu: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("OpenRouter Connection Error: $e");
      return "Sunucuya bağlanırken bir sorun oluştu. Lütfen internet bağlantınızı kontrol edin.";
    }
    return "Beklenmedik bir hata oluştu.";
  }
}
