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
        let eagl = EAGLContext(API: EAGLRenderingAPI.openGLES2)
        let context = CIContext(EAGLContext: eagl!, options: [kCIContextWorkingColorSpace : NSNull()])
        
        self.init(asset: asset, filters: filters, context: context)
    }
    
    func export(toURL url: URL, @escaping callback: (url: URL?) -> Void){
        guard let track: AVAssetTrack = self.asset.tracks(withMediaType: AVMediaTypeVideo).first else{callback(nil); return}
        
        let composition = AVMutableComposition()
        composition.naturalSize = track.naturalSize
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do{try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, self.asset.duration), of: track, at: kCMTimeZero)}
        catch _{callback(nil); return}
        
        if let audio = self.asset.tracks(withMediaType: AVMediaTypeAudio).first{
            do{try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, self.asset.duration), ofTrack: audio, atTime: kCMTimeZero)}
            catch _{callback(nil); return}
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
        
        session.exportAsynchronously(){
            DispatchQueue.main.async{
                callback(url)
            }
        }
    }
}
