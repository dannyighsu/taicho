//
//  LogActivityViewController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation
import UIKit
import Combine

/**
 The base view controller that allows you to log new activities.
 */
class LogActivityViewController: UIViewController {

    private static let createNewPresetString = "Add New Preset"

    private let activityOptionCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = UIConstants.interSectionSpacing
        collectionViewLayout.estimatedItemSize = LogActivityOptionCell.sizeRequired
        collectionViewLayout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()
    @Published private var viewModels: [LogActivityOptionViewModel] = []
    /**
     The reactive stream for the viewModels array. Will cause an update
     to the collection view with the array membership is updated.
     */
    private lazy var viewModelStream: AnyCancellable? = $viewModels.receive(on: DispatchQueue.main).sink { [weak self] _ in
        self?.updateData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityOptionCollectionView.delegate = self
        activityOptionCollectionView.dataSource = self
        activityOptionCollectionView.register(LogActivityOptionCell.self, forCellWithReuseIdentifier: LogActivityOptionCell.reuseIdentifier)
        view.addSubview(activityOptionCollectionView)
        activityOptionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityOptionCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            activityOptionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityOptionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityOptionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadViewModels(with: TaichoContainer.container.logEntryPresetDataManager.getAll())
    }

    private func updateData() {
        activityOptionCollectionView.reloadData()
    }

    private func loadViewModels(with logEntryPresets: [LogEntryPreset]) {
        viewModels = [
            LogActivityOptionViewModel(
                icon: UIConstants.plusButtonEmoji,
                name: LogActivityViewController.createNewPresetString)
        ] + logEntryPresets.map { preset in
            LogActivityOptionViewModel(
                icon: preset.icon,
                name: preset.name,
                logEntryPreset: preset)
        }
    }
    
}

extension LogActivityViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LogActivityOptionCell.reuseIdentifier,
            for: indexPath) as? LogActivityOptionCell else {
                Log.assert("Incorrect cell type found for index path \(indexPath)")
                return UICollectionViewCell()
        }
        guard let viewModel = viewModels[safe: indexPath.row] else {
            Log.assert("View model not found for index path \(indexPath)")
            return UICollectionViewCell()
        }
        cell.load(viewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // Create new preset flow
            let viewController = LogEntryPresetDetailViewController()
            present(UINavigationController(rootViewController: viewController), animated: true)
        } else {

        }
    }

}
