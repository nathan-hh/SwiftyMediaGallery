# SwiftyMediaGallery

[![CI Status](https://img.shields.io/travis/nathan-hh/SwiftyMediaGallery.svg?style=flat)](https://travis-ci.org/nathan-hh/SwiftyMediaGallery)
[![Version](https://img.shields.io/cocoapods/v/SwiftyMediaGallery.svg?style=flat)](https://cocoapods.org/pods/SwiftyMediaGallery)
[![License](https://img.shields.io/cocoapods/l/SwiftyMediaGallery.svg?style=flat)](https://cocoapods.org/pods/SwiftyMediaGallery)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyMediaGallery.svg?style=flat)](https://cocoapods.org/pods/SwiftyMediaGallery)
![Swift](https://img.shields.io/badge/%20in-swift%205.0-orange.svg)

## Demo
![](https://raw.githubusercontent.com/nathan-hh/SwiftyMediaGallery/master/images/example4.gif)
![](https://raw.githubusercontent.com/nathan-hh/SwiftyMediaGallery/master/images/example1.gif)
![](https://raw.githubusercontent.com/nathan-hh/SwiftyMediaGallery/master/images/example3.gif)

## Requirements
- [X] 📱 iOS 13 or later

## Table of Contents

- [Description](#description)
- [Usage](#usage)
  - [Advanced](#advanced)
  - [Configuration](#configuration)
  - [Pre-fetching](#pre-fetching)
- [Installation](#installation)

## Description

Showing images and videos in an application is a requirement these days in many apps,
after strageling finding a good library who do it same as the native iOS gallery i've decided to come with a solution myself and help others.
with `SwiftyMediaGallery` it is very easy to implement.
The library comes with flexible public API based POP (Protocol Oriented Proggraming) and
a bunch of built-in features:

- [x] Asynchronous images downloading
- [x] Automatic reprioritizing images downloading - last requests will be on higher so user will wait less
- [x] Rendering and decoding images on the global thread (default iOS do it on the Main)
- [x] Automatic disk / Memory cache
- [x] Navigation Image Transition animation
- [x] Follow back current image index
- [x] Supports images / videos
- [x] Automatic generating videos tumbnails if needed

## Usage

Using 'Combine' library you just need to pass CurrentValueSubject array of AnyMediaItem and init controller with the model
```swift
import Combine

let arrMediaItems = CurrentValueSubject <[AnyMediaItem], Never>([AnyMediaItem]())
let currentIndex = CurrentValueSubject <Int, Never>(0)
let viewController = MediaGalleryVC.initVC(array: arrMediaItems, currentIndex: currentIndex)
```
Create type-erasing items by using wrapper 'AnyMediaItem' and append to an array
```swift
let imageItem = ImageMediaItem(url: url.absoluteString)
let videoItem = VideoMediaItem(url: url.absoluteString)
let arr : [AnyMediaItem] = [AnyMediaItem(imageItem),AnyMediaItem(videoItem)]
```
Then update CurrentValueSubject Array
```swift
arrMediaItems.send(arr)
```
#### Use placeholder

Placeholder is optional if you want the user to see something while images are being fetched.

```swift
let placeholderVideo = UIImage(named: "PlaceholderImage")
let placeholderImage = UIImage(named: "PlaceholderVideo")

Configuration.shared.videoPlaceholder = placeholderVideo
Configuration.shared.imagePlaceholder = placeholderImage
```

## Advanced
### Set Navigation Image Transition

```swift
viewController.setTransitionConfiguration(from: self, referenceImageView: {[weak self] in
        return self!.currentImage
    }, referenceImageViewFrameInTransitioningView: { [weak self] in
        self!.view.layoutIfNeeded()
        return self!.view.convert(self!.currentImage.frame, to: self!.view)
})
navigationController?.pushViewController(viewController, animated: true)
```
### Set-UIImageView
You can enjoy the benefit of the library to set your on UIImageView and have auto downloading and caching
```swift
yourImageView.set(image: url, withIndicator: false) //deafult with activity indicator
```
### Pre-fetching
Manually pre-fetch urls
```swift
Prefetcher.startFetching(urls:urls)
Prefetcher.cancelFetching(urls:urls)
```
### Caching
Set options saveToDisk / saveToMemory / clearOnMemoryWarning 
```swift
Configuration.shared.cacheOptions = [.clearOnMemoryWarning,.saveToDisk,.saveToMemory] // default is all
```
```swift
Configuration.shared.diskCacheMB = 300  // default is 200
```
You can get the current MB used by the disk cache
```swift
print(Configuration.shared.diskCacheMB)
```
### Image rendering max size
You can set it low to save memory and disk cache
```swift
Configuration.shared.imageRendererMaxSize = CGSize(width: 2400,height: 2400)  // default is   1200*1200
```
### Show items from a specific index 
for example gallery jump and show from 10th picture index

just update currentIndex
```swift
currentIndex.send(10)
```
You can also follow back the index to the original View Controller 
```swift
private var subscriptions = [AnyCancellable]()

currentIndex.sink { (index) in
    //update VC
}.store(in: &subscriptions)
```
## Configuration
Set gallery navigation title and backgroundColor
```swift
Configuration.shared.title = "Best Gallery"
Configuration.shared.backgroundColor = .white 
```
Configure actions when delete/share button was clicked
```swift
GalleryConfiguration.shared.onDelete { (item) in
    deleteItem(id: item.id)
}
```
```swift
GalleryConfiguration.shared.onShare { (item) in
    shareItem(id: item.id)
}
```
## Installation
### CocoaPods
SwiftyMediaGallery is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftyMediaGallery'
```
### Swift Package Manager
You can also use Swift Package Manager to add SwiftyMediaGallery as a dependency to your project. In order to do so, use the following URL:
```bash
https://github.com/nathan-hh/SwiftyMediaGallery.git
```
## Author

nathan-hh, fdg

## License

SwiftyMediaGallery is available under the MIT license. See the LICENSE file for more info.
