//  KeyboardObserver.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import Combine
import UIKit

class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0 // 정확한 키보드 높이

    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification in
                // 여기에 클로저 매개변수 notification의 타입을 명시적으로 'Notification'으로 지정합니다.
                // 그리고 userInfo에서 값을 가져올 때 타입을 명확히 합니다.
                guard let userInfo = notification.userInfo,
                      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                return (true, keyboardFrame.height)
            }
            // sink 클로저의 매개변수 타입도 명시적으로 지정합니다.
            .sink { [weak self] (isVisible: Bool, height: CGFloat) in // <<-- 이 부분을 수정했습니다.
                self?.isKeyboardVisible = isVisible
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in // 이 클로저는 매개변수를 사용하지 않으므로 변경 없음
                self?.isKeyboardVisible = false
                self?.keyboardHeight = 0
            }
            .store(in: &cancellables)
    }
}
