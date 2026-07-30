import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else { return }
        
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.presenter = imagesListPresenter
        imagesListViewController.configure(imagesListPresenter)
        
        let profilePresenter = ProfileViewPresenter()
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        viewControllers = [imagesListViewController, profileViewController]
    }
}
