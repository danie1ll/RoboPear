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
    @State private var landingPageURL: String?
    @State private var alertItem: AlertItem?
    @State private var isUploading = false

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
                    UploadResultView(result: uploadResult ?? "", landingPageURL: landingPageURL, onBack: {
                        currentStep = 0
                        image = nil
                        description = ""
                        uploadResult = nil
                        landingPageURL = nil
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
        .overlay(
            Group {
                if isUploading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                        Text("Uploading...")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
            }
        )
    }
    
    private func uploadImageAndDescription() {
        guard let image = image else { return }
        
        isUploading = true
        
        APIService.shared.uploadImage(image) { result in
            switch result {
            case .success(let imageMessage):
                print("Image upload success: \(imageMessage)")
                
                // Now upload the text
                APIService.shared.uploadText(self.description) { textResult in
                    DispatchQueue.main.async {
                        isUploading = false
                        switch textResult {
                        case .success(let textMessage):
                            print("Text upload success: \(textMessage)")
                            self.landingPageURL = textMessage
                            self.uploadResult = "Image and text uploaded successfully"
                            self.currentStep = 2
                        case .failure(let error):
                            print("Text upload failure: \(error)")
                            self.alertItem = AlertItem(title: "Text Upload Error", message: error.localizedDescription)
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    isUploading = false
                    print("Image upload failure: \(error)")
                    self.alertItem = AlertItem(title: "Image Upload Error", message: error.localizedDescription)
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
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
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
                    if isRecording {
                        speechRecognizer.stopTranscribing()
                    } else {
                        speechRecognizer.transcribe()
                    }
                    isRecording.toggle()
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
        .onAppear {
            speechRecognizer.requestAuthorization()
        }
        .onChange(of: speechRecognizer.transcript) { newValue in
            description = newValue
        }
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
    let landingPageURL: String?
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Result")
                .font(.title)
            
            Text(result)
                .multilineTextAlignment(.center)
                .padding()
            
            if let url = landingPageURL {
                Text("Here is your awesome landing page:")
                    .font(.headline)
                    .padding(.top)
                
                Link(url, destination: URL(string: url) ?? URL(string: "https://example.com")!)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Button(action: onBack) {
                Text("Back to Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .navigationBarBackButtonHidden(true)
        .padding()
    }
}

#Preview {
    ContentView()
}
