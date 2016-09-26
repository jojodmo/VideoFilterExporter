/*
   Copyright 2016 Domenico Ottolia

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import Foundation

class VideoFilterCompositor : NSObject, AVVideoCompositing{
    
    // For Swift 2.*, replace [String : Any] and [String : Any]? with [String : AnyObject] and [String : AnyObject]? respectively
   
    // You may alter the value of kCVPixelBufferPixelFormatTypeKey to fit your needs
    var requiredPixelBufferAttributesForRenderContext: [String : Any] = [
        kCVPixelBufferPixelFormatTypeKey as String : NSNumber(unsignedInt: kCVPixelFormatType_32BGRA),
        kCVPixelBufferOpenGLESCompatibilityKey as String : NSNumber(bool: true),
        kCVPixelBufferOpenGLCompatibilityKey as String : NSNumber(bool: true)
    ]
    
    // You may alter the value of kCVPixelBufferPixelFormatTypeKey to fit your needs
    var sourcePixelBufferAttributes: [String : Any]? = [
        kCVPixelBufferPixelFormatTypeKey as String : NSNumber(unsignedInt: kCVPixelFormatType_32BGRA),
        kCVPixelBufferOpenGLESCompatibilityKey as String : NSNumber(bool: true),
        kCVPixelBufferOpenGLCompatibilityKey as String : NSNumber(bool: true)
    ]
    
    let renderQueue = dispatch_queue_create("com.jojodmo.videofilterexporter.renderingqueue", DISPATCH_QUEUE_SERIAL)
    let renderContextQueue = dispatch_queue_create("com.jojodmo.videofilterexporter.rendercontextqueue", DISPATCH_QUEUE_SERIAL)
    
    var renderContext: AVVideoCompositionRenderContext!
    override init(){
        super.init()
    }
    
    func startVideoCompositionRequest(request: AVAsynchronousVideoCompositionRequest){
        autoreleasepool(){
            dispatch_sync(self.renderQueue){
                guard let instruction = request.videoCompositionInstruction as? VideoFilterCompositionInstruction else{
                    request.finishWithError(NSError(domain: "jojodmo.com", code: 760, userInfo: nil))
                    return
                }
                guard let pixels = request.sourceFrameByTrackID(instruction.trackID) else{
                    request.finishWithError(NSError(domain: "jojodmo.com", code: 761, userInfo: nil))
                    return
                }
                
                var image = CIImage(CVPixelBuffer: pixels)
                for filter in instruction.filters{
                  filter.setValue(image, forKey: kCIInputImageKey)
                  image = filter.outputImage ?? image
                }
                
                let newBuffer: CVPixelBuffer? = self.renderContext.newPixelBuffer()

                if let buffer = newBuffer{
                    instruction.context.render(image, toCVPixelBuffer: buffer)
                    request.finishWithComposedVideoFrame(buffer)
                }
                else{
                    request.finishWithComposedVideoFrame(pixels)
                }
            }
        }
    }
    
    func renderContextChanged(newRenderContext: AVVideoCompositionRenderContext){
        dispatch_sync(self.renderContextQueue){
            self.renderContext = newRenderContext
        }
    }
}
