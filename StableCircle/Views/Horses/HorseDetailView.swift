import SwiftUI
import SwiftData

struct HorseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var horse: Horse
    @State private var showingAddVetRecord = false
    @State private var showingAddCareSchedule = false

    var body: some View {
        List {
            Section(header: Text("Details")) {
                TextField("Name", text: $horse.name)
                TextField("Breed", text: $horse.breed)
                DatePicker("Date of Birth", selection: $horse.dateOfBirth, displayedComponents: .date)
                TextField("Color", text: $horse.color)
            }

            Section(header: Text("Photo Gallery")) {
                NavigationLink(destination: PhotoGalleryView(horse: horse)) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("View Photo Gallery")
                    }
                }
            }
          
            Section(header: Text("Veterinary Records")) {
                ForEach(horse.veterinaryRecords) { record in
                    NavigationLink(destination: VetRecordDetailView(horse: horse, record: record, onDelete: deleteVetRecord)) {
                        VStack(alignment: .leading) {
                            Text(record.date, style: .date)
                            Text(record.procedure).lineLimit(1)
                        }
                    }
                }
                Button("Add Veterinary Record") {
                    showingAddVetRecord = true
                }
            }

            Section(header: Text("Care Schedules")) {
                ForEach(horse.careSchedules) { schedule in
                    NavigationLink(destination: CareScheduleDetailView(horse: horse, schedule: schedule, onDelete: deleteCareSchedule)) {
                        VStack(alignment: .leading) {
                            Text(schedule.type)
                            Text(schedule.frequency).font(.subheadline)
                        }
                    }
                }
                Button("Add Care Schedule") {
                    showingAddCareSchedule = true
                }
            }
        }
        .navigationTitle(horse.name)
        .sheet(isPresented: $showingAddVetRecord) {
            AddVetRecordView(horse: horse)
        }
        .sheet(isPresented: $showingAddCareSchedule) {
            AddCareScheduleView(horse: horse)
        }
    }

    private func deleteVetRecord(_ record: VeterinaryRecord) {
        if let index = horse.veterinaryRecords.firstIndex(where: { $0.id == record.id }) {
            horse.veterinaryRecords.remove(at: index)
            modelContext.delete(record)
            try? modelContext.save()
        }
    }

    private func deleteCareSchedule(_ schedule: CareSchedule) {
        if let index = horse.careSchedules.firstIndex(where: { $0.id == schedule.id }) {
            horse.careSchedules.remove(at: index)
            modelContext.delete(schedule)
            try? modelContext.save()
        }
    }
}
