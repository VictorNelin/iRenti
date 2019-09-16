import 'dart:async' show Future, StreamController;
import 'dart:io' show File, HttpClient, HttpClientRequest, HttpClientResponse, HttpStatus;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef void ErrorListener();

class CachedNetworkImageProvider extends ImageProvider<CachedNetworkImageProvider> {
  CachedNetworkImageProvider(
    this.url, {
    this.scale: 1.0,
    this.errorListener,
    this.headers,
  })  : assert(url != null),
        assert(scale != null);

  final String url;
  final double scale;
  final ErrorListener errorListener;
  final Map<String, String> headers;

  @override
  Future<CachedNetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(CachedNetworkImageProvider key) {
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents),
      scale: key.scale,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<CachedNetworkImageProvider>('Image key', key);
      },
    );
  }

  static final HttpClient _sharedHttpClient = HttpClient()..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) client = debugNetworkImageHttpClientProvider();
      return true;
    }());
    return client;
  }

  Future<File> getSingleFile(
    String url, {
    Map<String, String> headers,
    StreamController<ImageChunkEvent> chunkEvents,
  }) async {
    try {
      String filename = url.split('/').last;
      if (filename.contains('?')) {
        filename = filename.substring(0, filename.indexOf('?'));
      }
      if (filename.contains('&')) {
        filename = filename.substring(0, filename.indexOf('&'));
      }
      File cached = File(p.join((await getTemporaryDirectory()).path, filename));
      if (await cached.exists() && DateTime.now().difference(await cached.lastModified()).abs().inDays < 7) {
        int length = await cached.length();
        chunkEvents?.add(ImageChunkEvent(
          cumulativeBytesLoaded: length,
          expectedTotalBytes: length,
        ));
        return cached;
      }
      final Uri resolved = Uri.base.resolve(url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw Exception('HTTP request failed, statusCode: ${response?.statusCode}, $resolved');
      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int total) {
          chunkEvents?.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0) throw Exception('NetworkImage is an empty file: $resolved');
      await cached.writeAsBytes(bytes, flush: true);
      await cached.setLastModified(DateTime.now());
      return cached;
    } finally {
      chunkEvents?.close();
    }
  }

  Future<ui.Codec> _loadAsync(
    CachedNetworkImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    var file = await getSingleFile(url, headers: headers, chunkEvents: chunkEvents);
    if (file == null) {
      if (errorListener != null) errorListener();
      return Future<ui.Codec>.error("Couldn't download or retrieve file.");
    }
    return await _loadAsyncFromFile(key, file);
  }

  Future<ui.Codec> _loadAsyncFromFile(CachedNetworkImageProvider key, File file) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      if (errorListener != null) errorListener();
      throw Exception("File was empty");
    }

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final CachedNetworkImageProvider typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}

/*enum _TransitionStatus {
  start,
  loading,
  animating,
  completed,
  failed,
}

class CachedNetworkImage extends StatefulWidget {
  CachedNetworkImage({
    Key key,
    @required String url,
    Map<String, String> headers,
    this.width,
    this.height,
    this.color,
    this.blendMode,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.filterQuality = FilterQuality.low,
    this.loadingBuilder,
    this.errorBuilder,
    this.frameBuilder,
  }) :  assert(url != null),
        image = CachedNetworkImageProvider(url, headers: headers),
        super(key: key);

  CachedNetworkImage.custom({
    Key key,
    @required this.image,
    this.width,
    this.height,
    this.color,
    this.blendMode,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.filterQuality = FilterQuality.low,
    this.loadingBuilder,
    this.errorBuilder,
    this.frameBuilder,
  }) :  assert(image != null),
        super(key: key);

  final ImageProvider image;
  final double width;
  final double height;
  final Color color;
  final BlendMode blendMode;
  final BoxFit fit;
  final Alignment alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final FilterQuality filterQuality;
  final LoadingWidgetBuilder loadingBuilder;
  final ErrorWidgetBuilder errorBuilder;
  final ImageFrameBuilder frameBuilder;

  @override
  _CachedNetworkImageState createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  _TransitionStatus _status;
  double _progress = 0;

  ImageProvider get _imageProvider => widget.image;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kThemeChangeDuration,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    _getImage();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(CachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image)
      _getImage();
  }

  @override
  void reassemble() {
    _getImage();
    super.reassemble();
  }

  @override
  void dispose() {
    _imageStream.removeListener(ImageStreamListener(_updateImage));
    _controller.dispose();
    super.dispose();
  }

  void _resolveStatus() {
    if (!mounted) return;
    setState(() {
      switch (_status) {
        case _TransitionStatus.start:
          if (_imageInfo == null) {
            _status = _TransitionStatus.loading;
          } else {
            _status = _TransitionStatus.completed;
            _controller.forward(from: 1.0);
          }
          break;
        case _TransitionStatus.loading:
          if (_imageInfo != null) {
            _status = _TransitionStatus.animating;
            _controller.forward(from: 0.0);
          }
          break;
        case _TransitionStatus.animating:
          if (_controller.status == AnimationStatus.completed)
            _status = _TransitionStatus.completed;
          break;
        case _TransitionStatus.completed:
        case _TransitionStatus.failed:
          break;
      }
    });
  }

  void _getImage({bool reload: false}) {
    if (reload) {
      _imageProvider.evict();
    }
    final ImageStream oldImageStream = _imageStream;
    if (_imageProvider is CachedNetworkImageProvider && widget.loadingBuilder != null) {
      var callback = (_imageProvider as CachedNetworkImageProvider).loadingProgress;
      (_imageProvider as CachedNetworkImageProvider).loadingProgress =
          (double progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        } else {
          return oldImageStream?.removeListener(ImageStreamListener(_updateImage));
        }

        if (callback != null) callback(progress);
      };
    }
    _imageStream = _imageProvider.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null
          ? Size(widget.width, widget.height)
          : null,
    ));
    if (_imageInfo != null && !reload && (_imageStream.key == oldImageStream?.key)) {
      *//*if (widget.forceRebuildWidget) {
        if (widget.loadedCallback != null)
          widget.loadedCallback();
        else if (widget.loadFailedCallback != null) widget.loadFailedCallback();
      }*//*
      setState(() => _status = _TransitionStatus.completed);
    } else {
      setState(() => _status = _TransitionStatus.start);
      oldImageStream?.removeListener(ImageStreamListener(_updateImage));
      _imageStream.addListener(
        ImageStreamListener(_updateImage, onError: _catchBadImage),
      );
      _resolveStatus();
    }
  }

  void _updateImage(ImageInfo info, bool synchronousCall) {
    _imageInfo = info;
    if (_imageInfo != null) {
      _resolveStatus();
    }
  }

  void _catchBadImage(dynamic exception, StackTrace stackTrace) {
    debugPrint(exception.toString());
    if (mounted) setState(() => _status = _TransitionStatus.failed);
    _resolveStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == _TransitionStatus.failed) {
      return GestureDetector(
        onTap: () => _getImage(reload: true),
        child: widget.errorBuilder != null ? widget.errorBuilder(context) : SizedBox(
          width: widget.width,
          height: widget.height,
        ),
      );
    }
    if (_status == _TransitionStatus.start || _status == _TransitionStatus.loading) {
      return widget.loadingBuilder != null
          ? widget.loadingBuilder(context, _progress)
          : SizedBox(
        width: widget.width,
        height: widget.height,
      );
    }
    Widget result = FadeTransition(
      opacity: _controller,
      child: RawImage(
        image: _imageInfo?.image,
        width: widget.width,
        height: widget.height,
        scale: _imageInfo?.scale ?? 1,
        color: widget.color,
        colorBlendMode: widget.blendMode,
        fit: widget.fit,
        alignment: widget.alignment,
        repeat: widget.repeat,
        matchTextDirection: widget.matchTextDirection,
        filterQuality: widget.filterQuality,
      ),
    );
    if (widget.frameBuilder != null)
      result = widget.frameBuilder(context, result, _frameNumber, _wasSynchronouslyLoaded);
  }
}*/
