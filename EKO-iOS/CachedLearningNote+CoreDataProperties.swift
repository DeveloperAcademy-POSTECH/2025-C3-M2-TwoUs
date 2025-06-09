//
//  CachedLearningNote+CoreDataProperties.swift
//  EKO-iOS
//
//  Created by 신민규 on 6/9/25.
//
//

import Foundation
import CoreData


extension CachedLearningNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedLearningNote> {
        return NSFetchRequest<CachedLearningNote>(entityName: "CachedLearningNote")
    }

    @NSManaged public var sessionId: String?
    @NSManaged public var receiverId: String?
    @NSManaged public var senderId: String?
    @NSManaged public var status: String?
    @NSManaged public var feedbackS3Key: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var isFavorite: Bool
    @NSManaged public var s3Key: String?
    @NSManaged public var title: String?
    @NSManaged public var voice1: String?
    @NSManaged public var voice2: String?

}

extension CachedLearningNote : Identifiable {

}
