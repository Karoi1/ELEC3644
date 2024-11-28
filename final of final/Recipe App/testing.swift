import SwiftUI

struct testing: View {
    @State private var loadedImage: UIImage? = nil
    var basePath = "/var/mobile/Containers/Data/Application/2C77B60E-DF8E-4512-8E96-629804850101/Documents/27.png"
    var recipeid = 27
    
    var body: some View {
        VStack {
            if let loadedImage = loadSavedImage(newid: recipeid) {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350, height: 200)
            }
        }
        .onAppear {
            loadedImage = loadSavedImage(newid: 27) // Load the image when the view appears
        }
    }
    
    // Load image from Document Directory
    private func loadSavedImage(newid: Int) -> UIImage? {
        let filename = getDocumentsDirectory().appendingPathComponent("\(newid).png") // Construct the file path
        return UIImage(contentsOfFile: filename.path) // Load the image
    }

    // Get Document Directory path
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

#Preview {
    testing()
}
