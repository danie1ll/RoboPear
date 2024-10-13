//
//  ContentView.swift
//  RoboPear
//
//  Created by Danylo Movchan on 10/12/24.
//
import SwiftUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var description: String = ""
    @State private var isShowingImagePicker = false
    @State private var isRecording = false

    var body: some View {
        VStack {
            // Image display
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Image(systemName: "camera")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }

            // Take picture button
            Button("Take Picture") {
                isShowingImagePicker = true
            }

            // Description input
            TextField("Enter description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Voice input button
            Button(isRecording ? "Stop Recording" : "Start Voice Input") {
                isRecording.toggle()
                // Implement voice recording logic here
            }

            // Send to server button
            Button("Send to Server") {
                sendToServer()
            }
        }
        .padding()
        .navigationTitle("Upload")
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $image)
        }
    }

    func sendToServer() {
        // Implement server sending logic here
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContentView()
}
