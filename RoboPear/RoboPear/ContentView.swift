//
//  ContentView.swift
//  RoboPear
//
//  Created by Danylo Movchan on 10/12/24.
//

import SwiftUI
import AVFoundation

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct ContentView: View {
    @State private var currentStep = 0
    @State private var image: UIImage?
    @State private var description: String = ""
    @State private var isShowingImagePicker = false
    @State private var uploadResult: String?
    @State private var videoURL: String?
    @State private var alertItem: AlertItem?

    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case 0:
                    WelcomeView(onTakePicture: {
                        isShowingImagePicker = true
                    })
                case 1:
                    ProductDescriptionView(image: image!, description: $description, onSubmit: {
                        uploadImageAndDescription()
                    }, onBack: {
                        currentStep = 0
                        image = nil
                        description = ""
                    })
                case 2:
                    UploadResultView(result: uploadResult ?? "", videoURL: videoURL, onBack: {
                        currentStep = 0
                        image = nil
                        description = ""
                        uploadResult = nil
                        videoURL = nil
                    })
                default:
                    Text("Invalid step")
                }
            }
            .navigationBarTitle("RoboPear", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $image)
                .onDisappear {
                    if image != nil {
                        currentStep = 1
                    }
                }
        }
        .alert(item: $alertItem) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func uploadImageAndDescription() {
        guard let image = image else { return }
        
        APIService.shared.uploadImage(image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("Image upload success: \(message)")
                    uploadResult = message
                    currentStep = 2
                case .failure(let error):
                    print("Image upload failure: \(error)")
                    alertItem = AlertItem(title: "Upload Error", message: error.localizedDescription)
                }
            }
        }
    }
}

struct WelcomeView: View {
    let onTakePicture: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create an ad and validate your product in one click!")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: onTakePicture) {
                Text("Take a Picture")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

struct ProductDescriptionView: View {
    let image: UIImage
    @Binding var description: String
    let onSubmit: () -> Void
    let onBack: () -> Void
    @State private var isRecording = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
            HStack {
                TextField("Describe your product", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    isRecording.toggle()
                    // Implement voice input logic here
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle")
                        .foregroundColor(isRecording ? .red : .blue)
                        .font(.title)
                }
            }
            .padding()
            
            Button(action: onSubmit) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: onBack) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        #if targetEnvironment(simulator)
        picker.sourceType = .photoLibrary
        #else
        picker.sourceType = .camera
        #endif
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

struct UploadResultView: View {
    let result: String
    let videoURL: String?
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Result")
                .font(.title)
            
            Text(result)
                .multilineTextAlignment(.center)
                .padding()
            
            if let url = videoURL, !url.isEmpty {
                Text("Video URL: \(url)")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: onBack) {
                Text("Back to Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
}
