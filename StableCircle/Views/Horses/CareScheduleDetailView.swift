import SwiftUI
import SwiftData

struct CareScheduleDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var horse: Horse
    @Bindable var schedule: CareSchedule
    var onDelete: (CareSchedule) -> Void

    var body: some View {
        Form {
            TextField("Type", text: $schedule.type)
            TextField("Frequency", text: $schedule.frequency)
            TextField("Notes", text: $schedule.notes)

            Button("Delete Schedule", role: .destructive) {
                onDelete(schedule)
                dismiss()
            }
        }
        .navigationTitle("Care Schedule")
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
