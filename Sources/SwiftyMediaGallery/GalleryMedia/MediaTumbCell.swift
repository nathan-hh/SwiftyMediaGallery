//
//  MediaViewCell.swift
//  SwiftyMediaGallery
//
//  Created by nati on 14/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit

class MediaThumbCell: UICollectionViewCell {
    @IBOutlet weak var imgPic: UIImageView!
    private var item : AnyMediaItem!;

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup(media: AnyMediaItem){
        item = media
        updateImage();
    }
    
    func updateImage(){
        switch item.type {
        case .image:
            let url = item.thumbUrl ?? item.url
            if let url = url , !url.isEmpty  {
                imgPic.set(image: url, withIndicator: false)
            }
        case .video:
            if let url = item.url , !url.isEmpty  {
                imgPic.set(image: url, withIndicator: false)
            }
        }
    }
}
