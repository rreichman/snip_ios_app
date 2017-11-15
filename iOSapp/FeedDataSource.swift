//
//  FeedDataSource.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class FeedDataSource: NSObject, UITableViewDataSource
{
    var postDataArray: [PostData] = []
    var _tableView: UITableView = UITableView()
    var setOfCellsNotToTruncate : Set<Int> = Set<Int>()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        _tableView = tableView
        handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row);
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let postData = postDataArray[indexPath[1]]
        tableView.allowsSelection = false
        
        retrievePostImage(cell: cell, postData: postData)
        fillImageDescription(cell: cell, postData: postData)
        fillPublishTimeAndWriterInfo(cell: cell, postData: postData)
        
        makeCellClickable(tableViewCell : cell)
        setCellText(tableViewCell : cell, postDataArray : postDataArray, indexPath: indexPath, shouldTruncate: !setOfCellsNotToTruncate.contains(indexPath[1]))
        
        cell.headline.font = SystemVariables().HEADLINE_TEXT_FONT
        cell.headline.text = postData.headline
        
        turnLikeAndDislikeIntoButtons(cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postDataArray.count
    }
    
    func handleInfiniteScroll(tableView : UITableView, currentRow : Int)
    {
        let SPARE_ROWS_UNTIL_MORE_SCROLL = 2
        if postDataArray.count - currentRow < SPARE_ROWS_UNTIL_MORE_SCROLL
        {
            let tableViewController : TableViewController = tableView.delegate as! TableViewController
            SnipRetrieverFromWeb.shared.loadMorePosts(completionHandler: tableViewController.dataCollectionCompletionHandler)
        }
    }
    
    // Cell UI management functions
    
    func makeCellClickable(tableViewCell : TableViewCell)
    {
        let singleTapRecognizerImage : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.postImage.isUserInteractionEnabled = true
        tableViewCell.postImage.addGestureRecognizer(singleTapRecognizerImage)
        
        let singleTapRecognizerText : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.body.isUserInteractionEnabled = true
        tableViewCell.body.addGestureRecognizer(singleTapRecognizerText)
        
        let singleTapRecognizerHeadline : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.headline.isUserInteractionEnabled = true
        tableViewCell.headline.addGestureRecognizer(singleTapRecognizerHeadline)
        
        let singleTapRecognizerPostTimeAndAuthor : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.postTimeAndWriter.isUserInteractionEnabled = true
        tableViewCell.postTimeAndWriter.addGestureRecognizer(singleTapRecognizerPostTimeAndAuthor)
    }
    
    // Returns if the operation was handled
    func handleClickOnTextView(sender: UITapGestureRecognizer) -> Bool
    {
        let textView : UITextView = sender.view as! UITextView
        let layoutManager : NSLayoutManager = textView.layoutManager
        var location : CGPoint = sender.location(in: textView)
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        let characterIndex : Int = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let attributes : [NSAttributedStringKey : Any] = textView.attributedText.attributes(at: characterIndex, longestEffectiveRange: nil, in: NSRange(location: characterIndex, length: characterIndex + 1))
        for attribute in attributes
        {
            if attribute.key._rawValue == "NSLink"
            {
                UIApplication.shared.open((attribute.value as! NSURL) as URL, options: [:], completionHandler: nil)
                return true
            }
        }
        return false
    }
    
    func handleClickOnLikeDislike(isLikeButton : Bool, sender : UITapGestureRecognizer)
    {
        // TODO:: handle errors here
        
        let imageViewWithMetadata = sender.view as! UIImageViewWithMetadata
        let tableViewCell : TableViewCell = sender.view?.superview?.superview as! TableViewCell
        var otherButton : UIImageViewWithMetadata = tableViewCell.dislikeButton
        
        if (!isLikeButton)
        {
            otherButton = tableViewCell.likeButton
        }
        
        if (imageViewWithMetadata.isClicked)
        {
            imageViewWithMetadata.isClicked = false
            imageViewWithMetadata.image = imageViewWithMetadata.unclickedImage
            // TODO:: Manage unlike/undislike click
        }
        else
        {
            imageViewWithMetadata.isClicked = true
            imageViewWithMetadata.image = imageViewWithMetadata.clickedImage
            otherButton.image = otherButton.unclickedImage
            otherButton.isClicked = false
            // TODO:: manage like/dislike click
        }
    }
    
    @objc func handleClickOnLike(sender : UITapGestureRecognizer)
    {
        handleClickOnLikeDislike(isLikeButton: true, sender: sender)
    }
    
    @objc func handleClickOnDislike(sender : UITapGestureRecognizer)
    {
        handleClickOnLikeDislike(isLikeButton: false, sender: sender)
    }
    
    func turnLikeAndDislikeIntoButtons(cell : TableViewCell)
    {
        let likeButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnLike(sender:)))
        cell.likeButton.isUserInteractionEnabled = true
        cell.likeButton.addGestureRecognizer(likeButtonClickRecognizer)
        
        let dislikeButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnDislike(sender:)))
        cell.dislikeButton.isUserInteractionEnabled = true
        cell.dislikeButton.addGestureRecognizer(dislikeButtonClickRecognizer)
    }
    
    @objc func textLabelPressed(sender: UITapGestureRecognizer)
    {
        if sender.view is UITextView
        {
            if (handleClickOnTextView(sender: sender))
            {
                return
            }
        }
        
        let indexPath = _tableView.indexPathForRow(at: sender.location(in: _tableView))
        
        if (setOfCellsNotToTruncate.contains(indexPath![1]))
        {
            setOfCellsNotToTruncate.remove(indexPath![1])
        }
        else
        {
            setOfCellsNotToTruncate.insert(indexPath![1])
        }
        
        UIView.performWithoutAnimation
            {
                _tableView.beginUpdates()
                _tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
                _tableView.endUpdates()
        }
    }
}
