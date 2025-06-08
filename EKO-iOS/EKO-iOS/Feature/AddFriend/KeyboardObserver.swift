//
//  KeyboardObserver.swift
//  EKO-iOS
//
//  Created by 성현 on 6/8/25.
//

import UIKit

final class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false

    init() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isKeyboardVisible = true
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isKeyboardVisible = false
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

