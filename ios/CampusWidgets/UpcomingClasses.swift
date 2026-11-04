import Foundation

private let classDays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
private let campusTimeZone = TimeZone(identifier: "America/Los_Angeles")!

struct WidgetClass: Decodable {
  let title: String
  let location: String
  let startMinutes: Int?
}

struct UpcomingClass {
  let title: String
  let location: String
  let start: Date
}

func campusCalendar() -> Calendar {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = campusTimeZone
  return calendar
}

func classSchedule(from store: UserDefaults?) -> [String: [WidgetClass]]? {
  var schedule: [String: [WidgetClass]] = [:]
  for day in classDays {
    guard let value = store?.string(forKey: "classes_\(day)") else { continue }
    // Existing installations have plain text until the app next syncs the schedule.
    guard let data = value.data(using: .utf8), let classes = try? JSONDecoder().decode([WidgetClass].self, from: data) else {
      return nil
    }
    schedule[day] = classes
  }
  return schedule.isEmpty ? nil : schedule
}

func upcomingClasses(in schedule: [String: [WidgetClass]], at now: Date) -> [UpcomingClass] {
  let calendar = campusCalendar()
  var upcoming: [UpcomingClass] = []
  // Two weeks covers the next two occurrences of a once-a-week class.
  for offset in 0...14 {
    let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now))!
    let code = classDays[calendar.component(.weekday, from: day) - 1]
    for meeting in schedule[code] ?? [] {
      guard let minutes = meeting.startMinutes, (0..<1440).contains(minutes),
        let start = calendar.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: day), start > now else { continue }
      upcoming.append(UpcomingClass(title: meeting.title, location: meeting.location, start: start))
    }
  }
  return Array(upcoming.sorted { $0.start < $1.start }.prefix(2))
}

func classDetails(_ upcoming: UpcomingClass, at now: Date) -> String {
  let formatter = DateFormatter()
  formatter.timeZone = campusTimeZone
  formatter.dateFormat = campusCalendar().isDate(upcoming.start, inSameDayAs: now) ? "h:mm a" : "EEE h:mm a"
  let location = upcoming.location.isEmpty ? "Location TBA" : upcoming.location
  return "\(location) · \(formatter.string(from: upcoming.start))"
}
