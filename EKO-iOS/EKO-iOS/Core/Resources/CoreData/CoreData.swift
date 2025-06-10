//
//  CoreData.swift
//  EKO-iOS
//
//  Created by 신민규 on 6/7/25.
//

// #55
// 기능: CoreData Stack 구성 (PersistentContainer + saveContext 지원)

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Persistent Container
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model") // ⚠️ 모델(.xcdatamodeld)의 이름과 정확히 일치해야 함!
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Context 저장 함수
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
