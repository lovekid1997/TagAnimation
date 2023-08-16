# Tag Animation

<!-- [![Pub Package](https://img.shields.io/pub/v/table_calendar.svg?style=flat-square)](https://pub.dartlang.org/packages/table_calendar) -->
<!-- [![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-52bdeb.svg?longCache=true&style=flat-square)](https://github.com/Solido/awesome-flutter) -->

Convenient utility to animate Tag widget for Flutter.

| ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/table_calendar_styles.gif) |
## Features

* Extensive, yet easy to use API
* Preconfigured UI with customizable styling
* Custom selective builders for unlimited UI design
* Locale support
* Range selection support
* Multiple selection support
* Dynamic events and holidays
* Vertical autosizing - fit the content, or fill the viewport
* Multiple calendar formats (month, two weeks, week)
* Horizontal swipe boundaries (first day, last day)

## Usage

Make sure to check out [examples](https://github.com/aleksanderwozniak/table_calendar/tree/master/example/lib/pages) and [API docs](https://pub.dev/documentation/table_calendar/latest/) for more details.

### Installation

Add the following line to `pubspec.yaml`:

```yaml
dependencies:
  table_calendar: ^3.0.9
```

### Basic setup

*The complete example is available [here](https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/basics_example.dart).*

**TableCalendar** requires you to provide `firstDay`, `lastDay` and `focusedDay`:
* `firstDay` is the first available day for the calendar. Users will not be able to access days before it.
* `lastDay` is the last available day for the calendar. Users will not be able to access days after it.
* `focusedDay` is the currently targeted day. Use this property to determine which month should be currently visible.

```dart
TableCalendar(
  firstDay: DateTime.utc(2010, 10, 16),
  lastDay: DateTime.utc(2030, 3, 14),
  focusedDay: DateTime.now(),
);
```

#### Adding interactivity

You will surely notice that previously set up calendar widget isn't quite interactive - you can only swipe it horizontally, to change the currently visible month. While it may be sufficient in certain situations, you can easily bring it to life by specifying a couple of callbacks.

Adding the following code to the calendar widget will allow it to respond to user's taps, marking the tapped day as selected:

```dart
selectedDayPredicate: (day) {
  return isSameDay(_selectedDay, day);
},
onDaySelected: (selectedDay, focusedDay) {
  setState(() {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay; // update `_focusedDay` here as well
  });
},
```

In order to dynamically update visible calendar format, add those lines to the widget:

```dart
calendarFormat: _calendarFormat,
onFormatChanged: (format) {
  setState(() {
    _calendarFormat = format;
  });
},
```

Those two changes will make the calendar interactive and responsive to user's input.

#### Updating focusedDay

Setting `focusedDay` to a static value means that whenever **TableCalendar** widget rebuilds, it will use that specific `focusedDay`. You can quickly test it by using hot reload: set `focusedDay` to `DateTime.now()`, swipe to next month and trigger a hot reload - the calendar will "reset" to its initial state. To prevent this from happening, you should store and update `focusedDay` whenever any callback exposes it.

Add this one callback to complete the basic setup:

```dart
onPageChanged: (focusedDay) {
  _focusedDay = focusedDay;
},
```

It is worth noting that you don't need to call `setState()` inside `onPageChanged()` callback. You should just update the stored value, so that if the widget gets rebuilt later on, it will use the proper `focusedDay`.

*The complete example is available [here](https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/basics_example.dart). You can find other examples [here](https://github.com/aleksanderwozniak/table_calendar/tree/master/example/lib/pages).*

### Events

*The complete example is available [here](https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/events_example.dart).*

You can supply custom events to **TableCalendar** widget. To do so, use `eventLoader` property - you will be given a `DateTime` object, to which you need to assign a list of events.

```dart
eventLoader: (day) {
  return _getEventsForDay(day);
},
```

`_getEventsForDay()` can be of any implementation. For example, a `Map<DateTime, List<T>>` can be used:

```dart
List<Event> _getEventsForDay(DateTime day) {
  return events[day] ?? [];
}
```

One thing worth remembering is that `DateTime` objects consist of both date and time parts. In many cases this time part is redundant for calendar related aspects. 

If you decide to use a `Map`, I suggest making it a `LinkedHashMap` - this will allow you to override equality comparison for two `DateTime` objects, comparing them just by their date parts:

```dart
final events = LinkedHashMap(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(eventSource);
```

#### Cyclic events

`eventLoader` allows you to easily add events that repeat in a pattern. For example, this will add an event to every Monday:

```dart
eventLoader: (day) {
  if (day.weekday == DateTime.monday) {
    return [Event('Cyclic event')];
  }

  return [];
},
```

#### Events selected on tap

Often times having a sublist of events that are selected by tapping on a day is desired. You can achieve that by using the same method you provided to `eventLoader` inside of `onDaySelected` callback:

```dart
void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  if (!isSameDay(_selectedDay, selectedDay)) {
    setState(() {
      _focusedDay = focusedDay;
      _selectedDay = selectedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  }
}