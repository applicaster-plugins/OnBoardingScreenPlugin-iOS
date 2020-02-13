//
//  OnBoardingOneStepViewController.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OnBoardingOneStepViewController: UIViewController {
    @IBOutlet var topTitleLabel: UILabel!
    @IBOutlet var hightlightTitleLabel: UILabel!
    @IBOutlet var titleDividerView: UIView!
    @IBOutlet var categoryCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var segmentsCollectionView: UICollectionView!
    @IBOutlet var nextStepButtonView: UIView!
    @IBOutlet var nextStepButton: UIButton!
    
    let bag = DisposeBag()
    var viewModel: OnBoardingViewModel?
    private var finishedLoadingInitialCells = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
        subscribe()
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        segmentsCollectionView.delegate = self
        segmentsCollectionView.dataSource = self
        categoryCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        segmentsCollectionView.register(UINib(nibName: "SegmentCollectionViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "SegmentCollectionViewCell")
        
        if let viewModel = viewModel {
            viewModel.fetch()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    private func styleUI() {
        topTitleLabel.text = ""
        hightlightTitleLabel.text = ""
        nextStepButton.setTitle("", for: .normal)
        
        //Apply transparent gradient to nextStepButton view
        let gradient = CAGradientLayer()
        gradient.frame = nextStepButtonView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 0.3]
        nextStepButtonView.layer.mask = gradient
        
        //round corners
        nextStepButton.layer.cornerRadius = 13.0
        nextStepButton.clipsToBounds = true
        
        guard let styles = OnBoardingManager.sharedInstance.styles else { return }
        if let backgroundColor = styles["backgroundColor"] as? String {
            self.view.backgroundColor = UIColor.init(argbHexString: backgroundColor)
            nextStepButtonView.backgroundColor = UIColor.init(argbHexString: backgroundColor)
            nextStepButton.setTitleColor(UIColor.init(argbHexString: backgroundColor), for: .normal)
        }
        if let highlightColor = styles["highlightColor"] as? String {
            hightlightTitleLabel.textColor = UIColor.init(argbHexString: highlightColor)
            nextStepButton.backgroundColor = UIColor.init(argbHexString: highlightColor)
        }
        if let titleColor = styles["titleColor"] as? String {
            topTitleLabel.textColor = UIColor.init(argbHexString: titleColor)
            titleDividerView.backgroundColor = UIColor.init(argbHexString: titleColor).withAlphaComponent(0.5)
        }
    }
    
    private func subscribe() {
        viewModel?.categories.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.showHideCategoryCollection()
                self?.categoryCollectionView.reloadData()
                self?.segmentsCollectionView.reloadData()
                self?.setActionButtonTitle()
            })
            .disposed(by: bag)
        
        viewModel?.categorySelectedIndex.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.categoryCollectionView.reloadData()
                self?.segmentsCollectionView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel?.onboardingTexts.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.setOnboardingTexts()
            })
            .disposed(by: bag)
        
        viewModel?.segmentsSelected.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.setActionButtonTitle()
            })
            .disposed(by: bag)
        
        nextStepButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.processSelectedTags()
            }).disposed(by: bag)
        
        viewModel?.completedProcessingTags.asObservable()
            .subscribe(onNext: { [weak self] completedProcessingTags in
                if completedProcessingTags {
                    self?.dismissOnBoardingVC()
                }
                }, onError: { [weak self] _ in
                    self?.dismissOnBoardingVC()
            }).disposed(by: bag)
        
        viewModel?.shouldRefresh.asObservable()
            .subscribe(onNext: { [weak self] shouldRefresh in
                if shouldRefresh {
                    self?.categoryCollectionView.reloadData()
                    self?.segmentsCollectionView.reloadData()
                }
            })
            .disposed(by: bag)
    }
    
    private func setOnboardingTexts() {
        guard let viewModel = viewModel else { return }
        let titleTxt = viewModel.onboardingTexts.value["title"]?.dictionary?["\(viewModel.languageCodeToUse())"]?.string ?? ""
        let subtitleTxt = viewModel.onboardingTexts.value["subtitle"]?.dictionary?["\(viewModel.languageCodeToUse())"]?.string ?? ""
        
        topTitleLabel.text = titleTxt
        hightlightTitleLabel.text = subtitleTxt
    }
    
    private func setActionButtonTitle() {
        guard let viewModel = self.viewModel else { return }
        let chooseLaterTxt = viewModel.onboardingTexts.value["skipOnboarding"]?.dictionary?["\(viewModel.languageCodeToUse())"]?.string ?? ""
        let finishTxt = viewModel.onboardingTexts.value["finishOnboarding"]?.dictionary?["\(viewModel.languageCodeToUse())"]?.string ?? ""
        
        let buttonTextToSet = (viewModel.segmentsSelected.value.count > 0) ? finishTxt : chooseLaterTxt
        nextStepButton.setTitle(buttonTextToSet, for: .normal)
    }
    
    private func showHideCategoryCollection() {
        guard let viewModel = viewModel else { return }
        categoryCollectionHeightConstraint.constant = viewModel.shouldHideCategoryCollection() ? 10 : 60
        categoryCollectionView.isHidden = viewModel.shouldHideCategoryCollection() ? true : false
    }
    
    private func getCategoryCellWidthtForItemAt(indexPath: IndexPath) -> CGFloat {
        guard let viewModel = viewModel else { return 0.0 }
        guard let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return 0.0 }
        guard let category = viewModel.categories.value[safe: indexPath.item], let categoryTitle = category.title else { return 0.0 }
        var cellWidth: CGFloat = 10.0
        
        //54.0 is the width taken by all the elements except the label in the cell
        let widthTakenByOtherElements: CGFloat = 54.0
        let labelFont = cell.categoryLabel.font
        
        //using the category title, calculate the width the UILabel should take based on the current font
        let langCode = viewModel.languageCodeToUse()
        let categoryTitleLocalized: String = categoryTitle["\(langCode)"]?.string ?? ""
        let labelWidth: CGFloat = categoryTitleLocalized.width(withConstrainedHeight: cell.categoryLabel.frame.height, font: labelFont!)
        
        cellWidth = widthTakenByOtherElements + labelWidth
        return cellWidth
    }
    
    private func dismissOnBoardingVC() {
        self.dismiss(animated: true, completion: {
            if let onBoardingPluginCompletion = OnBoardingManager.sharedInstance.onBoardingPluginCompletion {
                onBoardingPluginCompletion()
            }
        })
    }
}

extension OnBoardingOneStepViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case categoryCollectionView:
            let categoriesCount = viewModel?.categories.value.count ?? 0
            
            if categoriesCount > 1 {
                return categoriesCount
            } else {
                return 0
            }
        case segmentsCollectionView:
            let index = viewModel?.categorySelectedIndex.value ?? 0
            if let category = viewModel?.categories.value[safe: index] {
                return category.segments?.count ?? 0
            }
            return 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case categoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.langCode = viewModel?.languageCodeToUse()
            if let currentCatIndex = viewModel?.categorySelectedIndex.value {
                cell.isCurrentlySelected = (indexPath.item == currentCatIndex)
            }
            cell.category = viewModel?.categories.value[safe: indexPath.item]
            cell.layoutIfNeeded()
            return cell
        case segmentsCollectionView:
            let index = viewModel?.categorySelectedIndex.value ?? 0
            if let category = viewModel?.categories.value[safe: index], let segments = category.segments {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SegmentCollectionViewCell", for: indexPath) as! SegmentCollectionViewCell
                let segment = segments[safe: indexPath.item]
                let segmentIsCurrentlySelected = viewModel?.segmentIsCurrentlySelected(segment: segment) ?? false
                cell.isCurrentlySelected = segmentIsCurrentlySelected
                cell.segment = segment
                cell.layoutIfNeeded()
                return cell
            }
            return UICollectionViewCell()
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView == segmentsCollectionView, !finishedLoadingInitialCells else { return }

        if !finishedLoadingInitialCells {
            cell.transform = CGAffineTransform(translationX: 0, y: 60)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
}

extension OnBoardingOneStepViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        finishedLoadingInitialCells = true
        switch collectionView {
        case categoryCollectionView:
            viewModel?.categorySelectedIndex.value = indexPath.item
            return
        case segmentsCollectionView:
            let index = viewModel?.categorySelectedIndex.value ?? 0
            guard let category = viewModel?.categories.value[safe: index],
                let segments = category.segments,
                let selectedSegment = segments[safe: indexPath.item] else { return }
            
            viewModel?.addRemoveSegmentIdSelected(segment: selectedSegment)
            let segmentIsCurrentlySelected = viewModel?.segmentIsCurrentlySelected(segment: selectedSegment) ?? false
            if let cell = collectionView.cellForItem(at: indexPath) as? SegmentCollectionViewCell {
                cell.animateSelectionSegmentImageView(addBorder: segmentIsCurrentlySelected)
            }
            return
        default:
            return
        }
    }
}

extension OnBoardingOneStepViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case categoryCollectionView:
            let categoriesCount = viewModel?.categories.value.count ?? 0
            
            if categoriesCount > 1 {
                return CGSize(width: getCategoryCellWidthtForItemAt(indexPath: indexPath), height: 40)
            } else {
                return .zero
            }
        case segmentsCollectionView:
            var numColumns = 3
            if let value = OnBoardingManager.sharedInstance.styles?["numberOfColumns"] as? String, let cols = Int(value) {
                numColumns = cols
            }
            
            let ratio = CGFloat(95.0/128.0)
            let width = collectionView.frame.width / CGFloat(numColumns)
            let height = width / ratio
            
            //return CGSize(width: 95, height: 128)
            return CGSize(width: width, height: height)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case categoryCollectionView:
            return UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        case segmentsCollectionView:
            return .zero//UIEdgeInsets(top: 10, left: 24, bottom: 90, right: 24)
        default:
            //return UIEdgeInsets(top: 10, left: 10, bottom: 100, right: 10)
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension OnBoardingOneStepViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.finishedLoadingInitialCells = true
    }
}

extension Collection where Indices.Iterator.Element == Index {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
