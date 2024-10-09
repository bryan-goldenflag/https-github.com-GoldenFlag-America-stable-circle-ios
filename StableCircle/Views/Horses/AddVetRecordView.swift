import SwiftUI
import SwiftData

struct AddVetRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var horse: Horse
    
    @State private var date = Date()
    @State private var procedure = ""
    @State private var veterinarian = ""

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Procedure", text: $procedure)
                TextField("Veterinarian", text: $veterinarian)

                Button("Save") {
                    let newRecord = VeterinaryRecord(date: date, procedure: procedure, veterinarian: veterinarian)
                    horse.veterinaryRecords.append(newRecord)
                    try? modelContext.save()
                    dismiss()
                }
            }
            .navigationTitle("Add Veterinary Record")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}