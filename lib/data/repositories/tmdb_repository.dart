import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:netflox/data/models/tmdb/element.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/data/models/tmdb/people.dart';
import 'package:netflox/data/models/tmdb/season.dart';
import 'package:netflox/data/models/tmdb/tv.dart';
import 'package:netflox/data/models/tmdb/video.dart';
import 'package:netflox/data/models/tmdb/error.dart';
import 'package:netflox/data/repositories/tmdb_result.dart';
import 'package:universal_io/io.dart';
import '../models/server_configs/tmdb_config.dart';
import '../models/tmdb/filter_parameter.dart';
import '../models/tmdb/media.dart';
import '../models/tmdb/type.dart';

part 'tmdb_query.dart';

class TMDBRepository {
  final TMDBApiConfig _tmdbApiConfig;
  const TMDBRepository(TMDBApiConfig config) : _tmdbApiConfig = config;

  BasicTMDBQuery<TMDBMovie> movie() {
    return BasicTMDBQuery<TMDBMovie>._(_tmdbApiConfig);
  }

  BasicTMDBQuery<TMDBTv> tv() {
    return BasicTMDBQuery<TMDBTv>._(_tmdbApiConfig);
  }

  BasicTMDBQuery<TMDBPerson> people() {
    return BasicTMDBQuery<TMDBPerson>._(_tmdbApiConfig);
  }

  BasicTMDBQuery<T> primaryMedia<T extends TMDBPrimaryMedia>(TMDBType<T> type) {
    return BasicTMDBQuery<T>._(_tmdbApiConfig, type);
  }

  BasicTMDBQuery<T> media<T extends TMDBMedia>(TMDBType<T> type) {
    return BasicTMDBQuery<T>._(_tmdbApiConfig, type);
  }

  BasicTMDBQuery<T> multimedia<T extends TMDBMultiMedia>(TMDBType<T> type) {
    return BasicTMDBQuery<T>._(_tmdbApiConfig, type);
  }

  TMDBSearchQuery<T> search<T extends TMDBPrimaryMedia>([TMDBType<T>? type]) {
    return TMDBSearchQuery<T>._(_tmdbApiConfig, type);
  }

  TrendingTMDBQuery<T> trending<T extends TMDBPrimaryMedia>(TMDBType<T> type) {
    return TrendingTMDBQuery<T>._(_tmdbApiConfig, type);
  }

  TMDBDiscoverQuery<T> discover<T extends TMDBMultiMedia>(TMDBType<T> type) {
    assert(type != TMDBMultiMediaType.any);
    return TMDBDiscoverQuery<T>._(_tmdbApiConfig, type);
  }

  BasicTMDBQuery<T> get<T extends TMDBElement>(TMDBType<T> type) {
    return BasicTMDBQuery<T>._(_tmdbApiConfig, type);
  }
}
