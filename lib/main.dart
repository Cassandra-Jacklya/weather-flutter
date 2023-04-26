import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
      return BlocProvider<WeatherBlock>(
        child: MaterialApp(
          title: 'Weather App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const Weather(),
        ), 
        create: (BuildContext context) { 
          return WeatherBlock();
        },
      );
  }
}

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Weather> {

  late final TextEditingController _controller;
  String text = '';

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  bool _isCelsius = true;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text("Weather App"),
          centerTitle: true,
          ),
          body: Center(
            child: BlocBuilder<WeatherBlock, WeatherState>(
              builder: (context, state) {
                if (state is WeatherStateLoaded) {
                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(state.bgImage),
                      fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: "Enter city name",
                            border: const OutlineInputBorder(),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                BlocProvider.of<WeatherBlock>(context).loadWeatherData(
                                  _controller.text);
                                setState(() {
                                  text = _controller.text;
                                });
                                _controller.clear();
                              },
                              child: const Icon(Icons.search))
                            ),
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(text,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(state.state,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        _isCelsius 
                        ? Text('${state.temp}° Celsius',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        )
                        : Text('${state.celsius}° Farenheit',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(onPressed: () {
                            setState(() {
                              _isCelsius = !_isCelsius;
                            });
                            } ,
                            child: _isCelsius 
                              ? const Text("Convert to Farenheit") 
                              : const Text("Convert to Celsius"),
                          ),
                        ),
                      ]
                    ),
                  );
                }
                else if (state is WeatherStateLoading) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "Enter city name",
                          border: const OutlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              BlocProvider.of<WeatherBlock>(context).loadWeatherData(
                                _controller.text);
                              setState(() {
                                text = _controller.text;
                              });
                              _controller.clear();
                            },
                            child: const Icon(Icons.search))
                          ),
                        )
                      ),
                    ]
                  );
                }
                else if (state is WeatherStateError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "Enter city name",
                          border: const OutlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              BlocProvider.of<WeatherBlock>(context).loadWeatherData(
                                _controller.text);
                              setState(() {
                                text = _controller.text;
                              });
                              _controller.clear();
                            },
                            child: const Icon(Icons.search))
                          ),
                        )
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Failed to load data"),
                      ),
                    ]
                  );
                }
                else {
                  return const Text("Something is wrong");
                }
              }
            ),
          ),
        );
      }
    );
  }
}

class WeatherBlock extends Cubit<WeatherState> {
  WeatherBlock() : super(WeatherStateLoading());
  
  void loadWeatherData(String location) async {
    String baseUrl = "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=aad8a8b0844e03da85810f1f7c78d28d";
    final http.Response response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      String res = response.body;
      Map<String,dynamic> res2 = jsonDecode(res);

        String weather = getWeather(res2);
        int temp = getTemp(res2);
        int celsius = convertToFarenheit(temp);
        String bgImage = getBgImage(weather);
        emit(WeatherStateLoaded(weather, temp, celsius, bgImage));
    }
    else {
      emit(WeatherStateError());
    }
  }

  String getWeather (Map<String, dynamic>? data) {
    String weather = '';
    weather = data!['weather'][0]['main'];
    return weather;
  }

  int getTemp (Map<String, dynamic>? data) {
    double temp = 0;
    temp = data!['main']['temp'] - 273.15;
    return temp.toInt();
  }

  int convertToFarenheit(int celsius) {
    return (celsius.toDouble() * (9/5) + 32).toInt();
  }

  String getBgImage(String weather) {
    String bgImage = '';
    switch (weather) {
      case 'Clouds':
        bgImage = 'https://s7d2.scene7.com/is/image/TWCNews/clouds_jpg_jpg_jpgjpgjpg';
      break;
      case 'Clear':
        bgImage = 'https://s7d2.scene7.com/is/image/TWCNews/img_3214_jpg-2';
      break;
      case 'Rain':
        bgImage = 'https://www.wallpaperup.com/uploads/wallpapers/2014/01/06/216707/abd00579533df4fd77afd5c2ece1cc61-375.jpg';
      break;
      case 'Drizzle':
        bgImage = 'https://previews.123rf.com/images/pohodka/pohodka1807/pohodka180700037/108184654-raindrops-on-the-glass-and-storm-clouds-in-the-background-rainy-weather-forecast.jpg';
      break;
      case 'Thunderstorm':
        bgImage = 'https://grist.org/wp-content/uploads/2016/06/thunder-lightning-storm.jpg';
      break;
      case 'Snow':
        bgImage = 'https://fournews-assets-prod-s3b-ew1-aws-c4-pml.s3.amazonaws.com/media/2017/12/snow_london_g_hd.jpg';
      break;
      case 'Mist':
        bgImage = 'https://www.metoffice.gov.uk/binaries/content/gallery/metofficegovuk/hero-images/weather/fog--mist/foggy-morning-in-a-meadow.jpg';
      break;
      case 'Smoke':
        bgImage = 'https://apicms.thestar.com.my/uploads/images/2020/09/23/870865.jpg';
      break;
      case 'Haze':
        bgImage = 'https://guardian.ng/wp-content/uploads/2022/01/Hazy-weather.jpg';
      break;
      case 'Dust':
        bgImage = 'https://image.khaleejtimes.com/?uuid=161fb4d5-dc4b-4781-a50f-03877a275841&function=cropresize&type=preview&source=false&q=75&crop_w=0.99999&crop_h=0.67286&x=0&y=0&width=1200&height=675';
      break;
      case 'Fog':
        bgImage = 'https://www.wallpaperflare.com/static/799/715/769/fog-bridge-foggy-railway-wallpaper.jpg';
      break;
      default:
        bgImage = 'https://wallpapercave.com/wp/wp6903417.jpg';
    }
    return bgImage;
  }
}

abstract class WeatherState{}

class WeatherStateLoading extends WeatherState {}

class WeatherStateLoaded extends WeatherState {
  WeatherStateLoaded(this.state, this.temp, this.celsius, this.bgImage);

  final String state;
  final int temp;
  final int celsius;
  final String bgImage;
}

class WeatherStateError extends WeatherState {}