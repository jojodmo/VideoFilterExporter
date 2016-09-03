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

class VideoFilterCompositionInstruction : AVMutableVideoCompositionInstruction{
    
    let trackID: CMPersistentTrackID
    let filters: [CIFilter]
    let context: CIContext
    
    override var passthroughTrackID: CMPersistentTrackID{get{return self.trackID}}
    override var requiredSourceTrackIDs: [NSValue]{get{return [NSNumber(integer: Int(self.trackID))]}}
    override var containsTweening: Bool{get{return false}}
    
    init(trackID: CMPersistentTrackID, filters: [CIFilter], context: CIContext){
        self.trackID = trackID
        self.filters = filters
        self.context = context
        
        super.init()
        
        self.enablePostProcessing = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
