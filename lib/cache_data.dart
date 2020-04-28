import 'package:flutter_custom_calendar/model/date_model.dart';

/**
 * 保存一些缓存数据，不用再次去计算日子
 */
class CacheData {

  //私有构造函数
  CacheData._();

  Map<DateModel, List<DateModel>> monthListCache = Map();
  Map<DateModel, List<DateModel>> weekListCache = Map();

  static CacheData getInstance() {
    return new CacheData._();
  }

  void clearData(){
    monthListCache.clear();
    weekListCache.clear();
  }


}



