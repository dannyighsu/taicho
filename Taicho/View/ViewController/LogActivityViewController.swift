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

    private static let title = "Taicho"
    private static let createNewPresetString = "Log New Activity"
    private static let highProductivitySection = 0
    private static let medProductivitySection = 1
    private static let lowProductivitySection = 2
    private static let noProductivitySection = 3

    private let activityOptionCollectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var activityOptionCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: activityOptionCollectionViewFlowLayout)
    private var highProductivityViewModels: [LogActivityOptionViewModel] {
        return allViewModels[safe: LogActivityViewController.highProductivitySection].assertIfNil() ?? []
    }
    private var medProductivityViewModels: [LogActivityOptionViewModel] {
        return allViewModels[safe: LogActivityViewController.medProductivitySection].assertIfNil() ?? []
    }
    private var lowProductivityViewModels: [LogActivityOptionViewModel] {
        return allViewModels[safe: LogActivityViewController.lowProductivitySection].assertIfNil() ?? []
    }
    private var noProductivityViewModels: [LogActivityOptionViewModel] {
        return allViewModels[safe: LogActivityViewController.noProductivitySection].assertIfNil() ?? []
    }
    private var allViewModels: [[LogActivityOptionViewModel]] = {
        return (0 ... LogActivityViewController.noProductivitySection).map { _ in
            [LogActivityOptionViewModel]()
        }
    }()

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

        activityOptionCollectionViewFlowLayout.minimumInteritemSpacing = UIConstants.interSectionSpacing
        activityOptionCollectionViewFlowLayout.scrollDirection = .vertical
        
        activityOptionCollectionView.delegate = self
        activityOptionCollectionView.dataSource = self
        activityOptionCollectionView.register(LogActivityOptionCell.self, forCellWithReuseIdentifier: LogActivityOptionCell.reuseIdentifier)
        activityOptionCollectionView.register(
            LogActivityCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: LogActivityCollectionHeaderView.reuseIdentifier)
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
                self?.addViewModel(LogActivityOptionViewModel(
                    icon: preset.icon,
                    name: preset.name,
                    logEntryPreset: preset))
            }
            self?.updateData()
        })
        logEntryPresetsDeletedReceiver = TaichoContainer.container.logEntryPresetDataManager.objectDeletedPublisher.sink(receiveValue: { [weak self] presets in
            guard let self = self else {
                return
            }
            for i in 0 ..< self.allViewModels.count {
                self.allViewModels[i].removeAll(where: { viewModel in
                    presets.contains { $0.objectID == viewModel.logEntryPreset.objectID }
                })
            }
            self.updateData()
        })
        logEntryPresetObjectsReceiver = TaichoContainer.container.logEntryPresetDataManager.objectUpdatePublisher.sink(receiveValue: { [weak self] presets in
            self?.allViewModels.flatMap({$0}).forEach({ viewModel in
                if presets.contains(where: { $0.objectID == viewModel.logEntryPreset.objectID }) {
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        activityOptionCollectionViewFlowLayout.headerReferenceSize = CGSize(width: view.frame.width, height: LogActivityCollectionHeaderView.requiredHeight)
    }

    private func configureNavigationItem() {
        navigationItem.title = LogActivityViewController.title

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "New Preset",
            style: .plain,
            target: self,
            action: #selector(addNewPreset))
    }

    private func updateData() {
        activityOptionCollectionView.reloadData()
    }

    private func loadViewModels(with logEntryPresets: [LogEntryPreset]) {
        let viewModelConstructor = { preset in
            return LogActivityOptionViewModel(
                icon: preset.icon,
                name: preset.name,
                logEntryPreset: preset)
        }
        allViewModels[LogActivityViewController.highProductivitySection] = logEntryPresets.filter { $0.productivityLevel == .high }.map(viewModelConstructor)
        allViewModels[LogActivityViewController.medProductivitySection] = logEntryPresets.filter { $0.productivityLevel == .medium }.map(viewModelConstructor)
        allViewModels[LogActivityViewController.lowProductivitySection] = logEntryPresets.filter { $0.productivityLevel == .low }.map(viewModelConstructor)
        allViewModels[LogActivityViewController.noProductivitySection] = logEntryPresets.filter { $0.productivityLevel == .none }.map(viewModelConstructor)
    }
    
    private func addViewModel(_ viewModel: LogActivityOptionViewModel) {
        switch viewModel.logEntryPreset.productivityLevel {
        case .high:
            allViewModels[LogActivityViewController.highProductivitySection].append(viewModel)
        case .medium:
            allViewModels[LogActivityViewController.medProductivitySection].append(viewModel)
        case .low:
            allViewModels[LogActivityViewController.lowProductivitySection].append(viewModel)
        case .none:
            allViewModels[LogActivityViewController.noProductivitySection].append(viewModel)
        }
    }

    @objc
    private func addNewPreset() {
        let viewController = LogEntryPresetDetailViewController(context: .new)
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
}

extension LogActivityViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return highProductivityViewModels.count
        case 1: return medProductivityViewModels.count
        case 2: return lowProductivityViewModels.count
        case 3: return noProductivityViewModels.count
        default:
            Log.assert("Invalid section found.")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LogActivityOptionCell.reuseIdentifier,
            for: indexPath) as? LogActivityOptionCell else {
                Log.assert("Incorrect cell type found for index path \(indexPath)")
                return .zero
        }
        return cell.sizeRequired
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LogActivityOptionCell.reuseIdentifier,
            for: indexPath) as? LogActivityOptionCell else {
                Log.assert("Incorrect cell type found for index path \(indexPath)")
                return UICollectionViewCell()
        }
        let viewModelOrNil: LogActivityOptionViewModel?
        switch indexPath.section {
        case LogActivityViewController.highProductivitySection:
            viewModelOrNil = highProductivityViewModels[safe: indexPath.row]
        case LogActivityViewController.medProductivitySection:
            viewModelOrNil = medProductivityViewModels[safe: indexPath.row]
        case LogActivityViewController.lowProductivitySection:
            viewModelOrNil = lowProductivityViewModels[safe: indexPath.row]
        case LogActivityViewController.noProductivitySection:
            viewModelOrNil = noProductivityViewModels[safe: indexPath.row]
        default:
            viewModelOrNil = nil
        }
        guard let viewModel = viewModelOrNil else {
            Log.assert("View model not found for index path \(indexPath)")
            return UICollectionViewCell()
        }
        cell.load(viewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = allViewModels[safe: indexPath.section]?[safe:indexPath.row] else {
            Log.assert("Failed to get view model at index path \(indexPath)")
            return
        }
        present(UINavigationController(rootViewController: LogEntryDetailViewController(logEntryPreset: viewModel.logEntryPreset)), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: LogActivityCollectionHeaderView.reuseIdentifier,
            for: indexPath) as? LogActivityCollectionHeaderView else {
                Log.assert("Invalid header view type found.")
                return UICollectionReusableView()
            }
        
        switch indexPath.section {
        case 0:
            headerView.loadProductivity(.high)
        case 1:
            headerView.loadProductivity(.medium)
        case 2:
            headerView.loadProductivity(.low)
        case 3:
            headerView.loadProductivity(.none)
        default:
            Log.assert("Unhandled section found.")
        }
        headerView.delegate = self
        return headerView
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

        guard let viewModel = allViewModels[safe: indexPath.section]?[safe:indexPath.row] else {
            Log.assert("Failed to get view model at index path \(indexPath)")
            return
        }
        let actionSheet = UIUtils.getAlertBottomSheet()
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self, weak actionSheet] action in
            actionSheet?.dismiss(animated: false, completion: {
                self?.present(UINavigationController(rootViewController: LogEntryPresetDetailViewController(logEntryPreset: viewModel.logEntryPreset, context: .edit)), animated: true)
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak actionSheet] action in
            TaichoContainer.container.logEntryPresetDataManager.delete(viewModel.logEntryPreset)
            TaichoContainer.container.persistenceController.saveContext()
            actionSheet?.dismiss(animated: true)
        }))
        actionSheet.addAction(UIUtils.getDismissAction(actionSheet))
        present(actionSheet, animated: true)
    }

}

extension LogActivityViewController: LogActivityCollectionHeaderViewDelegate {
    
    func newButtonTapped(forProductivity productivity: ProductivityLevel) {
        let viewController: LogEntryDetailViewController
        switch productivity {
        case .high:
            viewController = LogEntryDetailViewController(defaultProductivity: .high)
        case .medium:
            viewController = LogEntryDetailViewController(defaultProductivity: .medium)
        case .low:
            viewController = LogEntryDetailViewController(defaultProductivity: .low)
        case .none:
            viewController = LogEntryDetailViewController(defaultProductivity: ProductivityLevel.none)
        }
        present(UINavigationController(rootViewController: viewController), animated: true)
    }

}
