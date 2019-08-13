//
//  NoteTakingViewController.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-05-19.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

final class NoteTakingViewController: UIViewController, PhotoManagerProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var largePhotoImageView: UIImageView!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTitleEditButton: UIButton!
    @IBOutlet weak var noteDetailTextView: UITextView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoCollectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var allowAccessLabel: UILabel!
    @IBOutlet weak var getAccessButton: UIButton!
    
    private var photoManager: PhotoManager?
    private var noteManager = NoteManager()
    private var viewModel: NoteTakingViewModel?
    
    // MARK: - Constants & Variables
    let photoCellId = "photoPreviewCellId"
    var collectionViewHeight:CGFloat = 162
    let minimumLineSpacing: CGFloat = 8.5

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPhotoLibraryAccessAllowed() {
            photoManager = PhotoManager(largeImageViewSize: view.bounds.size, noteManager: noteManager)
        }
        viewModel = NoteTakingViewModel(photoManager: photoManager, noteManager: noteManager)
        setStyle()
        addKeyboardObserver()
        setTextDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPhotoLibraryPermission { [weak self] (status) in
            DispatchQueue.main.async {
                if status {
                    guard let viewModel = self?.viewModel else {
                        return
                    }
                    viewModel.updatePhotoManager(largeImageViewSize: self?.view.bounds.size)
                    
                    viewModel.setCurrentSelectedPhoto(indexPath: viewModel.selectedIndexPath) {
                        self?.populateViewWithSelectedPhotoInfo()
                    }
                    self?.photosCollectionView.reloadData()
                } else {
                    self?.allowAccessLabel.isHidden = false
                    self?.getAccessButton.isHidden = false
                    self?.noteTitleTextField.isUserInteractionEnabled = false
                    self?.noteDetailTextView.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Make photo collection view shorter for iPhone 6\7\8 or 5
        let viewHeight = view.bounds.height
        if viewHeight <= 667 {
            collectionViewHeight = viewHeight * 0.181
            photoCollectionViewHeightConstraint.constant = collectionViewHeight
        }
        
        // Set photo collection view layout
        if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = minimumLineSpacing
            let cellWidth = (view.bounds.width - minimumLineSpacing * 4) / 5 // 5 horizontal cells
            layout.itemSize = CGSize(width: cellWidth, height: collectionViewHeight - 1)
            
            // Set thumbnail image size to the cell's size so we don't need to load all our phone photos in a large size
            viewModel?.updateThumbnailSize(size: layout.itemSize)
        }
        
        // Make scroll view scrollable for iPhone 5
        let detailTextViewMinHeight: CGFloat = 59
        let detailTextViewHeight = noteDetailTextView.bounds.height
        if detailTextViewHeight < detailTextViewMinHeight {
            contentViewHeightConstraint.constant += detailTextViewMinHeight - detailTextViewHeight
        }
    }
    
    deinit {
        // Remove keyboard listener
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        if let photoManager = photoManager {
            removePHPhotoObserver(observer: photoManager)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    fileprivate func setStyle() {
        largePhotoImageView.image = viewModel?.largePhoto
        // Set keyboard style
        noteTitleTextField.keyboardAppearance = .dark
        noteDetailTextView.keyboardAppearance = .dark

        noteTitleTextField.returnKeyType = .done
        noteDetailTextView.returnKeyType = .done
        
        // Set text field/View style
        if let font = Fonts.SFmedium20 {
            noteTitleTextField.attributedPlaceholder = NSAttributedString(string: Constants.defaultNoteTitle, attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor, NSAttributedString.Key.font: font])
        }
        noteDetailTextView.textContainerInset = UIEdgeInsets(top: 10, left: 21, bottom: 10, right: 21)
        
        // Allow Access
        getAccessButton.layer.cornerRadius = 20.5
    }
    
    @IBAction func NoteTitleEditButtontapped(_ sender: Any) {
        noteTitleTextField.becomeFirstResponder()
    }
    
    @IBAction func getAccessButtonTapped(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl)
        else { return }
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
}

// MARK: - CollectionView
extension NoteTakingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItems() ?? 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: photoCellId, for: indexPath) as? PhotoPreviewCollectionViewCell else {
            return UICollectionViewCell()
        }
        let cellViewModel = viewModel?.getCellViewModel(atIndexPath: indexPath)
        cell.configCell(cellViewModel: cellViewModel, indexPath: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Disable selection if app has no access to photo album.
        guard getAccessButton.isHidden, let viewModel = viewModel else { return }
        
        viewModel.setCurrentSelectedPhoto(indexPath: indexPath) { [weak self] in
            self?.populateViewWithSelectedPhotoInfo()
            let prevSelectedIndex = viewModel.selectedIndexPath
            viewModel.updateSelectedIndexPath(atIndexPath: indexPath)

            // Update cellViewModel's isSelected property
            let prevVM = viewModel.getCellViewModel(atIndexPath: prevSelectedIndex)
            prevVM?.isSelected = false
            let currentVM = viewModel.getCellViewModel(atIndexPath: indexPath)
            currentVM?.isSelected = true
            
            self?.photosCollectionView.reloadItems(at: [prevSelectedIndex])
            self?.photosCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    fileprivate func populateViewWithSelectedPhotoInfo() {
        creationDateLabel.text = viewModel?.photoCreatedData
        largePhotoImageView.image = viewModel?.largePhoto
        noteTitleTextField.text = viewModel?.noteTitle
        noteDetailTextView.text = viewModel?.noteDetail
    }
}

// MARK: - Keyboard
extension NoteTakingViewController {
    fileprivate func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            keyboardWillShow(notification, keyboardHeight: keyboardHeight)
        } else {
            keyboardWillHide(notification, keyboardHeight: keyboardHeight)
        }
    }
    
    func keyboardWillShow(_ notification: Notification, keyboardHeight: CGFloat) {
        // Add keyboard height to contentView's so the scroll view can scroll
        UIView.animate(withDuration: 0.3, animations: {
            self.contentViewHeightConstraint.constant += keyboardHeight
        })
        // Move up if keyboard hide input field
        let distanceToBottom = self.scrollView.frame.size.height - noteDetailTextView.frame.origin.y - noteDetailTextView.frame.size.height + collectionViewHeight - 20
        
        let collapseSpace = keyboardHeight - distanceToBottom
        guard collapseSpace >= 0 else { return }
        UIView.animate(withDuration: 0.3, animations: {
            // scroll to the position above keyboard 10 points
            self.scrollView.contentOffset = CGPoint(x: 0, y: collapseSpace + 10)
        })
    }
    
    func keyboardWillHide(_ notification: Notification, keyboardHeight: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.contentViewHeightConstraint.constant -= keyboardHeight
            self.scrollView.contentOffset = .zero
        }
    }
}

// MARK: - TextField & TextView
extension NoteTakingViewController: UITextFieldDelegate, UITextViewDelegate {
    fileprivate func setTextDelegate() {
        noteTitleTextField.delegate = self
        noteDetailTextView.delegate = self
    }
    
    // MARK: - Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateNoteWhenDidEndEditing()
    }
    
    // MARK: - Text View
    // Mimic placeholder behaviour
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == Constants.defaultNoteDetail {
            textView.text = ""
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = Constants.defaultNoteDetail
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateNoteWhenDidEndEditing()
    }
    
    // Mimic dismiss keyboard when should return
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // Helper
    fileprivate func updateNoteWhenDidEndEditing() {
        guard let viewModel = viewModel else { return }
        viewModel.noteTitle = noteTitleTextField.text
        viewModel.noteDetail = noteDetailTextView.text
        
        viewModel.saveNote() { [weak self] (errorMessage) in
            if let errorMessage = errorMessage {
                self?.showDefaultAlert(title: "Note not saved", message: errorMessage)
            } else {
                // Update the hasNote indicator real time
                let indexPath = viewModel.selectedIndexPath
                self?.photosCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    fileprivate func showDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
