# VideoFilterExporter

This is a simple, lightweight iOS utility that allows applying for saving `AVAsset`s with `CIFilter`s applied.

The `kCVPixelBufferPixelFormatTypeKey` value of both `requiredPixelBufferAttributesForRenderContext` and `sourcePixelBufferAttributes` in the `VideoFilterCompositor` class can be altered to fit your needs

It is important to keep in mind that as the length of the video increses, the time it takes to process also increses. This utility is in no way intended for real-time processing, and can take a few seconds to process a one minute video.

**Make sure** that both the import URL (if it exists) and export URL end in either `.mp4` or `.mov`.

## Usage

    let asset: AVAsset //your video
    let filters: [CIFilter] //an array of CIFilters to apply to the asset
    let exporter = VideoFilterExporter(asset: asset, filters: filters)
    // there is also an initializer which accepts an additional context: CIContext parameter
    // VideoFilterExporter(asset: asset, filters: filters, context: myCIContext)
    
    let url: URL // the URL to export the video with filters to.
                 // MAKE SURE THIS ENDS IN EITHER .mp4 OR .mov
    exporter.export(toURL: url){(url: URL?) -> Void in
        // The filters have been applied and the new video is now at url
    }
    
## Example

This will take the video at the URL "\(NSHomeDirectory())/Documents/myVideo.mp4", apply a filter that sets the vibrance to **2**, then save the video to the URL "\(NSHomeDirectory())/Documents/vibranceVideo.mp4".

    let asset: AVAsset = AVAsset(URL: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/myVideo.mp4"))
    var filters: [CIFilter] = []
            
    let vibrance = CIFilter(name: "CIVibrance")
    vibrance?.setValue(2, forKey: "inputAmount")
    if let vibrance = vibrance{
      filters.append(vibrance)
    }
            
    let exporter = VideoFilterExport(asset: asset, filters: filters)
    exporter.export(toURL: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/vibranceVideo.mp4")){(url: URL?) -> Void in
        // The video with applied filters is now at the URL "\(NSHomeDirectory())/Documents/vibranceVideo.mp4"
        // if no errors were encountered
    }
    
 ## Rotating a Video
 
 To rotate the video using this utility, use the `CIAffineTransform` filter

     let size = asset.tracks(withMediaType: AVMediaTypeVideo).first!.naturalSize

     let degrees = // How many degrees to rotate the video by (multiple of 90)
     let mirrored = // Whether or not the video should be mirrored
     let extent = CGRect(x: 0, y: 0, width: size.width, height: size.height))

     var tx = CGAffineTransform(
         translationX: extent.width / 2,
         y: extent.height / 2
     )
    
     tx = tx.rotated(by: (CGFloat(degrees) / 90.0) * CGFloat(M_PI_2)) 
     tx = tx.translatedBy(x: -extent.width / 2, y: -extent.height / 2)
    
     if(mirrored){
         tx = tx.scaledBy(x: -1.0, y: 1.0)  
         tx = tx.translatedBy(x: -extent.width, y: 0.0)
     }
    
     let transformFilter = CIFilter(name: "CIAffineTransform")!
     transformFilter.setDefaults()
     transformFilter.setValue(NSValue(cgAffineTransform: tx, forKey: kCIInputTransformKey))

     // Use transformFilter as one of the filters on the video
    
