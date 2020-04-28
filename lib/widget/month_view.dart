import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/cache_data.dart';
import 'package:flutter_custom_calendar/calendar_provider.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/model/date_model.dart';
import 'package:flutter_custom_calendar/utils/LogUtil.dart';
import 'package:flutter_custom_calendar/utils/date_util.dart';
import 'package:flutter_custom_calendar/utils/selected_util.dart';
import 'package:provider/provider.dart';

import 'item_container.dart';

/**
 * 月视图，显示整个月的日子
 */
class MonthView extends StatefulWidget {
  final int year;
  final int month;
  final int day;

  final CalendarConfiguration configuration;

  const MonthView({
    Key key,
    @required this.year,
    @required this.month,
    this.day,
    this.configuration,
  }) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView>
    with AutomaticKeepAliveClientMixin {
  List<DateModel> items = List();

  int lineCount;
  Map<DateModel, Object> extraDataMap; //自定义额外的数据

  @override
  void initState() {
    super.initState();
    extraDataMap = widget.configuration.extraDataMap;
    DateModel firstDayOfMonth =
    DateModel.fromDateTime(DateTime(widget.year, widget.month, 1));
    if (widget.configuration.cacheData.monthListCache[firstDayOfMonth]?.isNotEmpty ==
        true) {
      LogUtil.log(TAG: this.runtimeType, message: "缓存中有数据");
      items = widget.configuration.cacheData.monthListCache[firstDayOfMonth];
    } else {
      LogUtil.log(TAG: this.runtimeType, message: "缓存中无数据");
      getItems().then((_) {
        widget.configuration.cacheData.monthListCache[firstDayOfMonth] = items;
      });
    }

    lineCount = DateUtil.getMonthViewLineCount(widget.year, widget.month, widget.configuration.offset);

    //第一帧后,添加监听，generation发生变化后，需要刷新整个日历
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Provider.of<CalendarProvider>(context, listen: false)
          .generation
          .addListener(() async {
        extraDataMap = widget.configuration.extraDataMap;
        if (widget.configuration.nowYear == widget.year
            && widget.configuration.nowMonth == widget.month) {
          await getItems();
        }
      });
    });
  }

  Future getItems() async {
    items = await compute(initCalendarForMonthView, {
      'year': widget.year,
      'month': widget.month,
      'minSelectDate': widget.configuration.minSelectDate,
      'maxSelectDate': widget.configuration.maxSelectDate,
      'extraDataMap': extraDataMap,
      'offset': widget.configuration.offset
    });
    setState(() {});
  }

  static Future<List<DateModel>> initCalendarForMonthView(Map map) async {
    return DateUtil.initCalendarForMonthView(
        map['year'], map['month'], DateTime.now(), DateTime.sunday,
        minSelectDate: map['minSelectDate'],
        maxSelectDate: map['maxSelectDate'],
        extraDataMap: map['extraDataMap'],
        offset: map['offset']);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LogUtil.log(TAG: this.runtimeType, message: "_MonthViewState build");

    CalendarProvider calendarProvider =
    Provider.of<CalendarProvider>(context, listen: false);
    CalendarConfiguration configuration =
        calendarProvider.calendarConfiguration;

    return new GridView.builder(
        addAutomaticKeepAlives: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, mainAxisSpacing: configuration.verticalSpacing),
        itemCount: items.isEmpty ? 0 : items.length,
        itemBuilder: (context, index) {
          DateModel dateModel = items[index];
          //判断是否被选择
          if (configuration.selectMode == CalendarConstants.MODE_MULTI_SELECT) {
            if (calendarProvider.selectedDateList.contains(dateModel)) {
              dateModel.isSelected = true;
            } else {
              dateModel.isSelected = false;
            }
          } else {
            if (calendarProvider.selectDateModel?.toString() == dateModel.toString()) {
              dateModel.isSelected = true;
            } else {
              dateModel.isSelected = false;
            }
          }

          return ItemContainer(
            dateModel: dateModel,
            key: ObjectKey(
                dateModel), //这里使用objectKey，保证可以刷新。原因1：跟flutter的刷新机制有关。原因2：statefulElement持有state。
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
