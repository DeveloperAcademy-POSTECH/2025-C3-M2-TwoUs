//
//  CoreDataManager.swift
//  EKO-iOS
//
//  Created by 신민규 on 6/9/25.
//

import CoreData

final class CoreDataManager {
    // 싱글톤 인스턴스
    static let shared = CoreDataManager()
    
    // Persistent Container (CoreData 스택)
    let persistentContainer: NSPersistentContainer
    
    // ViewContext → CoreData 작업 시 사용
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // 초기화 (private → 외부에서 인스턴스 못 만듦)
    private init() {
        // ⚠️ 여기 "Model" 은 .xcdatamodeld 파일 이름과 동일해야 함
        persistentContainer = NSPersistentContainer(name: "Model")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ CoreData 스토어 로드 실패: \(error)")
            } else {
                print("✅ CoreData 스토어 로드 성공!")
            }
        }
    }
    
    // 변경사항 저장 함수
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("✅ CoreData 저장 성공!")
            } catch {
                print("❌ CoreData 저장 실패: \(error)")
            }
        }
    }
}
