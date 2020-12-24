//
//  MediaGalleryVC.swift
//  SwiftyMediaGallery
//
//  Created by nati on 14/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit
import CombineDataSources
import Combine

public final class MediaGalleryVC: UIViewController {
    
    private var shouldTrack = true
    private var currentIndex: CurrentValueSubject <IndexPath, Never>?

    @IBOutlet var btnShare: UIButton!
    @IBOutlet weak var cvMediaThumbs: UICollectionView!
    @IBOutlet var cvMediaView: UICollectionView!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var vbottom: UIView!
    @IBOutlet var vNoPhotos: UIStackView!
    private var subscriptions = [AnyCancellable]()
    private var viewDidAppear = false;
    private var viewModel: MediaControllerViewModel!
    private lazy var transitionController:ZoomTransitionController = ZoomTransitionController()
    private var currentImage = UIImageView()
    private var previousTitle : String?
    
    private var visibleCell :MediaViewCell?{
        return cvMediaView.visibleCells.first as? MediaViewCell
    }
    private var visibleCellIndex :IndexPath?{
        guard let visibleCell = visibleCell else {
            return nil
        }
        return cvMediaView.indexPath(for: visibleCell)
    }
    
    public class func initVC(array: CurrentValueSubject<[AnyMediaItem],Never>, currentIndex: CurrentValueSubject <IndexPath, Never>? = nil) -> MediaGalleryVC {
        let vc = Utils.galleryStoryboard().instantiateViewController(withIdentifier: "MediaGalleryVC") as! MediaGalleryVC
        let model = MediaControllerViewModel(arrMediaItems: array)

        vc.viewModel = model
        vc.currentIndex = currentIndex
        return vc
    }
    
    public func setTransitionConfiguration(from:UIViewController,referenceImageView:@escaping ReferenceImageView,referenceImageViewFrameInTransitioningView:@escaping ReferenceImageViewFrame){
        from.navigationController?.delegate = transitionController
        let to = ZoomAnimatorRreferences(referenceImageView: {[weak self] () -> UIImageView in
            return self!.currentImage
        }) { [weak self] () -> CGRect in
            guard let self = self , let imgview = self.visibleCell?.imgPic else {return CGRect(x: 0, y: 0, width: 350, height: 600)}
            return self.cvMediaView.convert(imgview.frame, to: self.cvMediaView)
        }
        transitionController.to = to
        let from = ZoomAnimatorRreferences(referenceImageView: referenceImageView, referenceImageViewFrameInTransitioningView: referenceImageViewFrameInTransitioningView)
        transitionController.to = to
        transitionController.from = from
    }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = GalleryConfiguration.shared.title
        navigationController?.delegate = transitionController
        view.backgroundColor = GalleryConfiguration.shared.backgroundColor;
        vbottom.backgroundColor = GalleryConfiguration.shared.backgroundColor;
        configureCollectaionView()
        bindMedia();
//        btnPlay.setImage(GalleryConfiguration.shared.playImage, for: .normal)
//        btnPlay.setImage(GalleryConfiguration.shared.pauseImage, for: .selected)
        Utils.setAudioSession(withSpeaker: true)
        previousTitle = navigationController?.navigationBar.topItem?.title
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = ""
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true;
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewDidAppear = false;
        if let idx = visibleCellIndex{
            currentIndex?.send(idx)
        }
        navigationController?.navigationBar.topItem?.title = previousTitle
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.none
    }

    private func configureCollectaionView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideThumbsAndBars))
        tap.cancelsTouchesInView = false
        cvMediaView.addGestureRecognizer(tap)
        cvMediaView.delegate = self
        cvMediaThumbs.delegate = self;
        cvMediaThumbs.prefetchDataSource = self;
        
        cvMediaView.contentInsetAdjustmentBehavior = .never;

        let sideInset = (view.width - cvMediaThumbs.height + 22 ) / 2
        let collectionViewLayout = cvMediaThumbs.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets(top: 1, left: sideInset, bottom: 1, right:sideInset )
        collectionViewLayout?.invalidateLayout()

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            cvMediaView.isScrollEnabled = false
            cvMediaThumbs.isScrollEnabled = false
            transitionController.isInteractive = true
            visibleCell?.finishVideo()
            btnPlay.isSelected = false
            let _ = navigationController?.popViewController(animated: true)
        case .ended:
            if transitionController.isInteractive {
                cvMediaView.isScrollEnabled = true
                cvMediaThumbs.isScrollEnabled = true
                transitionController.isInteractive = false
                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if transitionController.isInteractive {
                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
    
    @objc private func hideThumbsAndBars()  {
        vbottom.isHidden = !vbottom.isHidden
        navigationController?.setNavigationBarHidden(vbottom.isHidden, animated: false)
        view.backgroundColor = vbottom.isHidden ? UIColor.black : GalleryConfiguration.shared.backgroundColor
        if let cell = visibleCell,vbottom.isHidden{
            cell.vTrackVideoPlaying.isHidden = true
        }
    }
    
    @IBAction private func deleteItem(_ sender: Any) {
        if let idx = visibleCellIndex {
            viewModel.deleteMedia(idx: idx)
        }
    }
    
    @IBAction private func buttonShare(_ sender: Any) {
        if let idx = visibleCellIndex {
            viewModel.shareMedia(idx: idx)
        }
    }
    
    @IBAction private func playPauseVideo(_ sender: UIButton) {
        if let cell = visibleCell{
            cell.playPause()
            sender.isSelected = !sender.isSelected
        }
    }
    
    private func bindMedia()
    {
        viewModel.arrMediaItems.receive(on:DispatchQueue.main).bind(subscriber: cvMediaThumbs.itemsSubscriber(cellIdentifier: "MediaThumbCell", cellType: MediaThumbCell.self, cellConfig: { cell, indexPath, media in
            cell.setup(media: media)
        }))
        .store(in: &subscriptions)
        
        viewModel.arrMediaItems.receive(on: DispatchQueue.main).bind(subscriber: cvMediaView.itemsSubscriber(cellIdentifier: "MediaViewCell", cellType: MediaViewCell.self, cellConfig: { cell, indexPath, media in
             cell.setup(item: media)
        }))
        .store(in: &subscriptions)
        
        viewModel.arrMediaItems.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] (arr) in
            self?.vNoPhotos.isHidden = !arr.isEmpty
        })
        .store(in: &subscriptions)
    }

    func scrollToPic(idx: IndexPath){
        DispatchQueue.main.async {[weak self] in
            self?.cvMediaView.scrollToItem(at: idx, at:.centeredHorizontally, animated: false)

        }
    }
}

extension MediaGalleryVC: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItemsAt(indexPaths: indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        viewModel.cancelPrefetching(indexPaths: indexPaths)
    }
}

extension MediaGalleryVC: UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MediaViewCell{
            let item  = viewModel.getMediaItem(idx: indexPath)
            btnPlay.isHidden = item.type == .image
            currentImage = cell.imgPic
            if let idx = currentIndex?.value, indexPath != idx , !viewDidAppear{
                scrollToPic(idx: idx)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvMediaThumbs{
            shouldTrack = false
            DispatchQueue.main.async {[weak self] in
                self?.cvMediaView.scrollToItem(at: indexPath, at:.centeredHorizontally, animated: false)
            }
            DispatchQueue.main.async {[weak self] in
                UIView.animate(withDuration: 0.0, animations: {
                    self?.cvMediaThumbs.scrollToItem(at: indexPath, at:.centeredHorizontally, animated: true)
                }) { (finished) in
                    if finished{
                        self?.cvMediaThumbs.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView === cvMediaView{
            if let cell = cell as? MediaViewCell{
                cell.finishVideo()
                btnPlay.isSelected = false
            }
        }
    }    
}

extension MediaGalleryVC:UIGestureRecognizerDelegate{
    
}

extension MediaGalleryVC: UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === cvMediaThumbs{
            var width = cvMediaThumbs.height - 22
            if let idx = visibleCellIndex, indexPath.item == idx.item {
                width = cvMediaThumbs.height + 14;
            }
            return CGSize(width:width , height: cvMediaThumbs.height - 2)
        }else{
            return CGSize(width:view.width, height: cvMediaView.height)
        }
    }
}

extension MediaGalleryVC: UIScrollViewDelegate
{
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let indexPath = visibleCellIndex,!decelerate{
            cvMediaThumbs.reloadItems(at: [indexPath])
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === cvMediaView{
            trackCollection(from: cvMediaView, to: cvMediaThumbs)
        }
        if scrollView === cvMediaThumbs {
            trackCollection(from: cvMediaThumbs, to: cvMediaView)
        }
    }
    
    private func trackCollection(from:UICollectionView, to : UICollectionView){
        let center = CGPoint(x: from.contentOffset.x + (from.frame.width / 2), y: (from.frame.height / 2))

        if shouldTrack{
            if let indexPath = from.indexPathForItem(at: center) {
                shouldTrack = false
                UIView.animate(withDuration: 0.0, animations: {
                    DispatchQueue.main.async {
                        to.scrollToItem(at: indexPath, at:.centeredHorizontally, animated: false)
                    }
                }) { (finished) in
                    self.shouldTrack = finished
                }
            }
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        shouldTrack = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPath = visibleCellIndex{
            cvMediaThumbs.reloadItems(at: [indexPath])
        }
    }
    
}
