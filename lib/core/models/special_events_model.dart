// To parse this JSON data, do
//
//     final specialEventsModel = specialEventsModelFromJson(jsonString);

import 'dart:convert';

SpecialEventsModel specialEventsModelFromJson(String str) => SpecialEventsModel.fromJson(json.decode(str));

String specialEventsModelToJson(SpecialEventsModel data) => json.encode(data.toJson());

class SpecialEventsModel {
    String name;
    String location;
    int startTime;
    int endTime;
    String logo;
    String logoSm;
    String map;
    List<String> uids;
    Map<String, Schedule> schedule;
    List<DateTime> dates;
    Map<String, List<String>> dateItems;
    List<String> labels;
    Map<String, List<String>> labelItems;
    String labelThemes;

    SpecialEventsModel({
        this.name,
        this.location,
        this.startTime,
        this.endTime,
        this.logo,
        this.logoSm,
        this.map,
        this.uids,
        this.schedule,
        this.dates,
        this.dateItems,
        this.labels,
        this.labelItems,
        this.labelThemes,
    });

    factory SpecialEventsModel.fromJson(Map<String, dynamic> json) => SpecialEventsModel(
        name: json["name"] == null ? null : json["name"],
        location: json["location"] == null ? null : json["location"],
        startTime: json["start-time"] == null ? null : json["start-time"],
        endTime: json["end-time"] == null ? null : json["end-time"],
        logo: json["logo"] == null ? null : json["logo"],
        logoSm: json["logo-sm"] == null ? null : json["logo-sm"],
        map: json["map"] == null ? null : json["map"],
        uids: json["uids"] == null ? null : List<String>.from(json["uids"].map((x) => x)),
        schedule: json["schedule"] == null ? null : Map.from(json["schedule"]).map((k, v) => MapEntry<String, Schedule>(k, Schedule.fromJson(v))),
        dates: json["dates"] == null ? null : List<DateTime>.from(json["dates"].map((x) => DateTime.parse(x))),
        dateItems: json["date-items"] == null ? null : Map.from(json["date-items"]).map((k, v) => MapEntry<String, List<String>>(k, List<String>.from(v.map((x) => x)))),
        labels: json["labels"] == null ? null : List<String>.from(json["labels"].map((x) => x)),
        labelItems: json["label-items"] == null ? null : Map.from(json["label-items"]).map((k, v) => MapEntry<String, List<String>>(k, List<String>.from(v.map((x) => x)))),
        labelThemes: json["label-themes"] == null ? null :json["label-themes"],
    );

    Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "location": location == null ? null : location,
        "start-time": startTime == null ? null : startTime,
        "end-time": endTime == null ? null : endTime,
        "logo": logo == null ? null : logo,
        "logo-sm": logoSm == null ? null : logoSm,
        "map": map == null ? null : map,
        "uids": uids == null ? null : List<dynamic>.from(uids.map((x) => x)),
        "schedule": schedule == null ? null : Map.from(schedule).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "dates": dates == null ? null : List<dynamic>.from(dates.map((x) => "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
        "date-items": dateItems == null ? null : Map.from(dateItems).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
        "labels": labels == null ? null : List<dynamic>.from(labels.map((x) => x)),
        "label-items": labelItems == null ? null : Map.from(labelItems).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
        "label-themes": labelThemes == null ? null : labelThemes,
    };
}

class LabelThemes {
    String muirArtsCultureFun;
    String rooseveltCommunityInvolvement;
    String muirCommunityInvolvement;
    String rooseveltArtsCultureFun;
    String sixthArtsCultureFun;
    String artsCultureFun;
    String sixthCommunityInvolvement;
    String communityInvolvement;

    LabelThemes({
        this.muirArtsCultureFun,
        this.rooseveltCommunityInvolvement,
        this.muirCommunityInvolvement,
        this.rooseveltArtsCultureFun,
        this.sixthArtsCultureFun,
        this.artsCultureFun,
        this.sixthCommunityInvolvement,
        this.communityInvolvement,
    });

    factory LabelThemes.fromJson(Map<String, dynamic> json) => LabelThemes(
        muirArtsCultureFun: json["Muir,Arts, Culture & Fun!"] == null ? null : json["Muir,Arts, Culture & Fun!"],
        rooseveltCommunityInvolvement: json["Roosevelt, Community Involvement"] == null ? null : json["Roosevelt, Community Involvement"],
        muirCommunityInvolvement: json["Muir,Community Involvement"] == null ? null : json["Muir,Community Involvement"],
        rooseveltArtsCultureFun: json["Roosevelt, Arts, Culture & Fun!"] == null ? null : json["Roosevelt, Arts, Culture & Fun!"],
        sixthArtsCultureFun: json["Sixth,Arts, Culture & Fun!"] == null ? null : json["Sixth,Arts, Culture & Fun!"],
        artsCultureFun: json["Arts, Culture & Fun!"] == null ? null : json["Arts, Culture & Fun!"],
        sixthCommunityInvolvement: json["Sixth,Community Involvement"] == null ? null : json["Sixth,Community Involvement"],
        communityInvolvement: json["Community Involvement"] == null ? null : json["Community Involvement"],
    );
}

class Schedule {
    String id;
    int startTime;
    int endTime;
    String talkType;
    String topLabel;
    String label;
    String labelTheme;
    String location;
    String talkTitle;
    String speakerShortdesc;
    String fullDescription;
    String directions;
    String imagethumb;
    String imagehq;
    String contactInfo;
    String contactPhone;
    String url;

    Schedule({
        this.id,
        this.startTime,
        this.endTime,
        this.talkType,
        this.topLabel,
        this.label,
        this.labelTheme,
        this.location,
        this.talkTitle,
        this.speakerShortdesc,
        this.fullDescription,
        this.directions,
        this.imagethumb,
        this.imagehq,
        this.contactInfo,
        this.contactPhone,
        this.url,
    });

    factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json["id"] == null ? null : json["id"],
        startTime: json["start-time"] == null ? null : json["start-time"],
        endTime: json["end-time"] == null ? null : json["end-time"],
        talkType: json["talk-type"] == null ? null : json["talk-type"],
        topLabel: json["top-label"] == null ? null : json["top-label"],
        label: json["label"] == null ? null : json["label"],
        labelTheme: json["label-theme"] == null ? null : json["label-theme"],
        location: json["location"] == null ? null : json["location"],
        talkTitle: json["talk-title"] == null ? null : json["talk-title"],
        speakerShortdesc: json["speaker-shortdesc"] == null ? null : json["speaker-shortdesc"],
        fullDescription: json["full-description"] == null ? null : json["full-description"],
        directions: json["directions"] == null ? null : json["directions"],
        imagethumb: json["imagethumb"] == null ? null : json["imagethumb"],
        imagehq: json["imagehq"] == null ? null : json["imagehq"],
        contactInfo: json["contact_info"] == null ? null : json["contact_info"],
        contactPhone: json["contact_phone"] == null ? null : json["contact_phone"],
        url: json["url"] == null ? null : json["url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "start-time": startTime == null ? null : startTime,
        "end-time": endTime == null ? null : endTime,
        "talk-type": talkType == null ? null : talkTypeValues.reverse[talkType],
        "top-label": topLabel == null ? null : topLabelValues.reverse[topLabel],
        "label": label == null ? null : label,
        "label-theme": labelTheme == null ? null : labelTheme,
        "location": location == null ? null : location,
        "talk-title": talkTitle == null ? null : talkTitle,
        "speaker-shortdesc": speakerShortdesc == null ? null : speakerShortdesc,
        "full-description": fullDescription == null ? null : fullDescription,
        "directions": directions == null ? null : directions,
        "imagethumb": imagethumb == null ? null : imagethumb,
        "imagehq": imagehq == null ? null : imagehq,
        "contact_info": contactInfo == null ? null : contactInfo,
        "contact_phone": contactPhone == null ? null : contactPhone,
        "url": url == null ? null : url,
    };
}

enum TalkType { DEFAULT }

final talkTypeValues = EnumValues({
    "Default": TalkType.DEFAULT
});

enum TopLabel { YES }

final topLabelValues = EnumValues({
    "Yes": TopLabel.YES
});

class EnumValues<T> {
    Map<String, T> map;
    Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        if (reverseMap == null) {
            reverseMap = map.map((k, v) => new MapEntry(v, k));
        }
        return reverseMap;
    }
}
