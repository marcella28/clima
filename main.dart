import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_icons/weather_icons.dart'; // Importe o pacote weather_icons

void main() {
  runApp(ClimaApp());
}

class ClimaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith( // Usar um tema claro
        primaryColor: const Color.fromARGB(255, 150, 188, 219),
        hintColor: Colors.black,
      ),
      darkTheme: ThemeData.dark().copyWith( // Usar um tema escuro
        primaryColor: Colors.black,
        hintColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Clima'),
        ),
        body: ClimaWidget(),
      ),
    );
  }
}

class ClimaWidget extends StatefulWidget {
  @override
  _ClimaWidgetState createState() => _ClimaWidgetState();
}

class _ClimaWidgetState extends State<ClimaWidget> {
  String cidade = "";
  double temperatura = 0.0;
  String condicaoClimatica = "";
  IconData iconeClima = WeatherIcons.alien; // Ícone padrão

  final apiKey = 'd177a5e5bf904470d6a92fb2b1a52b53'; // Substitua pela sua chave de API do OpenWeatherMap

  Color corClima(String descricao) {
    // Mapeie a descrição para uma cor específica
    switch (descricao.toLowerCase()) {
      case 'ensolarado':
        return Colors.yellow;
      case 'nublado':
        return Color.fromARGB(255, 94, 85, 85);
      case 'chuva':
        return Color.fromARGB(255, 31, 49, 63);
      case 'nuvens dispersas':
        return Color.fromARGB(255, 58, 135, 223);
      default:
        return const Color.fromARGB(255, 5, 35, 59); // Cor padrão
    }
  }

  IconData mapearIcone(String codigoIcone) {
    // Mapeie o código de ícone para o ícone correspondente no pacote weather_icons
    switch (codigoIcone) {
      case '01d':
        return WeatherIcons.day_sunny;
      case '01n':
        return WeatherIcons.night_clear;
      case '02d':
        return WeatherIcons.day_cloudy;
      case '02n':
        return WeatherIcons.night_cloudy;
      case '03d':
        return WeatherIcons.day_cloudy_high;
      case '03n':
        return WeatherIcons.night_cloudy_high;
      case '04d':
      case '04n':
        return WeatherIcons.cloudy;
      case '09d':
      case '09n':
        return WeatherIcons.showers;
      case '10d':
        return WeatherIcons.day_rain;
      case '10n':
        return WeatherIcons.night_rain;
      case '11d':
      case '11n':
        return WeatherIcons.thunderstorm;
      case '13d':
      case '13n':
        return WeatherIcons.snow;
      case '50d':
      case '50n':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.alien; // Ícone padrão
    }
  }

  Future<void> buscarTemperatura(String cidade) async {
    final apiUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=${cidade.replaceAll(" ", "+")}&appid=$apiKey&units=metric&lang=pt_br');

    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        cidade = data['name'];
        temperatura = data['main']['temp'];
        condicaoClimatica = data['weather'][0]['description'];
        iconeClima = mapearIcone(data['weather'][0]['icon']);
      });
    } else {
      // Trate o erro aqui, por exemplo, exibindo uma mensagem de erro para o usuário.
      print('Erro na solicitação à API: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color cor = corClima(condicaoClimatica);
    Color corContainer = corClima(condicaoClimatica);

    return Container(
      color: corContainer, // Define a cor de fundo do contêiner com base na condição climática
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Informe o nome da cidade:"),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (text) {
                cidade = text;
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              buscarTemperatura(cidade);
            },
            child: Text("Buscar Temperatura"),
          ),
          SizedBox(height: 16),
          Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Temperatura atual: ",
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                SizedBox(height: 8),
                Text(
                  "$temperatura°C",
                  style: TextStyle(fontSize: 24, color: Theme.of(context).hintColor),
                ),
                SizedBox(height: 8),
                Text(
                  "Condição Climática: $condicaoClimatica",
                  style: TextStyle(fontSize: 18, color: cor),
                ),
                SizedBox(height: 8),
                Icon(
                  iconeClima,
                  size: 48,
                  color: Theme.of(context).hintColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
