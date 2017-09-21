//
//  AKFindPersonViewController.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/21.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit

class AKFindPersonViewController: RootViewController {
    var contents: [AKUserInfo] = []
    let textField = UITextField(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 45)).then {
        $0.placeholder = "手机号／名字／id"
        $0.clearsOnBeginEditing = true
        $0.borderStyle = .roundedRect
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "找人聊天"
        setupUI()
        // Do any additional setup after loading the view.
    }
    func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(str: "MeTableViewCell")
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        textField.delegate = self
        tableView.tableHeaderView = textField
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func search(text: String) {
        if text.characters.count > 0 {
            NetworkManager.providerUserApi.request(.searchUser(key: text)).mapArray(AKUserInfo.self).subscribe(onNext: { (list) in
                self.contents.removeAll()
                self.contents.append(contentsOf: list)
                self.tableView.reloadData()
            }, onError: { (err) in
                
            }).addDisposableTo(disposeBag)
            
        }
    }
    

}

extension AKFindPersonViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.search(text: textField.text ?? "")
        return true
    }
}
extension AKFindPersonViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = contents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeTableViewCell", for: indexPath) as! MeTableViewCell
        cell.iconImageView.kfImage(user.user_avatar)
        cell.titleLabel.text = user.userName()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AKPersonalViewController()
        vc.user = contents[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
