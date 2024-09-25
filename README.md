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

'SwiftyMediaGallery' is a powerful library specifically designed to streamline the process of displaying online images and videos within your applications. This library is engineered to handle the complexities of managing online media. In the modern era, the inclusion of multimedia elements in applications is almost a necessity, and SwiftyMediaGallery aims to make this process as seamless as possible.

I developed this library after noticing a lack of satisfactory libraries that could mimic the functionality of the native iOS gallery. SwiftyMediaGallery not only fills this gap but also offers an easy-to-implement solution for developers.
Unlike the native iOS gallery, which is primarily used for displaying locally stored media, SwiftyMediaGallery stands out by providing functionality for both local and online media. It offers developers a streamlined process for fetching and displaying media content from online sources, alongside the ability to handle locally stored media.

The library is built with Protocol Oriented Programming (POP) principles, providing a flexible, public API. It comes loaded with several built-in features, such as automatic reprioritization of image downloads to reduce user wait time, and offloading image rendering and decoding to a global thread, which contrasts with the main thread used by default iOS.

features:

- [x] Asynchronous image downloading
- [x] Automatic reprioritizing images downloading - last requests will be higher so a user will wait less
- [x] Rendering and decoding images on the global thread (default iOS do it on the Main)
- [x] Automatic disk / Memory cache
- [x] Navigation Image Transition animation
- [x] Follow back current image index
- [x] Supports images/videos
- [x] Automatic generating videos thumbnails if needed

## Usage

Using 'Combine' library you just need to pass CurrentValueSubject array of AnyMediaItem and init controller with the model
```swift
import Combine

let arrMediaItems = CurrentValueSubject <[AnyMediaItem], Never>([AnyMediaItem]())
let currentIndex = CurrentValueSubject <Int, Never>(0)
let viewController = MediaGalleryVC.initVC(array: arrMediaItems, currentIndex: currentIndex)
```
Create type-erasing items by using the wrapper 'AnyMediaItem' and append to an array
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
SwiftyMediaGallery is available under the [NON-AI-MIT license]([https://cocoapods.org](https://github.com/non-ai-licenses/non-ai-licenses/blob/main/NON-AI-MIT)). See the LICENSE file for more info.
