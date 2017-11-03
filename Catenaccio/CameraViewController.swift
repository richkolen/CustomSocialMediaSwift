//
//  CameraViewController.swift
//  Catenaccio
//
//  Created by Richard Kolen on 06-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var placeholderTextview: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelNewPostButton: UIButton!
    var selectedImage: UIImage?
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectedProfilePhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        captionTextView.backgroundColor = .white
    }
    
    internal func textViewDidEndEditing(_ textView: UITextView) {
        guard let checkTextview = captionTextView.text, !checkTextview.isEmpty else {
            captionTextView.backgroundColor = .clear
            return
        }
    }
    
    func handlePost() {
        if selectedImage != nil {
            self.shareButton.isEnabled = true
            self.cancelNewPostButton.isEnabled = true
            self.captionTextView.isUserInteractionEnabled = true
            self.placeholderTextview.textColor = UIColor(red: 153/250, green: 153/250, blue: 153/250, alpha: 0.9)
            self.shareButton.backgroundColor = UIColor(red: 79/250, green: 235/250, blue: 149/250, alpha: 1)
        } else {
            self.shareButton.isEnabled = false
            self.cancelNewPostButton.isEnabled = false
            self.captionTextView.isUserInteractionEnabled = false
            self.placeholderTextview.textColor = UIColor(red: 230/250, green: 230/250, blue: 230/250, alpha: 0.8)
            self.shareButton.backgroundColor = UIColor(red: 79/250, green: 235/250, blue: 149/250, alpha: 0.4)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func handleSelectedProfilePhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareBtn_TouchUpInside(_ sender: Any) {
        ProgressHUD.show("Loading..", interaction: false)
        if let selectedImg = self.selectedImage {
            let compressSelectedImg = compressImage(selectedImg)
            let imageData = UIImageJPEGRepresentation(compressSelectedImg, 0.3)
            let ratio = selectedImg.size.width / selectedImg.size.height
            
            HelperService.uploadDataToServer(data: imageData!, videoUrl: videoUrl, ratio: ratio, caption: captionTextView.text!, onSucces: {
                self.clearNewPost()
                self.tabBarController?.selectedIndex = 0
            })
            
            } else {
            ProgressHUD.showError("There is no image attached!")
        }
        
    }
    
    func compressImage (_ image: UIImage) -> UIImage {
        let actualHeight: CGFloat = image.size.height
        let actualWidth: CGFloat = image.size.width
        let imageRatio: CGFloat = actualWidth/actualHeight
        let maxWidth: CGFloat = 1024.0
        let resizedHeight: CGFloat = maxWidth/imageRatio
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData: Data = UIImageJPEGRepresentation(img, 0.5)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
    }

    
    @IBAction func removeImage_TouchUpInside(_ sender: Any) {
        clearNewPost()
        handlePost()
    }
        
    func clearNewPost() {
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
        self.captionTextView.backgroundColor = .clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}



extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            if let videoThumbnailImage = self.generateThumbnailForVideo(videoUrl) {
                self.videoUrl = videoUrl
                selectedImage = videoThumbnailImage
                photo.image = videoThumbnailImage
            }
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            photo.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func generateThumbnailForVideo(_ fileUrl: URL) -> UIImage? {
        let assets = AVAsset(url: fileUrl)
        let thumbnailGenerator = AVAssetImageGenerator(asset: assets)
        thumbnailGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailCGImage = try thumbnailGenerator.copyCGImage(at: CMTimeMake(1, 10), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
}


