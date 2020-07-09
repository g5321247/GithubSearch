//
//  ViewController.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/8.
//  Copyright © 2020 George Liu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.registerCollectionViewCell(
                identifiers: [
                    String(describing: UserCollectionViewCell.self)
                ]
            )
        }
    }

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }

    var viewModel: SearchViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - CollectionView DataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UserCollectionViewCell = collectionView.makeCell(indexPath: indexPath)
        return cell
    }
}

// MARK: - CollectionView Delegate
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideSpacing: CGFloat = 40
        let interitemSpacing: CGFloat = 30
        let numberOfInterCell = 2
        let spacing = (sideSpacing + interitemSpacing * CGFloat(numberOfInterCell - 1))
        let width =
            (Constant.screenWidth - spacing) / CGFloat(numberOfInterCell)
        
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

// MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.inputs.searchUsers(queryKey: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
