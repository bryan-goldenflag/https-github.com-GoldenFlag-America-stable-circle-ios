import SwiftUI
import SwiftData

struct VetRecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var horse: Horse
    @Bindable var record: VeterinaryRecord
    var onDelete: (VeterinaryRecord) -> Void

    var body: some View {
        Form {
            DatePicker("Date", selection: $record.date, displayedComponents: .date)
            TextField("Procedure", text: $record.procedure)
            TextField("Veterinarian", text: $record.veterinarian)

            Button("Delete Record", role: .destructive) {
                onDelete(record)
                dismiss()
            }
        }
        .navigationTitle("Veterinary Record")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    try? modelContext.save()
                    dismiss()
                }
            }
        }
    }
}
