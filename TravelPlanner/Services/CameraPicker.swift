//
//  CameraPicker.swift
//  TravelPlanner
//
//  Created by Valentyna Kharkova on 14.07.2026.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper around `UIImagePickerController` for capturing photos with the camera.
/// UIKit's camera picker has no native SwiftUi equivalent, so this bridges it via
/// `UIViewControllerRepresentable`
struct CameraPicker: UIViewControllerRepresentable {
    
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to Update
    }
    
    func makeCoordinator() -> Coordinator { 
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    Text("Camera preview doesn't work in simulator without a real device/camera")
}
