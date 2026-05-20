//
//  Alert.swift
//  activityapp
//
//  Created by Ty Dickson on 5/17/26.
//

import SwiftUI
internal import Combine

// Toast Manager - Global singleton
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toast: Toast?
    
    private init() {}
    
    func show(_ message: String, type: ToastType = .info, duration: TimeInterval = 2.0) {
        toast = Toast(message: message, type: type, duration: duration)
    }
    
    func success(_ message: String) {
        show(message, type: .success)
    }
    
    func error(_ message: String) {
        show(message, type: .error)
    }
    
    func info(_ message: String) {
        show(message, type: .info)
    }
    
    func warning(_ message: String) {
        show(message, type: .warning)
    }
}

// Toast Model
struct Toast: Equatable {
    let message: String
    let type: ToastType
    let duration: TimeInterval
}

// Toast Types
enum ToastType {
    case success, error, info, warning
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
}

// Toast View
struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.title3)
                .foregroundColor(.white)
            
            Text(toast.message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(toast.type.color.opacity(0.95))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// Toast Modifier
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toastManager.toast {
                VStack {
                    ToastView(toast: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.top, 50)
                        
                    Spacer()
                }
                .animation(.spring(), value: toastManager.toast)
                .zIndex(1)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                        withAnimation {
                            toastManager.toast = nil
                        }
                    }
                }
            }
        }
    }
}

// View Extension
extension View {
    func toast() -> some View {
        modifier(ToastModifier())
    }
}
