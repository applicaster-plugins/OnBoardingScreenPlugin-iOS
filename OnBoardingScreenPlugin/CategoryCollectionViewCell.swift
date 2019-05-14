//
//  CategoryCollectionViewCell.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var categoryLabel: UILabel!
    
    var isCurrentlySelected: Bool = false
    var langCode: String?
    var category: Category? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleUI()
    }
    
    override func prepareForReuse() {
        categoryLabel.text = ""
        setUnselectedStyle()
    }
    
    private func styleUI() {
        containerView.layer.cornerRadius = 3
        containerView.clipsToBounds = true
        setUnselectedStyle()
    }

    private func updateUI() {
        guard let category = category, let titleDict = category.title, let langCode = langCode else { return }
        categoryLabel.text = titleDict["\(langCode)"]?.string ?? ""
        categoryImageView.sd_setImage(with: URL(string: "\(category.imageUrl ?? "")"), placeholderImage: UIImage(named: "ob_category_placeHolder"))
        
        if isCurrentlySelected {
            setSelectedStyle()
        } else {
            setUnselectedStyle()
        }
    }
    
    private func setSelectedStyle() {
        guard let styles = OnBoardingManager.sharedInstance.styles else { return }
        if let highlightColor = styles["highlightColor"] as? String {
            containerView.backgroundColor = UIColor(hex: highlightColor)
        }
        if let backgroundColor = styles["backgroundColor"] as? String {
            categoryLabel.textColor = UIColor(hex: backgroundColor)
        }
    }
    
    private func setUnselectedStyle() {
        guard let styles = OnBoardingManager.sharedInstance.styles else { return }
        if let titleColor = styles["titleColor"] as? String {
            categoryLabel.textColor = UIColor(hex: titleColor).withAlphaComponent(0.8)
        }
        if let categoryBackgroundColor = styles["categoryBackgroundColor"] as? String {
            containerView.backgroundColor = UIColor(hex: categoryBackgroundColor)
        }
    }
}
