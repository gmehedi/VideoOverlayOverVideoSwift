//
//  ViewController.swift
//  OverlayVideoOverVideo
//
//  Created by M M MEHEDI HASAN on 2/9/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    var audioIsEnabled = false
    var outputSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.outputSize = self.topView.bounds.size
            let v1 = Bundle.main.url(forResource: "video2", withExtension: "mp4")
            let v2 = Bundle.main.url(forResource: "animation", withExtension: "mp4")
            self.exportVideoWithAnimation(videoUrl: v1!, video2Url: v2!, image: UIImage())
        })
    }


}

extension ViewController {
    
    func exportVideoWithAnimation(videoUrl: URL, video2Url: URL, image: UIImage) {
        
        let composition = AVMutableComposition()
        
        let asset = AVAsset(url: videoUrl)
        let track =  asset.tracks(withMediaType: AVMediaType.video)
        print("CC  ", track.count)
        let videoTrack: AVAssetTrack = track[0] as AVAssetTrack
        let timerange = CMTimeRangeMake(start: CMTime.zero, duration: (asset.duration))
        
        let compositionVideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        ////
        
        let asset1 = AVAsset(url: video2Url)
        let track1 =  asset1.tracks(withMediaType: AVMediaType.video)
        print("CC  ", track.count)
        let videoTrack1: AVAssetTrack = track1[0] as AVAssetTrack
        let timerange1 = CMTimeRangeMake(start: CMTime.zero, duration: (asset1.duration))
        
        let compositionVideoTrack1: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
        
        do {
            try compositionVideoTrack1.insertTimeRange(timerange1, of: videoTrack1, at: CMTime.zero)
            compositionVideoTrack1.preferredTransform = videoTrack1.preferredTransform
        } catch {
            print(error)
        }
        
        
        //if your video has sound, you don’t need to check this
        if audioIsEnabled {
            let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            
            for audioTrack in (asset.tracks(withMediaType: AVMediaType.audio)) {
                do {
                    try compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: CMTime.zero)
                } catch {
                    print(error)
                }
            }
        }
        let videoSize = CGSize(width: max(videoTrack.naturalSize.width, videoTrack1.naturalSize.width), height: max(videoTrack.naturalSize.height, videoTrack1.naturalSize.height))
        
//        let nextPhoto = image
//        let horizontalRatio = CGFloat(self.outputSize.width) / nextPhoto.size.width
//        let verticalRatio = CGFloat(self.outputSize.height) / nextPhoto.size.height
//        let aspectRatio = min(horizontalRatio, verticalRatio)
//        let newSize: CGSize = CGSize(width: nextPhoto.size.width * aspectRatio, height: nextPhoto.size.height * aspectRatio)
//        let x = newSize.width < self.outputSize.width ? (self.outputSize.width - newSize.width) / 2 : 0
//        let y = newSize.height < self.outputSize.height ? (self.outputSize.height - newSize.height) / 2 : 0
        
        ///I showed 10 animations here. You can uncomment any of this and export a video to see the result
        
//        //let size = self.newSize!
//        let videoSize = videoTrack.naturalSize
//
//        let parentlayer = CALayer()
//        parentlayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
//        parentlayer.backgroundColor = UIColor.clear.cgColor
//
//        let videolayer = CALayer()
//        videolayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
//        videolayer.backgroundColor = UIColor.red.cgColor
//        parentlayer.addSublayer(videolayer)
//
//        let blackLayer = CALayer()
//        blackLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
//        blackLayer.backgroundColor = UIColor.clear.cgColor
//
//        let imageLayer = CALayer()
//        imageLayer.frame = CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
//        imageLayer.backgroundColor = UIColor.clear.cgColor
//        imageLayer.contents = image.cgImage
//
//        let gifLayer = CALayer()
//        gifLayer.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
//        gifLayer.backgroundColor = UIColor.clear.cgColor
//        gifLayer.add(gifAnimation!, forKey: "basic")
//        imageLayer.addSublayer(gifLayer)
//
//        blackLayer.addSublayer(imageLayer)
//        parentlayer.addSublayer(blackLayer)
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        let layercomposition = AVMutableVideoComposition()
    
        layercomposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        layercomposition.renderSize = videoSize
       // layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.backgroundColor = UIColor.clear.cgColor
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
        
        let videotrack = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
        
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        
        ///
        let videotrack1 = composition.tracks(withMediaType: AVMediaType.video)[1] as AVAssetTrack
        
        let layerinstruction1 = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack1)
        
        instruction.layerInstructions = [layerinstruction, layerinstruction1]
        
        layercomposition.instructions = [instruction]
        
        let animatedVideoURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/video2.mp4")
        removeFileAtURLIfExists(url: animatedVideoURL)
        
        guard let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality) else {return}
        assetExport.videoComposition = layercomposition
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = animatedVideoURL as URL
        assetExport.exportAsynchronously(completionHandler: {
            switch assetExport.status{
            case AVAssetExportSession.Status.completed:
                DispatchQueue.main.async {
                    self.play(url: assetExport.outputURL!)
                    print("URL  :  ", assetExport.outputURL!)
                }
            case  AVAssetExportSessionStatus.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("Exported")
            }
        })
    }
    
    
    func removeFileAtURLIfExists(url: NSURL) {
        if let filePath = url.path {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                do{
                    try fileManager.removeItem(atPath: filePath)
                } catch let error as NSError {
                    print("Couldn't remove existing destination file: \(error)")
                }
            }
        }
    }
    
    func play(url: URL){
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.topView.bounds
        self.topView.layer.addSublayer(playerLayer)
        player.play()
    }
}
