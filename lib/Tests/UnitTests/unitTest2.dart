import 'package:test/test.dart';
import 'package:emergency_help/sharedFunctions.dart';

void main() {
  test('Check date format string', () {
    bool isLeapYear = false;

//    Date should be less than a minute
    DateTime date = DateTime.now();
    expect(formatDateOptions(date), "0 mins");

//    Date should be 1 minute
    date = date.subtract(Duration(minutes: 1));
    expect(formatDateOptions(date), "1 min");

//    Date should be 59 minutes
    date = date.subtract(Duration(minutes: 58));
    expect(formatDateOptions(date), "59 mins");

//    1 more minute should change the string to hours
    date = date.subtract(Duration(minutes: 1));
    expect(formatDateOptions(date), "1 hour");

//    Should be 23 hours
    date = date.subtract(Duration(hours: 22));
    expect(formatDateOptions(date), "23 hours");

//    Calculate yesterdays date
    List<String> months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    String yesterdayString =
        yesterday.day.toString() + " " + months[yesterday.month - 1];

//    1 more hour should switch to date view
    date = date.subtract(Duration(hours: 1));
    expect(formatDateOptions(date), yesterdayString);

//    Get last years date
    int lastYear = DateTime.now().year - 1;
    String lastYearString = yesterdayString + " " + lastYear.toString().substring(2);

//    Make date be from 1 year ago
    if (isLeapYear == false)
      date = date.subtract(Duration(days: 365));
    else
      date = date.subtract(Duration(days: 366));
    expect(formatDateOptions(date), lastYearString);
  });
}
