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
      Text(store?.string(forKey: "student_name") ?? signedOut).font(.headline).foregroundColor(.white)
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
  let date: Date

  var body: some View {
    let day = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"][Calendar.current.component(.weekday, from: date) - 1]
    let classes = store?.string(forKey: "classes_\(day)")
    VStack(alignment: .leading, spacing: 4) {
      BrandHeader()
      Text("Classes Today").font(.headline)
      Text(classes.map { $0.isEmpty ? "No classes today" : $0 } ?? signedOut).font(.caption)
    }
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
    StaticConfiguration(kind: "ClassesWidget", provider: Provider()) { ClassesView(date: $0.date) }
      .configurationDisplayName("Classes")
      .supportedFamilies([.systemMedium, .systemLarge])
  }
}

@main
struct CampusWidgets: WidgetBundle {
  var body: some Widget {
    StudentIdWidget()
    ClassesWidget()
  }
}
