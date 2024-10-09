import SwiftUI
import SwiftData

struct AddHorseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var breed = ""
    @State private var dateOfBirth = Date()
    @State private var color = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Breed", text: $breed)
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                TextField("Color", text: $color)
                
                Button("Save") {
                    let newHorse = Horse(name: name, breed: breed, dateOfBirth: dateOfBirth, color: color)
                    modelContext.insert(newHorse)
                    dismiss()
                }
            }
            .navigationTitle("Add New Horse")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}