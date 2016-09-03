# VideoFilterExporter

This is a simple, lightweight iOS utility that allows applying for saving `AVAsset`s with `CIFilter`s applied.

It is important to keep in mind that as the length of the video increses, the time it takes to process also increses. This utility is in no way intended for real-time processing, and can take a few seconds to process a one minute video.

## Usage

    let asset: AVAsset //your video
    let filters: [CIFilter] //an array of CIFilters to apply to the asset
    let exporter = VideoFilterExporter(asset: asset, filters: filters)
    
    let url: NSURL //the URL to export the video with filters to
    exporter.export(toURL: url){(url: NSURL?) -> Void in
        // The filters have been applied and the new video is now at url
    }
    
## Example

This will take the video at the URL "\(NSHomeDirectory())/Documents/myVideo.mp4", apply a filter that sets the vibrance to **2**, then save the video to the URL "\(NSHomeDirectory())/Documents/vibranceVideo.mp4".

    let asset: AVAsset = AVAsset(URL: NSURL(fileURLWithPath: "\(NSHomeDirectory())/Documents/myVideo.mp4"))
    var filters: [CIFilter] = []
            
    let vibrance = CIFilter(name: "CIVibrance")
    vibrance?.setValue(2, forKey: "inputAmount")
    if let vibrance = vibrance{
      filters.append(vibrance)
    }
            
    let exporter = VideoFilterExport(asset: asset, filters: filters)
    exporter.export(toURL: NSURL(fileURLWithPath: "\(NSHomeDirectory())/Documents/vibranceVideo.mp4")){(url: NSURL?) -> Void in
        // The video with applied filters is now at the URL "\(NSHomeDirectory())/Documents/vibranceVideo.mp4"
    }
    
