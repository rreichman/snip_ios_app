//
//  SplashScreenViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class OpeningSplashScreenViewController: UIViewController
{
    @IBOutlet weak var splashScreenBackgroundImage: UIImageView!
    @IBOutlet weak var splashScreenLogoImage: UIImageView!
    @IBOutlet weak var splashScreenSummarizedLineImage: UIImageView!
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewLeadingConstraint: NSLayoutConstraint!
    
    var snippetsTableViewController = SnippetsTableViewController()
    var _snipRetrieverFromWeb : SnipRetrieverFromWeb = SnipRetrieverFromWeb()
    var _postDataArray : [PostData] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("loaded splash screen: \(Date())")
        
        UserInformation().getUserInformationFromWeb()
        Logger().logStartedSplashScreen()
        loadSplashScreenImages()
        print("done loading splash screen: \(Date())")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadSplashScreenImages()
    {
        splashScreenLogoImage.image = #imageLiteral(resourceName: "snipLogo")
        splashScreenSummarizedLineImage.image = #imageLiteral(resourceName: "newsSummarized")
        splashScreenLogoImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        splashScreenSummarizedLineImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        splashScreenBackgroundImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        logoView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        logoViewTopConstraint.constant = (CachedData().getScreenHeight() - logoView.bounds.height) / 2
        logoViewLeadingConstraint.constant = (CachedData().getScreenWidth() - logoView.bounds.width) / 2
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        print("before super didAppear \(Date())")
        super.viewDidAppear(animated)
        print("after super didAppear \(Date())")
        /**
        _snipRetrieverFromWeb.isCoreSnipViewController = true
        _snipRetrieverFromWeb.lock.lock()
        print("about to get snips from server \(Date())")
        Logger().logAboutToRetrieveSplashScreenSnippets()
        _snipRetrieverFromWeb.getSnipsJsonFromWebServer(completionHandler: self.collectionCompletionHandler, appendDataAndNotReplace: false)
         **/
    }
    
    override func restoreUserActivityState(_ userActivity: NSUserActivity)
    {
        
        snippetsTableViewController.operateRefresh(newBaseUrlString: (userActivity.webpageURL?.absoluteString)!, newQuery: "", useActivityIndicator: true)
        snippetsTableViewController.shouldEnterCommentOfFirstSnippet = (userActivity.webpageURL?.absoluteString.range(of: "?comment") != nil)
        
        super.restoreUserActivityState(userActivity)
    }
    
    func collectionCompletionHandler(postsToAdd: [PostData], appendDataAndNotReplace : Bool)
    {
        print("starting here: \(Date())")
        _postDataArray = WebUtils.shared.addPostsToFeed(snipRetriever: _snipRetrieverFromWeb, originalPostDataArray: _postDataArray, postsToAdd: postsToAdd, appendDataAndNotReplace: appendDataAndNotReplace)

        print("performing segue: \(Date())")
        performSegue(withIdentifier: "segueToTabBarView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("preparing")
        //TODO: Replace this segue /w coordinator logic
        /**
        if (segue.identifier == "segueToTabBarView")
        {
            print("preparing to segue to tab bar view")
            
            let barViewController : MainTabBarViewController = segue.destination as! MainTabBarViewController
            let mainSnippetsTableViewController = (barViewController.viewControllers?.first as! UINavigationController).viewControllers.first as! SnippetsTableViewController
            mainSnippetsTableViewController.snipRetrieverFromWeb = _snipRetrieverFromWeb
            mainSnippetsTableViewController._postDataArray = _postDataArray
            snippetsTableViewController = mainSnippetsTableViewController
            
            print("done seguing to tab bar view")
        }
        **/
    }
}
