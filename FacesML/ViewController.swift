import UIKit
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
  
        // Do any additional setup after loading the view.
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.isNavigationBarHidden = false; self.dismiss(animated: true, completion: nil)}
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage
        {  imageView.image = userPickedImage
            //uncomment below two lines to convert to CI Image
            let cgImage = userPickedImage.cgImage!
            let orientation = CGImagePropertyOrientation(rawValue: UInt32(userPickedImage
                .imageOrientation.rawValue))!
            let request = VNDetectFaceRectanglesRequest(){ (request, error) in
                guard let results = request.results as? [VNFaceObservation] else{
                    print(fatalError())
                }
                
                self.navigationItem.title = String(results.count)
                
                
                
                
            }
            let handler = VNImageRequestHandler(cgImage: cgImage,orientation: orientation)
            do{
                try handler.perform([request])
                
            }
            catch{print(error)
                
            }
            
            
            
        }
        
        
        
        
        //  guard let ciImage = CIImage(image:userPickedImage) else{
        //       fatalError()
        
        //       }
        
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera()
    {
       
          
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        
      
    }
    func openGallery()
    {
       
            
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
       
}
}
