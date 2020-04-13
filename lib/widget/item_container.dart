import 'package:flutter/widgets.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/model/date_model.dart';
import 'package:flutter_custom_calendar/utils/LogUtil.dart';
import 'package:provider/provider.dart';

import '../calendar_provider.dart';
import '../configuration.dart';

class ItemContainer extends StatefulWidget {
  final DateModel dateModel;

  const ItemContainer({
    Key key,
    this.dateModel,
  }) : super(key: key);

  @override
  ItemContainerState createState() => ItemContainerState();
}

class ItemContainerState extends State<ItemContainer> {
  DateModel dateModel;
  CalendarConfiguration configuration;
  CalendarProvider calendarProvider;

  ValueNotifier<bool> isSelected;

  @override
  void initState() {
    super.initState();
    dateModel = widget.dateModel;
    isSelected = ValueNotifier(dateModel.isSelected);

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      calendarProvider?.selectedUtil?.add(null, dateModel, this);
    });
  }

  /**
   * 提供方法给外部，可以调用这个方法进行刷新item
   */
  void refreshItem(bool v) {
    /**
        Exception caught by gesture
        The following assertion was thrown while handling a gesture:
        setState() called after dispose()
     */
    if (mounted) {
      setState(() {
        dateModel.isSelected = v;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    configuration = calendarProvider.calendarConfiguration;

    return GestureDetector(
      //点击整个item都会触发事件
      behavior: HitTestBehavior.opaque,
      onTap: () {
        LogUtil.log(
            TAG: this.runtimeType,
            message: "GestureDetector onTap: $dateModel}");

        //范围外不可点击
        if (!dateModel.isInRange) {
          //多选回调
          if (configuration.selectMode == CalendarConstants.MODE_MULTI_SELECT) {
            configuration.multiSelectOutOfRange();
          }
          return;
        }

        calendarProvider.lastClickDateModel = dateModel;

        if (configuration.selectMode == CalendarConstants.MODE_MULTI_SELECT) {
          if (calendarProvider.selectedDateList.contains(dateModel)) {
            calendarProvider.selectedDateList.remove(dateModel);
          } else {
            //多选，判断是否超过限制，超过范围
            if (calendarProvider.selectedDateList.length ==
                configuration.maxMultiSelectCount) {
              if (configuration.multiSelectOutOfSize != null) {
                configuration.multiSelectOutOfSize();
              }
              return;
            }
            calendarProvider.selectedDateList.add(dateModel);
          }
          if (configuration.calendarSelect != null) {
            configuration.calendarSelect(dateModel);
          }
          //多选也可以弄这些单选的代码
          calendarProvider.selectDateModel = dateModel;
          calendarProvider?.selectedUtil?.set(dateModel, !this.dateModel.isSelected);
        } else {
          calendarProvider.selectDateModel = dateModel;
          if (configuration.calendarSelect != null) {
            configuration.calendarSelect(dateModel);
          }
          if (!dateModel.isSelected) {
            calendarProvider?.selectedUtil?.add(calendarProvider?.lastClickItemState?.dateModel, dateModel, this);
            calendarProvider.lastClickItemState = this;
            calendarProvider?.selectedUtil?.set(dateModel, true);
          } else {
            // TODO 如果单选取消选中周月视图切换存在问题，还未能解决 所以禁止取消选中
          }
        }
      },
      child: configuration.dayWidgetBuilder(dateModel),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(ItemContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}