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

class VideoFilterExport{
    
    let asset: AVAsset
    let filters: [CIFilter]
    let context: CIContext
    init(asset: AVAsset, filters: [CIFilter], context: CIContext){
        self.asset = asset
        self.filters = filters
        self.context = context
    }
    
    convenience init(asset: AVAsset, filters: [CIFilter]){
        let eagl = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let context = CIContext(EAGLContext: eagl, options: [kCIContextWorkingColorSpace : NSNull()])
        
        self.init(asset: asset, filters: filters, context: context)
    }
    
    func export(toURL url: NSURL, callback: (url: NSURL?) -> Void){
        guard let track: AVAssetTrack = self.asset.tracksWithMediaType(AVMediaTypeVideo).first else{callback(url: nil); return}
        
        let composition = AVMutableComposition()
        composition.naturalSize = track.naturalSize
        let videoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do{try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, self.asset.duration), ofTrack: track, atTime: kCMTimeZero)}
        catch _{callback(url: nil); return}
        
        if let audio = self.asset.tracksWithMediaType(AVMediaTypeAudio).first{
            do{try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, self.asset.duration), ofTrack: audio, atTime: kCMTimeZero)}
            catch _{callback(url: nil); return}
        }
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.trackID = videoTrack.trackID
        
        let instruction = VideoFilterCompositionInstruction(trackID: videoTrack.trackID, filters: self.filters, context: self.context)
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration)
        instruction.layerInstructions = [layerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.customVideoCompositorClass = VideoFilterCompositor.self
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.instructions = [instruction]
        
        let session: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        session.videoComposition = videoComposition
        session.outputURL = url
        session.outputFileType = AVFileTypeMPEG4
        
        session.exportAsynchronouslyWithCompletionHandler(){
            dispatch_async(dispatch_get_main_queue()){
                callback(url: url)
            }
        }
    }
}
