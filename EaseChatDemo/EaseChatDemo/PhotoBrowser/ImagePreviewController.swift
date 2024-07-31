//
//  ImagePreviewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/7/8.
//

import UIKit
import EaseChatUIKit

public class ImagePreviewController: UIViewController {

    private var cache = Dictionary<Int, PreviewImage>.init(minimumCapacity: 20)
    
    public weak var delegate: ImageBrowserProtocol!
    public var presentDuration: TimeInterval = 0.3          //显示动画时间
    public var dissmissDuration: TimeInterval = 0.3         //隐藏动画时间
    public var selectedIndex = 0                            //当前显示图片的序号
    var collectionView: UICollectionView!
    public var pageControl: UIPageControl!
    private let transDelegate = ImagePreviewTransitionDelegate()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(with delegate: ImageBrowserProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.transitioningDelegate = transDelegate
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.clipsToBounds = true
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = UIScreen.main.bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        var frame = UIScreen.main.bounds
        frame.size.width += 10.0
        collectionView = UICollectionView.init(frame: frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 10.0)
        collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .normal
        self.view.addSubview(collectionView)
        collectionView.selectItem(at: IndexPath.init(item: selectedIndex, section: 0), animated: false, scrollPosition: .left)
        
        pageControl = UIPageControl.init(frame: CGRect.init(x: 0, y: ScreenHeight - 30, width: ScreenWidth, height: 20))
        pageControl.numberOfPages = self.delegate.numberOfPhotos(with: self)
        pageControl.currentPage = selectedIndex
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
        pageControl.isHidden = delegate.numberOfPhotos(with: self) == 1
        
    }
    
    deinit {
    }
    

    
    @objc func disAction() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ImagePreviewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate.numberOfPhotos(with: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var photo = cache[indexPath.item]
        if photo == nil {
            photo = self.delegate.photo(of: indexPath.item, with: self)
            cache[indexPath.item] = photo
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImagePreviewCell
        cell.setPhoto(photo: photo)
        cell.index = indexPath.item
        cell.browser = self
        return cell
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let page = Int(scrollView.contentOffset.x / (ScreenWidth + 10))
        pageControl.currentPage = page
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / (ScreenWidth + 10))
        selectedIndex = page
        pageControl.currentPage = selectedIndex
        delegate.didDisplayPhoto?(at: page, with: self)
        
    }

}

