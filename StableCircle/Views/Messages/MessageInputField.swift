import SwiftUI

struct MessageInputField: View {
    @Binding var newMessageText: String
    let onSend: () -> Void

    var body: some View {
        HStack {
            TextField("Type a message", text: $newMessageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .disabled(newMessageText.isEmpty)
            .padding(.trailing)
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}
