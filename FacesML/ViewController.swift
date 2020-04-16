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
            let request = VNDetectFaceLandmarksRequest(){ (request, error) in
                guard let results = request.results as? [VNFaceObservation] else{
                    print(fatalError())
                }
              // uncomment below to only show rectangles
              //  self.imageView.image =  self.imageView.image!.drawOnImage(observations: results)
                self.imageView.image = self.imageView.image!.drawLandmarksOnImage(observations: results)  //this gives landmarks also
                
                
               
                
                
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

//MARK: -Draws rectangles
extension UIImage{//below shos only rectangles
//   func drawOnImage(observations: [VNFaceObservation]) -> UIImage? {
//
//           UIGraphicsBeginImageContext(self.size)
//
//           guard let context = UIGraphicsGetCurrentContext() else {
//                     return nil
//                 }
//
//           self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//
//           context.setStrokeColor(UIColor.red.cgColor)
//           context.setLineWidth(5.0)
//
//           let transform = CGAffineTransform(scaleX: 1, y: -1)
//                             .translatedBy(x: 0, y: -self.size.height)
//
//           for observation in observations {
//
//               let rect = observation.boundingBox
//               let normalizedRect = VNImageRectForNormalizedRect(rect, Int(self.size.width), Int(self.size.height))
//                              .applying(transform)
//               context.stroke(normalizedRect)
//           }
//
//           let result = UIGraphicsGetImageFromCurrentImageContext()
//           UIGraphicsEndImageContext()
//
//           return result
//
//       }
    //MARK: -LANDMARKS

   
        
        func drawLandmarksOnImage(observations: [VNFaceObservation]) -> UIImage? {
            
            UIGraphicsBeginImageContext(self.size)
            guard let context = UIGraphicsGetCurrentContext() else {
                fatalError("Unable to initialize context!")
            }
            
            self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
            
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            observations.forEach { face in
            
                guard let landmark = face.landmarks else {
                    return
                }
                
                let width = face.boundingBox.width * self.size.width
                let height = face.boundingBox.height * self.size.height
                let x = face.boundingBox.origin.x * self.size.width
                let y = face.boundingBox.origin.y * self.size.height
                
                let faceRect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
                
                context.setStrokeColor(UIColor.red.cgColor)
                context.stroke(faceRect, width: 4.0)
                
                if let leftEye = landmark.leftEye {
                    drawLines(context: context, points: leftEye.normalizedPoints, boundingBox: face.boundingBox)
                }
                
                if let rightEye = landmark.rightEye {
                    drawLines(context: context, points: rightEye.normalizedPoints, boundingBox: face.boundingBox)
                }
                if let innerLips = landmark.innerLips {
                    drawLines(context: context, points: innerLips.normalizedPoints, boundingBox: face.boundingBox)
                }
                
                if let outerLips = landmark.outerLips {
                    drawLines(context: context, points: outerLips.normalizedPoints, boundingBox: face.boundingBox)
                }
                
                if let leftPupil = landmark.leftPupil {
                    drawLines(context: context, points: leftPupil.normalizedPoints, boundingBox: face.boundingBox)
                }
                
                if let rightPupil = landmark.rightPupil {
                    drawLines(context: context, points: rightPupil.normalizedPoints, boundingBox: face.boundingBox)
                }
                
            }
            
            let result = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            
            return result
        }
        
        
        
        private func drawLines(context: CGContext, points: [CGPoint], boundingBox: CGRect) {
            
            let width = boundingBox.width * self.size.width
            let height = boundingBox.height * self.size.height
            let x = boundingBox.origin.x * self.size.width
            let y = boundingBox.origin.y * self.size.height
            
            context.setStrokeColor(UIColor.yellow.cgColor)
            
            var lastPoint = CGPoint.zero
            
            points.forEach { currentPoint in
                
                if lastPoint == CGPoint.zero {
                    context.move(to: CGPoint(x: currentPoint.x * width + x, y: currentPoint.y * height + y))
                    lastPoint = currentPoint
                } else {
                    context.addLine(to: CGPoint(x: currentPoint.x * width + x, y: currentPoint.y * height + y))
                }
                
            }
            
            context.closePath()
            context.setLineWidth(8.0)
            context.drawPath(using: .stroke)
            
        }
        
    }

   

