//
//  ExampleVC.swift
//  SwiftyMediaGallery
//
//  Created by nati on 29/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit
import Combine
import CombineDataSources
import SwiftyMediaGallery

class ExampleNavigationVC: UINavigationController {
    
    class func getVC() -> ExampleNavigationVC {
        let storyboard = UIStoryboard(name: "Example", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ExampleNavigationVC") as! ExampleNavigationVC
        return vc
    }
}

class ExampleVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    let arrMediaItems = CurrentValueSubject <[AnyMediaItem], Never>([AnyMediaItem]())
    private let currentIndex = CurrentValueSubject <IndexPath, Never>(IndexPath(row: 0, section: 0))
    private var subscriptions = [AnyCancellable]()
    private var currentCell : ExampleMediaCell?{
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        return collectionView.cellForItem(at: self.currentIndex.value) as? ExampleMediaCell
    }
    
    override func loadView() {
        super.loadView()
        getPicturesRemote()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind();
    }
    
    private func bind(){
        currentIndex.sink {[weak self] (index) in
            guard let self = self, self.collectionView.visibleCells.count > 0 else {return}
            self.collectionView.scrollToItem(at: index,at:.centeredVertically, animated: false)
        }.store(in: &subscriptions)
        
        arrMediaItems.receive(on: DispatchQueue.main).bind(subscriber: collectionView.itemsSubscriber(cellIdentifier: "ExampleMediaCell", cellType: ExampleMediaCell.self, cellConfig: { cell, indexPath, media in
            cell.img.set(image: media.url)
        })).store(in: &subscriptions)
    }
    
    func getPicturesRemote(){
        var arr = [AnyMediaItem]()
        let urls = Mock.urls.split(separator: ",").compactMap{URL(string: String($0))}
        urls.forEach { (url) in
            if url.isVideo{
                let video = AnyMediaItem(VideoMediaItem(url: url.absoluteString))
                arr.append(video)
            }else{
                let image = AnyMediaItem(ImageMediaItem(url: url.absoluteString))
                arr.append(image)
            }
            if arr.count == urls.count{
                self.arrMediaItems.send(arr)
            }
        }
        
        GalleryConfiguration.shared.onDelete { (item) in
            //do delete;
        }
        
    }
    
    func pushSwiftyMediaGallery(){
        let viewController = MediaGalleryVC.initVC(array: arrMediaItems, currentIndex: currentIndex)
        viewController.setTransitionConfiguration(from: self, referenceImageView: {[unowned self] in
            return self.currentCell!.img
        }, referenceImageViewFrameInTransitioningView: { [unowned self] in
            return self.collectionView.convert(self.currentCell?.frame ?? self.view.frame, to: self.view)
        })
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ExampleVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex.send(indexPath)
        pushSwiftyMediaGallery()
    }
}

extension ExampleVC: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.width / 3)
        return CGSize(width:width , height:width)
    }
}

