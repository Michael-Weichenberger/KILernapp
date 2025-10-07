
import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            Text(message)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.red.opacity(0.9))
                .cornerRadius(12)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { isShowing = false }
                    }
                }
                .zIndex(100)
        }
    }
}
