//
//  DateExtensions.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/30/21.
//

import Foundation

extension Date {

    // Convert local time to UTC (or GMT)
    func toUTCTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

}
