import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:flutter_custom_calendar/widget/item_container.dart';
import 'package:flutter_custom_calendar/widget/month_view.dart';

class SelectedUtil {

  Map<String, List<ItemContainerState>> itemStates = new Map();

  void add(DateModel lastDateModel, DateModel dateModel, ItemContainerState state, {
    bool multiple = false
  }) {
    clear(lastDateModel);
    List<ItemContainerState> states = itemStates[dateModel.toString()];
    if (states == null) {
      states = new List();
      itemStates[dateModel.toString()] = states;
    } else if (states.contains(state)) {
      return;
    }
    states.add(state);
  }

  void clear(DateModel dateModel) {
    final states = itemStates[dateModel?.toString()];
    if (states != null) {
      states.forEach((state) => state.refreshItem(false));
    }
  }

  void set(DateModel dateModel, bool selected, {
    bool multiple = false
  }) {
    List<ItemContainerState> states = itemStates[dateModel.toString()];
    if (states != null) {
      states.forEach((state) => state.refreshItem(selected));
    }
  }

  void remove(DateModel dateModel, ItemContainerState state) {
    final states = itemStates[dateModel?.toString()];
    if (states != null) states.remove(state);
  }

  void clean() {
    itemStates.clear();
  }

}