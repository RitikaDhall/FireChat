//
//  ProfileViewController.swift
//  FireChat
//
//  Created by Ritika Dhall on 30/10/20.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

final class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var data = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        data.append(Section(title: "Info", options: [
            ProfileViewModel(viewModelType: .name,
                             title: UserDefaults.standard.value(forKey: "name") as? String ?? "No Name",
                             handler: nil),
            ProfileViewModel(viewModelType: .info,
                             title: UserDefaults.standard.value(forKey: "email") as? String ?? "No Email",
                             handler: nil)
        ]))
        
        data.append(Section(title: "Log Out", options: [
            ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                let alertLogOut = UIAlertController(title: "Log Out",
                                                    message: "Are you sure you want to log out?",
                                                    preferredStyle: .alert)
                
                alertLogOut.addAction(UIAlertAction(title: "Log Out",
                                                    style: .destructive,
                                                    handler: { [weak self] _ in
                                                        
                                                        guard let strongSelf = self else {
                                                            return
                                                        }
                                                        
                                                        UserDefaults.standard.set(nil, forKey: "email")
                                                        UserDefaults.standard.set(nil, forKey: "name")
                                                        
                                                        // Facebook log out
                                                        FBSDKLoginKit.LoginManager().logOut()
                                                        
                                                        // Google log out
                                                        GIDSignIn.sharedInstance()?.signOut()
                                                        
                                                        do {
                                                            try FirebaseAuth.Auth.auth().signOut()
                                                            
                                                            let vc = LoginViewController()
                                                            let nav = UINavigationController(rootViewController: vc)
                                                            nav.modalPresentationStyle = .fullScreen
                                                            strongSelf.present(nav, animated: true)
                                                        }
                                                        catch {
                                                            print("Failed to log out.")
                                                        }
                                                    }))
                
                alertLogOut.addAction(UIAlertAction(title: "Cancel",
                                                    style: .cancel,
                                                    handler: nil))
                
                strongSelf.present(alertLogOut, animated: true)
            })
        ]))
                
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        tableView.tableFooterView = createTableFooter()
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .systemGray4
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 200) / 2,
                                                  y: 50,
                                                  width: 200,
                                                  height: 200))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBackground
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get the download url: \(error)")
            }
        })
        
        return headerView
    }
    
    func createTableFooter() -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.width,
                                              height: 100))
        let imageView = UIImageView(frame: CGRect(x: (footerView.width - 125) / 2,
                                                  y: 15,
                                                  width: 125,
                                                  height: 125))
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        footerView.addSubview(imageView)
        return footerView
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier,
                                                 for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section].options[indexPath.row].handler?()
    }
    
}

class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        textLabel?.text = viewModel.title
        backgroundColor = .secondarySystemGroupedBackground
        
        switch viewModel.viewModelType {
        case .name:
            textLabel?.textAlignment = .center
            textLabel?.font = .systemFont(ofSize: 24, weight: .medium)
            selectionStyle = .none
        case .info:
            textLabel?.textAlignment = .center
            textLabel?.font = .systemFont(ofSize: 22, weight: .regular)
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .systemRed
            textLabel?.font = .systemFont(ofSize: 22, weight: .regular)
            textLabel?.textAlignment = .center
        }
    }
}
