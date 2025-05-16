//
//  ChallengeEntity.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//


import CoreData

@objc(ChallengeEntity)
public class ChallengeEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var totalCount: Int16
    @NSManaged public var completedCount: Int16
}