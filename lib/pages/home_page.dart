import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_full1/components/custom_icon_buttom.dart';
import 'package:weather_full1/constants/app_colors.dart';
import 'package:weather_full1/constants/app_text.dart';
import 'package:weather_full1/constants/app_text_styles.dart';
import 'package:weather_full1/models/weather_model.dart';

import '../constants/api_const.dart';

List<String> cities = [
  'bishkek',
  'osh',
  'jalal-abad',
  'batken',
  'naryn',
  'talas',
  'yssyk-kol',
  'leylek',
  'kadamzhai',
  'chon-alai',
  'nookat',
  'aravan',
  'kara-suu',
  'alai',
  'ozgen',
  'kara-kulja',
  'suzak',
  'bazar-korgon',
  'nooken',
  'aksy',
  'ala-buka',
  'chatkal',
  'toktogul',
  'toguz-toro',
  'aitmatov',
  'bakai-ata',
  'manas',
  'panfilov',
  'zhayil',
  'moscow',
  'sokoluk',
  'alamud',
  'issyk-ata',
  'kemin',
  'jumgal',
  'kochkor',
  'ak-talaa',
  'at-bashi',
  'tup',
  'tong',
  'jeti-oguz',
  'ak-suu',
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WeatherModel? weatherModel;

  Future<void> weatherLocation() async {
    setState(() {
      weatherModel = null;
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always &&
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        final dio = Dio();
        final response = await dio.get(ApiConst.getLocator(
          lat: position.latitude,
          lon: position.longitude,
        ));
        if (response.statusCode == 200 || response.statusCode == 201) {
          weatherModel = WeatherModel(
            id: response.data['weather'][0]['id'],
            main: response.data['weather'][0]['main'],
            description: response.data['weather'][0]['description'],
            icon: response.data['weather'][0]['icon'],
            temp: response.data['main']['temp'],
            country: response.data['sys']['country'],
            city: response.data['name'],
          );
        }
        setState(() {});
      }
    } else {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      final response = await dio.get(ApiConst.getLocator(
        lat: position.latitude,
        lon: position.longitude,
      ));
      if (response.statusCode == 200 || response.statusCode == 201) {
        weatherModel = WeatherModel(
          id: response.data['weather'][0]['id'],
          main: response.data['weather'][0]['main'],
          description: response.data['weather'][0]['description'],
          icon: response.data['weather'][0]['icon'],
          temp: response.data['main']['temp'],
          country: response.data['sys']['country'],
          city: response.data['name'],
        );
      }
      setState(() {});
    }
  }

  Future<void> weatherName({String? cityName}) async {
    final dio = Dio();
    final response = await dio.get(ApiConst.api);
    if (response.statusCode == 200 || response.statusCode == 201) {
      weatherModel = WeatherModel(
        id: response.data['weather'][0]['id'],
        main: response.data['weather'][0]['main'],
        description: response.data['weather'][0]['description'],
        icon: response.data['weather'][0]['icon'],
        temp: response.data['main']['temp'],
        country: response.data['sys']['country'],
        city: response.data['name'],
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    weatherName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: const Text(AppText.appBar, style: AppTextStyle.appBar),
      ),
      body: weatherModel == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/weather.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconButton(
                        onPressed: () async {
                          weatherLocation();
                        },
                        icon: Icons.near_me,
                      ),
                      CustomIconButton(
                        onPressed: () {
                          showBottomSheet();
                        },
                        icon: Icons.location_city,
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          '${temp(weatherModel!.temp)}',
                          style: const TextStyle(
                            fontSize: 96,
                            color: AppColors.white,
                          ),
                        ),
                        Image.network(ApiConst.getIcon(weatherModel!.icon, 4)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          weatherModel!.description.replaceAll(' ', '\n'),
                          style: const TextStyle(
                            fontSize: 60,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FittedBox(
                          child: Text(
                            weatherModel!.city!,
                            style: const TextStyle(
                              fontSize: 60,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  int temp(double? temp) {
    return (temp! - 273.15).toInt();
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white),
            color: AppColors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    setState(() {
                      weatherModel = null;
                    });
                    weatherName(cityName: city);
                    Navigator.pop(context);
                  },
                  title: Text(city),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
