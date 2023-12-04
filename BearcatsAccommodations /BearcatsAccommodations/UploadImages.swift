//
//  UploadImages.swift
//  BearcatsAccommodations
//
//  Created by Mounica Seelam on 11/10/2023.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit
class UploadImages: NSObject{
    
    static func saveImages(imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
        
        let id = Auth.auth().currentUser?.uid ?? ""
        uploadImages(userId: id, imagesArray : imagesArray){ (uploadedImageUrlsArray) in
            print("uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
            completionHandler(uploadedImageUrlsArray)
        }
    }
    
    
    static func uploadImages(userId: String, imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
        let storage = Storage.storage()
        
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = imagesArray.count
        
        for image in imagesArray{
            
            let imageName = NSUUID().uuidString // Unique string to reference image
            
            //Create storage reference for image
            let storageRef = storage.reference().child("Images").child("\(imageName).png")
            
            
            let myImage = image
            guard let uplodaData = myImage.pngData() else{
                return
            }
            
            // Upload image to firebase
            let uploadTask = storageRef.putData(uplodaData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                
                storageRef.downloadURL(completion: { (url, error) in
                    
                    let str = url?.absoluteString
                    uploadedImageUrlsArray.append(str ?? "")
                    
                    uploadCount += 1
                    print("Number of images successfully uploaded: \(uploadCount)")
                    if uploadCount == imagesCount{
                        NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
                        completionHandler(uploadedImageUrlsArray)
                    }
                })
                
                
                
                
            })
            
            
            observeUploadTaskFailureCases(uploadTask : uploadTask)
        }
    }
    
    
    //Func to observe error cases while uploading image files, Ref: https://firebase.google.com/docs/storage/ios/upload-files
    
    
    static func observeUploadTaskFailureCases(uploadTask : StorageUploadTask){
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    NSLog("File doesn't exist")
                    break
                case .unauthorized:
                    NSLog("User doesn't have permission to access file")
                    break
                case .cancelled:
                    NSLog("User canceled the upload")
                    break
                    
                case .unknown:
                    NSLog("Unknown error occurred, inspect the server response")
                    break
                default:
                    NSLog("A separate error occurred, This is a good place to retry the upload.")
                    break
                }
            }
        }
    }
    
}
