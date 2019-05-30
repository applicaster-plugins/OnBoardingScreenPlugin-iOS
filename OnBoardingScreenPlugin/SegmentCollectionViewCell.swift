//
//  SegmentCollectionViewCell.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/4/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class SegmentCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var selectSegmentIconBgView: UIView!
    @IBOutlet var selectSegmentIconImageView: UIImageView!
    @IBOutlet var segmentImageView: UIImageView!
    
    var isCurrentlySelected: Bool = false
    var segment: Segment? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleUI()
    }
    
    override func prepareForReuse() {
        isCurrentlySelected = false

        var placeHolderImage = UIImage(named: "ob_16_9_vertical_placeholder")
        if placeHolderImage == nil {
            if let path = Bundle(for: self.classForCoder).path(forResource: "ob_16_9_vertical_placeholder", ofType: "png") {
                placeHolderImage = UIImage(contentsOfFile: path)
            }
        }
        segmentImageView.image = placeHolderImage
        segmentImageView.contentMode = .scaleAspectFill
        containerView.layer.borderWidth = 0.0
        containerView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func styleUI() {
        containerView.layer.cornerRadius = 3
        containerView.clipsToBounds = true
        selectSegmentIconBgView.layer.cornerRadius = selectSegmentIconBgView.frame.height/2
        selectSegmentIconBgView.clipsToBounds = true
        setUnselectedStyle()
    }
    
    func animateSelectionSegmentImageView(addBorder: Bool) {
        UIView.animate(withDuration: 0.10,
           animations: { [weak self] in
            self?.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            },
           completion: { _ in
            UIView.animate(withDuration: 0.20,
                           delay: 0.0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 6,
                           options: .curveLinear,
                           animations: {
                            self.containerView.transform = CGAffineTransform.identity
                            if addBorder {
                                self.setSelectedStyle()
                            } else {
                                self.setUnselectedStyle()
                            }
            }, completion: nil)
        })
    }
    
    private func updateUI() {
        guard let segment = segment else { return }
        
        var placeHolderImage = UIImage(named: "ob_16_9_vertical_placeholder")
        if placeHolderImage == nil {
            if let path = Bundle(for: self.classForCoder).path(forResource: "ob_16_9_vertical_placeholder", ofType: "png") {
                placeHolderImage = UIImage(contentsOfFile: path)
            }
        }
        segmentImageView.sd_setImage(with: URL(string: "\(segment.imageUrl ?? "")"), placeholderImage: placeHolderImage)
        setOBLikeIcon(selected: false)
        
        if isCurrentlySelected {
            setSelectedStyle()
        } else {
            setUnselectedStyle()
        }
    }
    
    private func setSelectedStyle() {
        guard let styles = OnBoardingManager.sharedInstance.styles else { return }
        setOBLikeIcon(selected: true)
        
        var highlightColor: UIColor = UIColor.clear
        
        if let color = styles["highlightColor"] as? String {
            highlightColor = UIColor(hex: color)
            containerView.layer.borderColor = highlightColor.cgColor
        }
        
        if let applyBorder = styles["applyBorder"] as? Bool, applyBorder {
            containerView.layer.borderWidth = 1.0
        }
    }
    
    private func setUnselectedStyle() {
        containerView.layer.borderWidth = 0.0
        containerView.layer.borderColor = UIColor.clear.cgColor
        setOBLikeIcon(selected: false)
        
        guard let styles = OnBoardingManager.sharedInstance.styles else { return }
        if let backgroundColor = styles["backgroundColor"] as? String {
            selectSegmentIconBgView.backgroundColor = UIColor(hex: backgroundColor).withAlphaComponent(0.4)
        }
    }
    
    private func setOBLikeIcon(selected: Bool) {
        let obIconFilename: String = selected ? "ob_like_icon_selected" : "ob_like_icon_unselected"
        
        //if custom image was uploaded, it will be in Resources folder, if not, load resource from plugin files
        let obLikeIconUnselected = UIImage(named: obIconFilename)
        if obLikeIconUnselected != nil {
            selectSegmentIconImageView.image = UIImage(named: obIconFilename)
        } else if let path = Bundle(for: self.classForCoder).path(forResource: obIconFilename, ofType: "png") {
            selectSegmentIconImageView.image = UIImage(contentsOfFile: path)
        }
    }
}

