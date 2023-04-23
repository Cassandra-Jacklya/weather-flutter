class HttpReq {
  String getLocation (Map<String, dynamic>? data) {
    String location = '';
    location = data!['name'];
    return location;
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
}