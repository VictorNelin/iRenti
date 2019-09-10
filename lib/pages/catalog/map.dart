import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart' hide MapState;
import 'package:latlong/latlong.dart' show LatLng, radianToDeg;
import 'package:irenti/bloc/map_bloc.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/repository/catalog_repository.dart';

class MapPage extends StatefulWidget {
  final CatalogEntry entry;

  const MapPage({Key key, this.entry}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ValueNotifier<bool> _loadNearby = ValueNotifier(false);
  final MapController _controller = MapController();
  MapBloc _bloc;
  LatLngBounds _bounds;

  @override
  void initState() {
    super.initState();
    _bloc = MapBloc(catalogRepository: RepositoryProvider.of<CatalogRepository>(context));
    /*_controller.onReady.then((_) {
      final bounds = _controller.bounds;
      _bloc.dispatch(MapLoadEvent(bounds.north, bounds.west, bounds.south, bounds.east));
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: SafeArea(
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(width: 16.0, height: kToolbarHeight),
                      const Icon(Icons.arrow_back_ios, size: 16.0),
                      const SizedBox(width: 16.0),
                      Align(child: Text(
                        'Назад',
                        style: Theme.of(context).textTheme.subhead.copyWith(
                          fontSize: 14.0,
                        ),
                      )),
                      const SizedBox(width: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<MapBloc, MapState>(
            bloc: _bloc,
            builder: (context, state) {
              return Listener(
                behavior: HitTestBehavior.translucent,
                onPointerUp: (e) {
                  if (_bounds != null) {
                    final bounds = _bounds;
                    _bounds = null;
                    Future.delayed(const Duration(milliseconds: 650), () {
                      _bloc.dispatch(MapLoadEvent(bounds.north, bounds.west, bounds.south, bounds.east));
                    });
                  }
                },
                child: FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    crs: const Epsg3395(),
                    center: LatLng(widget.entry.location[0], widget.entry.location[1]),
                    interactive: !state.loading,
                    onPositionChanged: (pos, b) {
                      if (b) _bounds = pos.bounds;
                    },
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: 'http://vec{s}.maps.yandex.net/tiles?l=map&v=2.2.3&x={x}&y={y}&z={z}',
                      subdomains: ['01', '02', '03', '04'],
                    ),
                    MarkerLayerOptions(
                      markers: [
                        for (var entry in state.entries)
                          if (entry.id != widget.entry.id)
                            Marker(
                              point: LatLng(entry.location[0], entry.location[1]),
                              anchorPos: AnchorPos.align(AnchorAlign.top),
                              width: 48,
                              height: 48,
                              builder: (ctx) => GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => Navigator.pushNamed(context, '/catalog/single', arguments: entry),
                                child: const Icon(
                                  CupertinoIcons.location_solid,
                                  size: 48,
                                  color: Color(0xff272d30),
                                ),
                              ),
                            ),
                        Marker(
                          point: LatLng(widget.entry.location[0], widget.entry.location[1]),
                          anchorPos: AnchorPos.align(AnchorAlign.top),
                          width: 48,
                          height: 48,
                          builder: (ctx) => const Icon(
                            CupertinoIcons.location_solid,
                            size: 48,
                            color: Color(0xffef5353),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          ),
        ),
        Material(
          child: Container(
            height: 60,
            child: InkWell(
              onTap: () {},
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 16),
                  const Expanded(child: Text('Показывать объекты рядом',)),
                  const SizedBox(width: 16),
                  ValueListenableBuilder(
                    valueListenable: _loadNearby,
                    builder: (context, data, _) {
                      return CupertinoSwitch(
                        value: data,
                        onChanged: (b) {
                          _loadNearby.value = b;
                          if (b) {
                            final bounds = _controller.bounds;
                            _bloc.dispatch(MapLoadEvent(bounds.north, bounds.west, bounds.south, bounds.east));
                          } else {
                            _bloc.dispatch(MapResetEvent());
                          }
                        },
                      );
                    }
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Epsg3395 extends Earth {
  @override
  final String code = 'EPSG:3395';

  @override
  final Projection projection;

  @override
  final Transformation transformation;

  static const num  _scale = 0.5 / (math.pi * Mercator.R_MAJOR);

  const Epsg3395()
      : projection = const Mercator(),
        transformation = const Transformation(_scale, 0.5, -_scale, 0.5),
        super();
}

class Mercator extends Projection {
  static const double MAX_LATITUDE = 85.0840591556;

  static const double R_MINOR = 6356752.314245179;
  static const double R_MAJOR = 6378137.0;

  static final Bounds<double> _bounds = Bounds<double>(
    CustomPoint<double>(-R_MAJOR * math.pi, -R_MAJOR * math.pi),
    CustomPoint<double>(R_MAJOR * math.pi, R_MAJOR * math.pi),
  );

  const Mercator() : super();

  @override
  Bounds<double> get bounds => _bounds;

  @override
  CustomPoint project(LatLng latlng) {
    final max = MAX_LATITUDE,
        lat = math.max(math.min(max, latlng.latitudeInRad), -max),
        r = R_MAJOR,
        r2 = R_MINOR,
        x = latlng.longitudeInRad * r,
        tmp = r2 / r,
        eccent = math.sqrt(1.0 - tmp * tmp);
    double y = lat;
    double con = eccent * math.sin(y);

    con = math.pow((1 - con) / (1 + con), eccent * 0.5);

    final ts = math.tan(0.5 * ((math.pi * 0.5) - y)) / con;
    y = -r * math.log(ts);

    return CustomPoint(x, y);
  }

  @override
  LatLng unproject(CustomPoint point) {
    final r = R_MAJOR,
        r2 = R_MINOR,
        lng = radianToDeg(point.x) / r,
        tmp = r2 / r,
        eccent = math.sqrt(1 - (tmp * tmp)),
        ts = math.exp(- point.y / r),
        numIter = 15,
        tol = 1e-7;
    int i = numIter;
    double dphi = 0.1;
    double phi = (math.pi / 2) - 2 * math.atan(ts);

    while ((dphi.abs() > tol) && (--i > 0)) {
      final con = eccent * math.sin(phi);
      dphi = (math.pi / 2) - 2 * math.atan(ts *
          math.pow((1.0 - con) / (1.0 + con), 0.5 * eccent)) - phi;
      phi += dphi;
    }

    return LatLng(radianToDeg(phi), lng);
  }
}
