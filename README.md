# VideoFilterExporter

This is a simple, lightweight iOS utility that allows applying for saving `AVAsset`s with `CIFilter`s applied.

## Examples

    let asset: AVAsset //your video
    let filters: [CIFilter] //an array of CIFilters to apply to the asset
    let exporter = VideoFilterExporter(asset: asset, filters: filters)
    
    let url: NSURL //the URL to export the video with filters to
    exporter.export(toURL: url){(url: NSURL?) -> Void in
        // The filters have been applied and the new video is now at url
    }
    
