//
//  ChatPhoto.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/7/8.
//

import UIKit

@objcMembers final public class PreviewImage: NSObject {
    public var image: UIImage?
    public var urlString: String?
    public var placeholderImage : UIImage?
    public var originalView: UIImageView?
    
    public init(image: UIImage, originalView: UIImageView? = nil) {
        super.init()
        self.image = image
        self.originalView = originalView
    }
    
    public init(urlString: String, placeholderImage: UIImage? = nil, originalView: UIImageView? = nil) {
        super.init()
        self.urlString = urlString
        self.placeholderImage = placeholderImage
        self.originalView = originalView
    }
}

@objc public protocol ImageBrowserProtocol {
    
    //需要显示图片的数量
    func numberOfPhotos(with browser: ImagePreviewController) -> Int
    //序号对应显示的图片
    func photo(of index: Int, with browser: ImagePreviewController) -> PreviewImage
    
    //当前显示的图片序号
    @objc optional func didDisplayPhoto(at index: Int, with browser: ImagePreviewController) -> Void
    //长按序号为index的图片，可以自己在这里添加一些菜单操作
    @objc optional func didLongPressPhoto(at index: Int, with browser: ImagePreviewController) -> Void
    
}
