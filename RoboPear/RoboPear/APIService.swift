import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "https://96a4-4-39-199-2.ngrok-free.app" // Replace with your actual server address and port
    private let sessionID = UUID().uuidString // Generate a unique session ID
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])))
            return
        }
        
        let url = URL(string: baseURL + "/upload-image/\(sessionID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            // Print raw response for debugging
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.success(message))
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                    completion(.failure(NSError(domain: "InvalidResponseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format: \(responseString)"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func uploadText(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: baseURL + "/upload-text/\(sessionID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.success(message))
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                    completion(.failure(NSError(domain: "InvalidResponseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format: \(responseString)"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func generateVideo(imageURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: baseURL + "/generate-video/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "image_url=\(imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let videoURL = json["video_url"] as? String {
                    completion(.success(videoURL))
                } else {
                    completion(.failure(NSError(domain: "InvalidResponseError", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
