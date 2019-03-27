//
//  StreamDisplayViewCell.swift
//  DFP Integration Demo
//
//  Created by Isaiah Mann on 3/20/19.
//  Copyright © 2019 true[X]. All rights reserved.
//

import UIKit

protocol StreamDisplayViewCellDelegate {
    func setFocusedStream(_ configuration : StreamConfiguration)
}

class StreamDisplayViewCell : UICollectionViewCell {
    private let scaleFactor : CGFloat = 1.2
    private let overlayColor : UIColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.75)
    
    private var configuration : StreamConfiguration?
    
    private var cover : UIImageView
    private var overlay : UIImageView
    private var delegate : StreamDisplayViewCellDelegate?
    
    required init?(coder decoder: NSCoder) {
        cover = UIImageView()
        overlay = UIImageView()
        cover.contentMode = .scaleAspectFill
        overlay.contentMode = .scaleAspectFill
        super.init(coder:decoder)
        
        cover.frame = frame
        overlay.frame = frame
        addSubview(cover)
        addSubview(overlay)
    }
    
    func setConfiguration(_ configuration : StreamConfiguration, delegate : StreamDisplayViewCellDelegate) {
        self.configuration = configuration
        self.delegate = delegate
        if let url = URL(string: configuration.cover), let data = try? Data(contentsOf: url) {
            cover.image = UIImage(data: data)
            overlay.image = cover.image?.withRenderingMode(.alwaysTemplate)
            cover.frame = frame
            overlay.frame = frame
            overlay.tintColor = overlayColor
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            if let configuration = configuration {
                delegate?.setFocusedStream(configuration)
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.frame = CGRect(x: self.frame.minX,
                                    y: self.frame.minY / (self.scaleFactor * 1.5),
                                    width: self.frame.width * self.scaleFactor,
                                    height: self.frame.height * self.scaleFactor)
                self.cover.frame = self.frame
                self.overlay.frame = self.frame
                self.overlay.tintColor = .clear
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.frame = CGRect(x: self.frame.minX,
                                    y: self.frame.minY * (self.scaleFactor * 1.5),
                                    width: self.frame.width / self.scaleFactor,
                                    height: self.frame.height / self.scaleFactor)
                self.cover.frame = self.frame
                self.overlay.frame = self.frame
                self.overlay.tintColor = self.overlayColor
            }, completion: nil)
        }
    }
}
