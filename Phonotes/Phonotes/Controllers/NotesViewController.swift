//
//  ViewController.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-05-19.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var photoDateLabel: UILabel!
    @IBOutlet weak var largePhotoImageView: UIImageView!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTitleEditButton: UIButton!
    @IBOutlet weak var noteDetailTextView: UITextView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoCollectionViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Constants
    let photoCellId = "photoPreviewCellId"
    
    // MARK: - Variables
    let photos = [
        Photo(photo: #imageLiteral(resourceName: "demo-photo1"), photoDate: "March 19, 2019", hasNote: false, noteTitle: "Time with Allen at UBC 1", noteDetail: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo3"), photoDate: "March 20, 2019", hasNote: true, noteTitle: "Work out day 2", noteDetail: "20 jumps."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo1"), photoDate: "March 21, 2019", hasNote: true, noteTitle: "Time with Allen at UBC 3", noteDetail: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo2"), photoDate: "March 22, 2019", hasNote: false, noteTitle: "@Emily 4", noteDetail: "Beautiful smile."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo1"), photoDate: "March 23, 2019", hasNote: true, noteTitle: "Time with Allen at UBC 5", noteDetail: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo3"), photoDate: "March 20, 2019", hasNote: true, noteTitle: "Work out day 6", noteDetail: "20 jumps."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo1"), photoDate: "March 21, 2019", hasNote: true, noteTitle: "Time with Allen at UBC 7", noteDetail: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo1"), photoDate: "March 19, 2019", hasNote: false, noteTitle: "Time with Allen at UBC 8", noteDetail: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo2"), photoDate: "March 22, 2019", hasNote: false, noteTitle: "@Emily 9", noteDetail: "Beautiful smile."),
        Photo(photo: #imageLiteral(resourceName: "demo-photo1"), photoDate: "March 23, 2019", hasNote: true, noteTitle: "Time with Allen at UBC 10", noteDetail: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt.")
    ]
    var selectedIndex = IndexPath(item: 2, section: 0)
    var collectionViewHeight:CGFloat = 162

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        addKeyboardObserver()
        setTextDelegate()
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
            layout.minimumLineSpacing = 8.5
            let cellWidth = (view.bounds.width - 34) / 5 // 8.5 * 4 = 34
            layout.itemSize = CGSize(width: cellWidth, height: collectionViewHeight - 1)
        }
        
        // Make scroll view scrollable for iPhone 5
        let detailTextViewHeight = noteDetailTextView.bounds.height
        if detailTextViewHeight < 59 {
            contentViewHeightConstraint.constant += 59 - detailTextViewHeight
        }
    }
    
    deinit {
        // Remove keyboard listener
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setStyle() {
        // Set keyboard style
        noteTitleTextField.keyboardAppearance = .dark
        noteDetailTextView.keyboardAppearance = .dark

        noteTitleTextField.returnKeyType = .done
        noteDetailTextView.returnKeyType = .done
        
        // Set text field/View style
        noteTitleTextField.attributedPlaceholder = NSAttributedString(string: Constants.defaultNoteTitle, attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor, NSAttributedString.Key.font: Fonts.SFmedium20!])
        noteDetailTextView.textContainerInset = UIEdgeInsets(top: 10, left: 21, bottom: 10, right: 21)
    }
    
    func addKeyboardObserver() {
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

    @IBAction func NoteTitleEditButtontapped(_ sender: Any) {
        noteTitleTextField.becomeFirstResponder()
    }
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: photoCellId, for: indexPath) as! PhotoPreviewCollectionViewCell
        configCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func configCell(cell: PhotoPreviewCollectionViewCell, indexPath: IndexPath) {
        let photoPath = photos[indexPath.row]
        cell.setupCell(photo: photoPath)
        if indexPath == selectedIndex {
            cell.setBorder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prevSelectedIndex = selectedIndex
        if let prevCell = photosCollectionView.cellForItem(at: prevSelectedIndex) as? PhotoPreviewCollectionViewCell {
            prevCell.removeBorder()
        }
        
        selectedIndex = indexPath
        
        if let cell = photosCollectionView.cellForItem(at: indexPath) as? PhotoPreviewCollectionViewCell {
            cell.setBorder()
        }
        
        // Populate view with selected photo info
        let photo = photos[indexPath.row]
        photoDateLabel.text = photo.photoDate
        largePhotoImageView.image = photo.photo
        if photo.hasNote {
            noteTitleTextField.text = photo.noteTitle
            noteDetailTextView.text = photo.noteDetail
        } else {
            noteTitleTextField.text = ""
            noteDetailTextView.text = Constants.defaultNoteDetail
        }
        
        photosCollectionView.reloadItems(at: [prevSelectedIndex])
    }
}

extension NotesViewController: UITextFieldDelegate, UITextViewDelegate {
    func setTextDelegate() {
        noteTitleTextField.delegate = self
        noteDetailTextView.delegate = self
    }
    
    // MARK: - Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
    // Mimic dismiss keyboard when should return
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
