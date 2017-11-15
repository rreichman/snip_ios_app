//
//  Tools.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/13/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func removePaddingFromTextView(textView : UITextView)
{
    textView.textContainerInset = UIEdgeInsets.zero
    textView.textContainer.lineFragmentPadding = 0
}

func getTimeAndWriterStringFromDateString(dateString : String, author : String) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    let dateAsDataStructure = dateFormatter.date(from : dateString)
    
    var displayedTime = ""
    let dateDifferenceInDays = Date().days(from: dateAsDataStructure!)
    if (dateDifferenceInDays < 30)
    {
        if (dateDifferenceInDays == 0)
        {
            let dateDifferenceInHours = Date().hours(from: dateAsDataStructure!)
            if (dateDifferenceInHours == 0)
            {
                let dateDifferenceInMinutes = Date().minutes(from: dateAsDataStructure!)
                if (dateDifferenceInMinutes == 0)
                {
                    let dateDifferenceInSeconds = Date().seconds(from: dateAsDataStructure!)
                    displayedTime.append(String(dateDifferenceInSeconds))
                    displayedTime.append(" secs ago")
                }
                else
                {
                    displayedTime.append(String(dateDifferenceInMinutes))
                    if (dateDifferenceInMinutes == 1)
                    {
                        displayedTime.append(" min ago")
                    }
                    else
                    {
                        displayedTime.append(" mins ago")
                    }
                }
            }
            else
            {
                displayedTime.append(String(dateDifferenceInHours))
                if (dateDifferenceInHours == 1)
                {
                    displayedTime.append(" hour ago")
                }
                else
                {
                    displayedTime.append(" hours ago")
                }
            }
        }
        else
        {
            displayedTime.append(String(dateDifferenceInDays))
            if (dateDifferenceInDays == 1)
            {
                displayedTime.append(" day ago")
            }
            else
            {
                displayedTime.append(" days ago")
            }
        }
    }
    else
    {
        displayedTime = String(dateString.prefix(10))
    }
    return displayedTime + ", by " + author
}

public func getLastIndexOfSubstringInString(originalString : String, substring : String) -> Int
{
    return (originalString.range(of: substring, options: .backwards)?.lowerBound.encodedOffset)!
}


// Use this for tests
/*let calendar = NSCalendar.current
 var componentSet = Set<Calendar.Component>()
 componentSet.insert(Calendar.Component.year)
 componentSet.insert(Calendar.Component.month)
 componentSet.insert(Calendar.Component.day)
 componentSet.insert(Calendar.Component.hour)
 componentSet.insert(Calendar.Component.minute)
 
 let components = calendar.dateComponents(componentSet, from: dateAsDataStructure!)
 let year = components.year
 let month = components.month
 let day = components.day
 let hour = components.hour
 let minutes = components.minute*/



/*
 Constrainsts stuff
 
 if (setOfCellsNotToTruncate.contains(indexPath[1]))
 {
 let referencesTextView = cell.contentView.viewWithTag(999)
 //referencesTextView?.removeFromSuperview()
 if (referencesTextView != nil)
 {
 return cell
 }
 
 //addReferencesToPost(cell : cell, postData: postData)
 let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
 textView.attributedText = NSAttributedString(string: "hello this is a text view which is sub. what is done with this")
 
 textView.tag = 999
 textView.translatesAutoresizingMaskIntoConstraints = false
 cell.contentView.addSubview(textView)
 
 print("here\n\n\n")
 for view in cell.contentView.subviews
 {
 print("Another view: \(view)\n\n")
 print(view.constraints)
 print("\n\n\n")
 }
 //print("imageview constraints")
 //print(cell.imageView?.constraints)
 
 let constraintBelowImage = NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: cell.imageView, attribute: .top, multiplier: 1, constant: 0)
 cell.contentView.addConstraint(constraintBelowImage)
 _tableView.updateConstraints()
 }
 else
 {
 //cell.likeButton.isHidden = true
 //cell.references.isHidden = true
 }
 
 */
