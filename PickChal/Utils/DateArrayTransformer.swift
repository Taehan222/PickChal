//
//  DateArrayTransformer.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import Foundation
import CoreData

class DateArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let dates = value as? [Date] else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: dates, requiringSecureCoding: false)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Date]
    }
}
