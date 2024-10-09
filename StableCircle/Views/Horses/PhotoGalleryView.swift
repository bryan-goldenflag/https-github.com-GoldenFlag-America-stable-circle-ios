import SwiftUI
import SwiftData
import PhotosUI

struct PhotoGalleryView: View {
    @Bindable var horse: Horse
    @Environment(\.modelContext) private var modelContext
    @State private var showingImagePicker = false
    @State private var inputImages: [UIImage] = []
    @State private var showingFullScreenImage = false
    @State private var selectedPhoto: Photo?

    let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(horse.photos, id: \.id) { photo in
                    if let uiImage = UIImage(data: photo.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                photo.isProfilePicture ?
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 3) : nil
                            )
                            .contextMenu {
                                Button(action: {
                                    deletePhoto(photo)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                if !photo.isProfilePicture {
                                    Button(action: {
                                        setAsProfilePicture(photo)
                                    }) {
                                        Label("Set as Profile Picture", systemImage: "person.crop.circle")
                                    }
                                }
                            }
                            .onTapGesture {
                                selectedPhoto = photo
                                showingFullScreenImage = true
                            }
                    }
                }
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "plus")
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImages) {
            ImagePicker(images: $inputImages)
        }
        .sheet(isPresented: $showingFullScreenImage) {
            if let photo = selectedPhoto, let uiImage = UIImage(data: photo.imageData) {
                FullScreenImageView(image: Image(uiImage: uiImage), caption: photo.caption)
            }
        }
    }

    func loadImages() {
        for inputImage in inputImages {
            if let imageData = inputImage.jpegData(compressionQuality: 0.8) {
                let newPhoto = Photo(imageData: imageData)
                horse.photos.append(newPhoto)
            }
        }
        try? modelContext.save()
        inputImages.removeAll() // Clear the temporary array after saving
    }

    func deletePhoto(_ photo: Photo) {
        if let index = horse.photos.firstIndex(where: { $0.id == photo.id }) {
            horse.photos.remove(at: index)
            modelContext.delete(photo)
            try? modelContext.save()
        }
    }

    func setAsProfilePicture(_ photo: Photo) {
        for p in horse.photos {
            p.isProfilePicture = (p.id == photo.id)
        }
        try? modelContext.save()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 0 means no limit
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }
}

struct FullScreenImageView: View {
    let image: Image
    let caption: String

    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
            Text(caption)
                .padding()
        }
    }
}
