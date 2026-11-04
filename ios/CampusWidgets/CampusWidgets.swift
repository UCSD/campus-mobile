import SwiftUI
import WidgetKit

// Data is written by lib/core/services/home_widget.dart
private let store = UserDefaults(suiteName: "group.edu.ucsd.ucsandiego")
private let signedOut = "Sign in to the UC San Diego app"
private let navy = Color(red: 0x18 / 255, green: 0x2B / 255, blue: 0x49 / 255)  // lightPrimaryColor in lib/app_styles.dart

struct Entry: TimelineEntry { let date: Date }

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> Entry { Entry(date: .now) }
  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) { completion(Entry(date: .now)) }
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    // The app pushes reloads on new data; the midnight entry flips Classes to the new weekday.
    let midnight = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: .now))!
    completion(Timeline(entries: [Entry(date: .now), Entry(date: midnight)], policy: .atEnd))
  }
}

struct ClassesProvider: TimelineProvider {
  func placeholder(in context: Context) -> Entry { Entry(date: .now) }
  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) { completion(Entry(date: .now)) }
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let now = Date.now
    let classes = upcomingClasses(in: classSchedule(from: store) ?? [:], at: now)
    let starts = Set(classes.map { $0.start }).sorted()
    let entries = [Entry(date: now)] + starts.map { Entry(date: $0) }
    let calendar = campusCalendar()
    let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
    completion(Timeline(entries: entries, policy: starts.isEmpty ? .after(midnight) : .atEnd))
  }
}

/// UC San Diego wordmark top left, Triton trident top right.
struct BrandHeader: View {
  var body: some View {
    HStack {
      Image("UCSDLogo").resizable().scaledToFit().frame(height: 16).accessibilityLabel("UC San Diego")
      Spacer()
      Image("TritonLogo").resizable().scaledToFit().frame(height: 24).accessibilityHidden(true)
    }
  }
}

struct StudentIdView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      BrandHeader()
      Text(store?.string(forKey: "student_name") ?? signedOut).font(.headline).foregroundColor(.white).privacySensitive()
      if let path = store?.string(forKey: "student_barcode"), let barcode = UIImage(contentsOfFile: path) {
        Image(uiImage: barcode).resizable().interpolation(.none)
          .padding(.horizontal, 10).padding(.vertical, 4)  // white quiet zone so scanners can read it
          .background(Color.white, in: RoundedRectangle(cornerRadius: 6))
          .privacySensitive()  // redacted while the device is locked
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetBackground()
  }
}

struct ClassesView: View {
  @Environment(\.widgetFamily) private var family
  let date: Date

  var body: some View {
    let isSmall = family == .systemSmall
    let schedule = classSchedule(from: store)
    let classes = upcomingClasses(in: schedule ?? [:], at: date)
    let secondary = Color(red: 0xB6 / 255, green: 0xC1 / 255, blue: 0xD2 / 255)
    let hasIdentity = store?.string(forKey: "student_name") != nil || store?.string(forKey: "student_barcode") != nil
    VStack(alignment: .leading, spacing: isSmall ? 4 : 6) {
      BrandHeader()
      if let next = classes.first {
        VStack(alignment: .leading, spacing: 2) {
          HStack(alignment: .firstTextBaseline) {
            Text(next.title).font(.system(size: isSmall ? 16 : 20, weight: .bold))
            if !isSmall {
              Spacer()
              Text("NEXT").font(.caption2).foregroundColor(secondary)
            }
          }
          Text(isSmall ? (next.location.isEmpty ? "Location TBA" : next.location) : classDetails(next, at: date))
            .font(isSmall ? .caption2 : .caption)
          HStack(spacing: 4) {
            Text("Starts in")
            Text(next.start, style: .relative).monospacedDigit()
          }.font((isSmall ? Font.caption2 : .caption).weight(.semibold))
        }.privacySensitive()
        if classes.count > 1 {
          let following = classes[1]
          VStack(alignment: .leading, spacing: 2) {
            Text(following.title).font(.system(size: 13, weight: .semibold))
            Text(classDetails(following, at: date)).font(.caption2).lineLimit(isSmall ? 2 : 1)
          }
          .foregroundColor(secondary)
          .privacySensitive()
        }
      } else if let schedule {
        let hasClasses = schedule.values.contains { !$0.isEmpty }
        Text(hasClasses ? "Class times unavailable" : "No upcoming classes").font(.caption).lineLimit(2)
      } else {
        Text(hasIdentity ? "Open the app to load your classes" : signedOut).font(.caption).lineLimit(2)
      }
    }
    .lineLimit(1)
    .minimumScaleFactor(isSmall ? 0.8 : 1)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetBackground()
  }
}

extension View {
  // iOS 17+ shows an error placeholder unless containerBackground is set.
  @ViewBuilder func widgetBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(navy, for: .widget)
    } else {
      padding().background(navy)
    }
  }
}

struct StudentIdWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "StudentIdWidget", provider: Provider()) { _ in StudentIdView() }
      .configurationDisplayName("Student ID")
      .supportedFamilies([.systemMedium])
  }
}

struct ClassesWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ClassesWidget", provider: ClassesProvider()) { ClassesView(date: $0.date) }
      .configurationDisplayName("Classes")
      .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

@main
struct CampusWidgets: WidgetBundle {
  var body: some Widget {
    StudentIdWidget()
    ClassesWidget()
  }
}
