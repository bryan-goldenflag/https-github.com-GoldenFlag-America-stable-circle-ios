import SwiftUI
import SwiftData

struct HorseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var horses: [Horse]
    @State private var showingAddHorse = false

    var body: some View {
        NavigationView {
            List {
                ForEach(horses) { horse in
                    NavigationLink(destination: HorseDetailView(horse: horse)) {
                        HorseRowView(horse: horse)
                    }
                }
                .onDelete(perform: deleteHorses)
            }
            .navigationTitle("Horses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddHorse = true }) {
                        Label("Add Horse", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHorse) {
                AddHorseView()
            }
        }
    }

    private func deleteHorses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(horses[index])
            }
        }
    }
}

struct HorseRowView: View {
    let horse: Horse

    var body: some View {
        HStack {
            if let profilePicture = horse.photos.first(where: { $0.isProfilePicture }),
               let uiImage = UIImage(data: profilePicture.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "horse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            VStack(alignment: .leading) {
                Text(horse.name)
                    .font(.headline)
                Text(horse.breed)
                    .font(.subheadline)
            }
        }
    }
}
