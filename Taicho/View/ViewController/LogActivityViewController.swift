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

    private static let title = "New Log"
    private static let createNewPresetString = "Log New Activity"

    private let activityOptionCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = UIConstants.interSectionSpacing
        collectionViewLayout.estimatedItemSize = LogActivityOptionCell.sizeRequired
        collectionViewLayout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()
    fileprivate var viewModels: [LogActivityOptionViewModel] = []

    /**
     The subscriber for log entry insertions. Will cause an update
     to the table view when log entries are added.
     */
    private var logEntryPresetsInsertedReceiver: AnyCancellable?

    /**
     The subscriber for log entry removals. Will cause an update to the table view
     when log entries are removed, if necessary.
     */
    private var logEntryPresetsDeletedReceiver: AnyCancellable?

    /**
     The subscriber listening to updates for individual log entries.
     */
    private var logEntryPresetObjectsReceiver: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        activityOptionCollectionView.delegate = self
        activityOptionCollectionView.dataSource = self
        activityOptionCollectionView.register(LogActivityOptionCell.self, forCellWithReuseIdentifier: LogActivityOptionCell.reuseIdentifier)
        view.addSubview(activityOptionCollectionView)
        activityOptionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityOptionCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            activityOptionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityOptionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.interItemSpacing),
            activityOptionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.interItemSpacing)
        ])

        activityOptionCollectionView.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPressOnCollectionView(_:))))

        logEntryPresetsInsertedReceiver = TaichoContainer.container.logEntryPresetDataManager.objectInsertedPublisher.sink(receiveValue: { [weak self] presets in
            presets.forEach { preset in
                self?.viewModels.append(LogActivityOptionViewModel(
                    icon: preset.icon,
                    name: preset.name,
                    logEntryPreset: preset))
            }
            self?.updateData()
        })
        logEntryPresetsDeletedReceiver = TaichoContainer.container.logEntryPresetDataManager.objectDeletedPublisher.sink(receiveValue: { [weak self] presets in
            self?.viewModels.removeAll(where: { viewModel in
                presets.contains { $0.objectID == viewModel.logEntryPreset?.objectID }
            })
            self?.updateData()
        })
        logEntryPresetObjectsReceiver = TaichoContainer.container.logEntryPresetDataManager.objectUpdatePublisher.sink(receiveValue: { [weak self] presets in
            self?.viewModels.forEach({ viewModel in
                if presets.contains(where: { $0.objectID == viewModel.logEntryPreset?.objectID }) {
                    viewModel.reload()
                }
            })
            self?.updateData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadViewModels(with: TaichoContainer.container.logEntryPresetDataManager.getAll())
        configureNavigationItem()
    }

    private func configureNavigationItem() {
        navigationItem.title = LogActivityViewController.title

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewPreset))
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

    @objc
    private func addNewPreset() {
        let viewController = LogEntryPresetDetailViewController(context: .new)
        present(UINavigationController(rootViewController: viewController), animated: true)
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
            // Log new activity flow
            present(UINavigationController(rootViewController: LogEntryDetailViewController()), animated: true)
        } else {
            guard let viewModel = viewModels[safe: indexPath.row] else {
                Log.assert("Failed to get view model at index path \(indexPath)")
                return
            }
            guard let preset = viewModel.logEntryPreset else {
                Log.assert("View model unexpectedly missing a preset \(viewModel)")
                return
            }
            present(UINavigationController(rootViewController: LogEntryDetailViewController(logEntryPreset: preset)), animated: true)
        }
    }

    @objc
    fileprivate func handleLongPressOnCollectionView(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        let p = gestureRecognizer.location(in: activityOptionCollectionView)

        // Create new preset cell can't be deleted.
        guard let indexPath = activityOptionCollectionView.indexPathForItem(at: p),
        indexPath.row != 0 else {
            return
        }

        let viewModel = viewModels[safe: indexPath.row]
        guard let preset = viewModel?.logEntryPreset else {
            Log.assert("Failed to fetch preset at index path \(indexPath)")
            return
        }

        let actionSheet = UIUtils.getAlertBottomSheet()
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self, weak actionSheet] action in
            actionSheet?.dismiss(animated: false, completion: {
                self?.present(UINavigationController(rootViewController: LogEntryPresetDetailViewController(logEntryPreset: preset, context: .edit)), animated: true)
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak actionSheet] action in
            TaichoContainer.container.logEntryPresetDataManager.delete(preset)
            actionSheet?.dismiss(animated: true)
        }))
        actionSheet.addAction(UIUtils.getDismissAction(actionSheet))
        present(actionSheet, animated: true)
    }

}
