//
//  ArticleDetailViewController.swift
//  InternManager
//
//  Created by apple on 2017/8/25.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import SVProgressHUD
class ArticleDetailViewController: RootViewController {
    var article: Article?
    
    public var webURLStr = ""
    public var articleID = ""
    
    let progressView = UIProgressView(progressViewStyle: .default).then {
        $0.progressTintColor = KNaviColor
    }
    let webView = WKWebView().then {
        $0.scrollView.keyboardDismissMode = .onDrag
    }
    let commentView = CommentToolView.default()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        setupInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentView.loadUserInfo()
        
        let pushD = UserDefaults.standard
        guard let result = pushD.object(forKey: "push") as? String else{return}
        if result == "push" {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(reback))
        }else{
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    func reback() {
        let pushD = UserDefaults.standard
        pushD.set("", forKey: "push")
        pushD.synchronize()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    fileprivate func setupUI() {
        self.view.addSubview(self.webView)
        self.webView.addSubview(self.progressView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 55, 0))
        }
        progressView.snp.makeConstraints { (make) in
            make.left.right.equalTo(webView)
            make.top.equalTo(webView).offset(64)
            make.height.equalTo(4)
        }
        self.view.addSubview(commentView)
        commentView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "评论", style: .plain, target: self, action: #selector(commentList))
    }
    fileprivate func setupRx() {
        webView.rx.observe(Double.self, "estimatedProgress").subscribe(onNext: { [unowned self] (progres) in
            self.progressView.progress = Float(progres ?? 0)
            self.progressView.isHidden = progres == 1
        }).addDisposableTo(disposeBag)
       
    }
    
    fileprivate func setupInit() {
        let requ = URLRequest(url: URL(string: webURLStr)!)
        webView.load(requ)
        
        let block = { [unowned self] (btn: UIButton) in
            guard self.showLogin() else{
                return
            }
            switch btn.tag {
            case 0:
                self.like(btn)
            case 1:
                self.shareSDK()
            case 2:
                self.send()
            default:
                break
            }
        }
        commentView.actionBlock = block
        commentView.article_id = articleID
        commentView.loadUserInfo()
    }
    
    func like(_ btn: UIButton) {
        WXActivityIndicatorView.start()
        NetworkManager.providerHomeApi.request(.setCollect(article_id: articleID, user_id: UserManager.shareUserManager.curUserInfo?.id ?? "")).mapJSON().subscribe(onNext: { (res) in
            WXActivityIndicatorView.stop()
            guard let respon = res as? Dictionary<String, Any> else{
                return
            }
            guard let data = respon["data"] as? Dictionary<String, Any> else {
                return
            }
            SVProgressHUD.showSuccess(withStatus: data["msg"] as? String ?? "")
            btn.isSelected = !btn.isSelected
        }, onError: { (er) in
            WXActivityIndicatorView.stop()
        }).addDisposableTo(disposeBag)
    }
    
    func send() {
        WXActivityIndicatorView.start()
        let userID = UserManager.shareUserManager.curUserInfo?.id ?? ""
        NetworkManager.providerHomeApi.request(.sendCommentArticle(user_id: userID, article_id: articleID, content: commentView.textField.text)).mapJSON()
        .subscribe(onNext: { [unowned self] (res) in
            WXActivityIndicatorView.stop()
            guard let respon = res as? Dictionary<String, Any> else{
                return
            }
            guard let data = respon["data"] as? Dictionary<String, Any> else {
                return
            }
            SVProgressHUD.showSuccess(withStatus: data["msg"] as? String ?? "")
            self.commentView.textField.text = ""
            self.commentList()
            
        }, onError: { (err) in
            WXActivityIndicatorView.stop()
        }).addDisposableTo(disposeBag)
    }

    func commentList() {
        let vc = CommentListViewController()
        vc.articleID = articleID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func shareSDK() {
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: article?.article_content ?? "",
                                          images : article?.file_path,
                                          url : NSURL(string:webURLStr) as URL!,
                                          title : article?.article_title ?? "",
                                          type : SSDKContentType.auto)
        
        //2.进行分享
        ShareSDK.showShareActionSheet(self.view, items: nil, shareParams: shareParames) { (state, platform, param, entity, err, flag) in
            switch state{
                
            case SSDKResponseState.success: print("分享成功")
            case SSDKResponseState.fail:    print("授权失败,错误描述:\(err.debugDescription)")
            case SSDKResponseState.cancel:  print("操作取消")
                
            default:
                break
            }
            
        }
        
    }

}
extension ArticleDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = webView.title
        
    }
}
