//
//  ViewController.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/8.
//  Copyright © 2020 George Liu. All rights reserved.
//

import RxCocoa
import RxSwift
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
            collectionView.collectionViewLayout = {
                let flowLayout = UICollectionViewFlowLayout()
                flowLayout.scrollDirection = .vertical
                return flowLayout
            }()
        }
    }

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }

    var viewModel: SearchViewModel!
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.outputs.reloadData.drive(onNext: { [weak self] in
            self?.collectionView.reloadData()
        }).disposed(by: bag)
    }
}

// MARK: - CollectionView DataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputs.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = viewModel.outputs.items[indexPath.row]
        let cell: UserCollectionViewCell = collectionView.makeCell(indexPath: indexPath)
        cell.configure(name: user.name, picURLStr: user.picURLStr)
        return cell
    }
}

// MARK: - CollectionView Delegate
extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.outputs.items.count - 1,
            viewModel.outputs.shouldLoadMore {
            viewModel.inputs.loadMore()
        }
    }

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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
