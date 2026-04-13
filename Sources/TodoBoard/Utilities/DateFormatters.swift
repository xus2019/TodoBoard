import Foundation

enum DateFormatters {
    private static let utcTimeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
    private static let iso8601FormatterKey = "TodoBoard.ISO8601DateFormatter"
    private static let monthFormatterKey = "TodoBoard.MonthDateFormatter"

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = utcTimeZone
        calendar.firstWeekday = 1
        return calendar
    }()

    static func weekRange(for date: Date) -> String {
        let now = Date()

        // Check if this week
        if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            && calendar.isDate(date, equalTo: now, toGranularity: .yearForWeekOfYear)
        {
            return "本周"
        }

        // Check if last week
        if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now),
           calendar.isDate(date, equalTo: lastWeek, toGranularity: .weekOfYear)
            && calendar.isDate(date, equalTo: lastWeek, toGranularity: .yearForWeekOfYear)
        {
            return "上周"
        }

        // Show date range
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return ""
        }

        let endDate = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
        let startMonth = calendar.component(.month, from: interval.start)
        let startDay = calendar.component(.day, from: interval.start)
        let endMonth = calendar.component(.month, from: endDate)
        let endDay = calendar.component(.day, from: endDate)

        let currentYear = calendar.component(.year, from: now)
        let dateYear = calendar.component(.year, from: date)

        let rangeStr = "\(startMonth)月\(startDay)日 - \(endMonth)月\(endDay)日"
        if dateYear != currentYear {
            return "\(rangeStr) (\(dateYear))"
        }
        return rangeStr
    }

    static func monthTitle(for date: Date) -> String {
        let now = Date()

        // Check if this month
        if calendar.isDate(date, equalTo: now, toGranularity: .month)
            && calendar.isDate(date, equalTo: now, toGranularity: .year)
        {
            return "本月"
        }

        // Check if last month
        if let lastMonth = calendar.date(byAdding: .month, value: -1, to: now),
           calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
            && calendar.isDate(date, equalTo: lastMonth, toGranularity: .year)
        {
            return "上月"
        }

        return monthFormatter().string(from: date)
    }

    static func relativeDone(for date: Date) -> String {
        let now = Date()
        let components = calendar.dateComponents([.day, .hour], from: date, to: now)
        if let day = components.day, day >= 1 {
            let month = calendar.component(.month, from: date)
            let dayValue = calendar.component(.day, from: date)
            return "\(month)/\(dayValue) 完成"
        }
        if let hour = components.hour, hour >= 1 {
            return "\(hour)小时前完成"
        }
        return "刚刚完成"
    }

    static func iso8601(for date: Date) -> String {
        iso8601Formatter().string(from: date)
    }

    static func fromISO8601(_ string: String) -> Date? {
        iso8601Formatter().date(from: string)
    }

    private static func iso8601Formatter() -> ISO8601DateFormatter {
        if let formatter = Thread.current.threadDictionary[iso8601FormatterKey] as? ISO8601DateFormatter {
            return formatter
        }
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = utcTimeZone
        formatter.formatOptions = [.withInternetDateTime]
        Thread.current.threadDictionary[iso8601FormatterKey] = formatter
        return formatter
    }

    private static func monthFormatter() -> DateFormatter {
        if let formatter = Thread.current.threadDictionary[monthFormatterKey] as? DateFormatter {
            return formatter
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.timeZone = utcTimeZone
        formatter.dateFormat = "yyyy年M月"
        Thread.current.threadDictionary[monthFormatterKey] = formatter
        return formatter
    }
}
