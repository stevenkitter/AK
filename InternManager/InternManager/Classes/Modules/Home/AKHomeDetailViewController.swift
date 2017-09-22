//
//  AKHomeDetailViewController.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/22.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit

class AKHomeDetailViewController: RootViewController {
    var class_name = ""
    var contents: [AKLinkModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefresh()
        loadServerData()
    }
    override func setupRefresh() {
        tableView.mj_header = RefreshHeader(refreshingBlock: { [unowned self] in
            self.loadServerData()
        })
    }
    func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        tableView.register(str: "AKHomeDetailTableViewCell")
    }
    override func loadServerData() {
        NetworkManager.providerHomeApi.request(.getlink(class_name: class_name)).mapArray(AKLinkModel.self).subscribe(onNext: { (list) in
            self.contents.removeAll()
            self.contents.append(contentsOf: list)
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
        }, onError: { (err) in
            self.tableView.mj_header.endRefreshing()
        }).addDisposableTo(disposeBag)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}

extension AKHomeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = contents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AKHomeDetailTableViewCell", for: indexPath) as! AKHomeDetailTableViewCell
        cell.iconImageView.kfImage(user.file_path)
        cell.contentLabel.text = user.link_title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = contents[indexPath.row]
        let vc = YSWebViewController()
        vc.url = model.link_url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

