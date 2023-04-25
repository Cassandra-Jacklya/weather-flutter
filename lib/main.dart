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
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Weather(),
    );
  }
}

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Weather> {

  final WeatherBlock _weatherBlock = WeatherBlock();
  final TextEditingController _controller = TextEditingController();

  final HttpReq _httpReq = HttpReq();
  Map<String, dynamic> _finalData = {};
  bool _loading = true;
  String _bgImage = '';
  String _weather = '';
  int _temp = 0;
  int _farenheit = 0;
  bool _isCelsius = true;

  void _getBgImage() {
    setState(() {
      switch (_weather) {
        case 'Clouds':
          _bgImage = 'https://s7d2.scene7.com/is/image/TWCNews/clouds_jpg_jpg_jpgjpgjpg';
        break;
        case 'Clear':
          _bgImage = 'https://s7d2.scene7.com/is/image/TWCNews/img_3214_jpg-2';
        break;
        case 'Rain':
          _bgImage = 'https://www.wallpaperup.com/uploads/wallpapers/2014/01/06/216707/abd00579533df4fd77afd5c2ece1cc61-375.jpg';
        break;
        case 'Drizzle':
          _bgImage = 'https://previews.123rf.com/images/pohodka/pohodka1807/pohodka180700037/108184654-raindrops-on-the-glass-and-storm-clouds-in-the-background-rainy-weather-forecast.jpg';
        break;
        case 'Thunderstorm':
          _bgImage = 'https://grist.org/wp-content/uploads/2016/06/thunder-lightning-storm.jpg';
        break;
        case 'Snow':
          _bgImage = 'https://fournews-assets-prod-s3b-ew1-aws-c4-pml.s3.amazonaws.com/media/2017/12/snow_london_g_hd.jpg';
        break;
        case 'Mist':
          _bgImage = 'https://www.metoffice.gov.uk/binaries/content/gallery/metofficegovuk/hero-images/weather/fog--mist/foggy-morning-in-a-meadow.jpg';
        break;
        case 'Smoke':
          _bgImage = 'https://apicms.thestar.com.my/uploads/images/2020/09/23/870865.jpg';
        break;
        case 'Haze':
          _bgImage = 'https://guardian.ng/wp-content/uploads/2022/01/Hazy-weather.jpg';
        break;
        case 'Dust':
          _bgImage = 'https://image.khaleejtimes.com/?uuid=161fb4d5-dc4b-4781-a50f-03877a275841&function=cropresize&type=preview&source=false&q=75&crop_w=0.99999&crop_h=0.67286&x=0&y=0&width=1200&height=675';
        break;
        case 'Fog':
          _bgImage = 'https://www.wallpaperflare.com/static/799/715/769/fog-bridge-foggy-railway-wallpaper.jpg';
        break;
        default:
          _bgImage = '6495ED';
      }
    });
  }

//default
//blue page

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBlock, WeatherState>(
      bloc: _weatherBlock,
      builder: (context, state) {

        if (state is WeatherStateLoading) {
          return const CircularProgressIndicator();
        }
        else if (state is WeatherStateLoaded) {
          return Scaffold(
          appBar: AppBar(title: const Text("Weather App"),
          centerTitle: true,),
          body: Center(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
              ),
            ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
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
                              
                            },
                            child: const Icon(Icons.search))
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_controller.text,
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
                    ? Text('$_temp° Celsius',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    )
                    : Text('$_farenheit° Farenheit',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton(onPressed: () {
                      setState(() {
                        _isCelsius = !_isCelsius;
                      });
                    } ,
                    child: _isCelsius ? const Text("Convert to Farenheit") 
                    : const Text("Convert to Celsius"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        }
        else if (state is WeatherStateError) {
          return Container(color: Colors.amber,);
        }
        else {
          return Container(color: Colors.amber,);
        }
      }
    );
  }
}

class WeatherBlock extends Cubit<WeatherState> {
  WeatherBlock() : super(WeatherStateLoading()) {
    loadWeatherData();
  } 
  
  void loadWeatherData() async {
    const String baseUrl = "https://api.openweathermap.org/data/2.5/weather?q=cyberjaya&appid=4e7159ca25e61b17cd1f8b4f2db95cdd";
    final http.Response response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      String res = response.body;
      Map<String,dynamic> res2 = jsonDecode(res);

        String weather = getWeather(res2);
        int temp = getTemp(res2);
        emit(WeatherStateLoaded(weather, temp));
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
}

abstract class WeatherState{}

class WeatherStateLoading extends WeatherState {}

class WeatherStateLoaded extends WeatherState {
  WeatherStateLoaded(this.state, this.temp);

  final String state;
  final int temp;
}

class WeatherStateError extends WeatherState {}

class HttpReq {

  int convertToFarenheit(int celsius) {
    return (celsius.toDouble() * (9/5) + 32).toInt();
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Weather App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const Weather(),
//     );
//   }
// }

// class Weather extends StatefulWidget {
//   const Weather({super.key});

//   @override
//   State<Weather> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<Weather> {

//   final HttpReq _httpReq = HttpReq();
//   Map<String, dynamic> _finalData = {};
//   bool _loading = true;
//   String _bgImage = '';
//   String _weather = '';
//   int _temp = 0;
//   int _farenheit = 0;
//   bool _isCelsius = true;

//   @override
//   void initState() {
//     super.initState();
//     _getApi();
//   }

//   void _getApi() async {
//     const String baseUrl = "https://api.openweathermap.org/data/2.5/weather?q=cyberjaya&appid=4e7159ca25e61b17cd1f8b4f2db95cdd";
//     final http.Response response = await http.get(Uri.parse(baseUrl));
//     if (response.statusCode == 200) {
//       String res = response.body;
//       Map<String,dynamic> res2 = jsonDecode(res);

//       setState(() {
//         _finalData = res2;
//         _loading = false;
//         _weather = _httpReq.getWeather(_finalData);
//         _temp = _httpReq.getTemp(_finalData);
//         _farenheit = _httpReq.convertToFarenheit(_temp);
//         _getBgImage();

//       });
//     }
//     else {
//       throw Exception("Failed to load weather API");
//     }
//   }

//   void _getBgImage() {
//     setState(() {
//       switch (_weather) {
//         case 'Clouds':
//           _bgImage = 'https://s7d2.scene7.com/is/image/TWCNews/clouds_jpg_jpg_jpgjpgjpg';
//         break;
//         case 'Clear':
//           _bgImage = 'https://s7d2.scene7.com/is/image/TWCNews/img_3214_jpg-2';
//         break;
//         case 'Rain':
//           _bgImage = 'https://www.wallpaperup.com/uploads/wallpapers/2014/01/06/216707/abd00579533df4fd77afd5c2ece1cc61-375.jpg';
//         break;
//         case 'Drizzle':
//           _bgImage = 'https://previews.123rf.com/images/pohodka/pohodka1807/pohodka180700037/108184654-raindrops-on-the-glass-and-storm-clouds-in-the-background-rainy-weather-forecast.jpg';
//         break;
//         case 'Thunderstorm':
//           _bgImage = 'https://grist.org/wp-content/uploads/2016/06/thunder-lightning-storm.jpg';
//         break;
//         case 'Snow':
//           _bgImage = 'https://fournews-assets-prod-s3b-ew1-aws-c4-pml.s3.amazonaws.com/media/2017/12/snow_london_g_hd.jpg';
//         break;
//         case 'Mist':
//           _bgImage = 'https://www.metoffice.gov.uk/binaries/content/gallery/metofficegovuk/hero-images/weather/fog--mist/foggy-morning-in-a-meadow.jpg';
//         break;
//         case 'Smoke':
//           _bgImage = 'https://apicms.thestar.com.my/uploads/images/2020/09/23/870865.jpg';
//         break;
//         case 'Haze':
//           _bgImage = 'https://guardian.ng/wp-content/uploads/2022/01/Hazy-weather.jpg';
//         break;
//         case 'Dust':
//           _bgImage = 'https://image.khaleejtimes.com/?uuid=161fb4d5-dc4b-4781-a50f-03877a275841&function=cropresize&type=preview&source=false&q=75&crop_w=0.99999&crop_h=0.67286&x=0&y=0&width=1200&height=675';
//         break;
//         case 'Fog':
//           _bgImage = 'https://www.wallpaperflare.com/static/799/715/769/fog-bridge-foggy-railway-wallpaper.jpg';
//         break;
//         default:
//           _bgImage = '6495ED';
//       }
//     });
//   }

// //default
// //blue page

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Weather App"),
//       centerTitle: true,),
//       body: _loading 
//       ? const Center(child: CircularProgressIndicator(),)
//       : Center(
//         child: Container(
//           height: double.infinity,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             image: DecorationImage(image: NetworkImage(_bgImage),
//             fit: BoxFit.cover,
//           ),
//         ),
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(_httpReq.getLocation(_finalData),
//                     style: const TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(_httpReq.getWeather(_finalData),
//                     style: const TextStyle(
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//                 _isCelsius 
//                 ? Text('$_temp° Celsius',
//                   style: const TextStyle(
//                     fontSize: 14,
//                   ),
//                 )
//                 : Text('$_farenheit° Farenheit',
//                   style: const TextStyle(
//                     fontSize: 14,
//                   ),
//                 ),
//                 ElevatedButton(onPressed: () {
//                   setState(() {
//                     _isCelsius = !_isCelsius;
//                   });
//                 } ,
//                 child: _isCelsius ? const Text("Convert to Farenheit") 
//                 : const Text("Convert to Celsius"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class HttpReq {
//   String getLocation (Map<String, dynamic>? data) {
//     String location = '';
//     location = data!['name'];
//     return location;
//   }

//   String getWeather (Map<String, dynamic>? data) {
//     String weather = '';
//     weather = data!['weather'][0]['main'];
//     return weather;
//   }

//   int getTemp (Map<String, dynamic>? data) {
//     double temp = 0;
//     temp = data!['main']['temp'] - 273.15;
//     return temp.toInt();
//   }

//   int convertToFarenheit(int celsius) {
//     return (celsius.toDouble() * (9/5) + 32).toInt();
//   }
// }