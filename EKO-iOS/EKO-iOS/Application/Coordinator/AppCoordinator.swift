//
//  AppCoordinator.swift
//  EKO-iOS
//
//  Created by mini on 5/28/25.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    /// push : 다음 화면으로 넘어갈 때 사용하는 메서드 (_ route 부분에 전환하고자 하는 다음 화면 명시)
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    /// pop : 이전 화면으로 돌아갈 때 사용하는 메서드
    func pop() {
        path.removeLast()
    }
    
    /// popToRoot : path에 쌓여있는 모든 화면을 지우고, 루트로 돌아가도록 하는 메서드
    func popToRoot() {
        path.removeLast(path.count)
    }
}
