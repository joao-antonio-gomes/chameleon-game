import 'dart:convert';

import 'package:chameleon/models/chameleon_open_ai.dart';
import 'package:chameleon/models/room.dart';
import 'package:http/http.dart' as http;

class ChatGptService {
  final String apiKey;

  ChatGptService({required this.apiKey});

  Future<ChameleonOpenAi?> generateThemes(Room room) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v2',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-4",
      "messages": [
        {
          "role": "system",
          "content": "Você é um gerador de temas criativos para jogos entre amigos."
              " O jogo consiste em um dos jogadores não saber o tema, enquanto os "
              "outros que sabem falam características do tema. O jogador que não sabe o tema também"
              "fala características sobre o tema mesmo sem saber, pois ele tem que se infiltrar"
              "e descobrir o tema. O objetivo é que o jogador que não sabe o tema descubra o tema"
              "através das características que os outros jogadores falam enquanto não é descoberto."
              "Um tema deve ser uma coisa, não um conjunto de coisas. Você deve fornecer junto ao tema, uma categoria, mas a categoria deve ser genérica."
              "O tema deve ser algo que a maioria das pessoas conheça, e que seja possível de ser descrito em uma ou poucas palavras."
              "O tema não pode ser óbvio, mas também não impossível de ser descoberto."
              "Devolver a resposta em json, com as propriedade theme e category."
              "O tema e categoria não deve vir com acentuação para evitar problemas de encode."
              "Exemplo: {\"theme\": \"Cachorro\", \"category\": \"Animal\"}"
              "Dito isso, me forneça um tema para a partida."
        }
      ],
      "max_tokens": 50,
      "temperature": 0.7,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final contentJson = jsonDecode(content);
        return ChameleonOpenAi.fromJson(contentJson);
      } else {
        print('Erro ao obter tema: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exceção ao obter tema: $e');
      return null;
    }
  }
}
