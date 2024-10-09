import SwiftUI
import SwiftData

struct AddCareScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var horse: Horse
    
    @State private var type = ""
    @State private var frequency = ""
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Type (e.g., Feeding, Grooming)", text: $type)
                TextField("Frequency (e.g., Daily, Weekly)", text: $frequency)
                TextField("Notes", text: $notes)

                Button("Save") {
                    let newSchedule = CareSchedule(type: type, frequency: frequency, notes: notes)
                    horse.careSchedules.append(newSchedule)
                    try? modelContext.save()
                    dismiss()
                }
            }
            .navigationTitle("Add Care Schedule")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}