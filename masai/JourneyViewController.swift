//
//  JourneyViewController.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class JourneyViewController: MasaiBaseViewController {
    
    // MARK: Types
    
    enum SearchScope: Int {
        case all = 0
        case past = 1
        case future = 2
    }
    
    
    // MARK: Properties
    
    private var didSetup = false
    
    fileprivate var journeys: [Journey] = []
    
    fileprivate var selectedSegment: Segment?
    
    private var filterContentViewCollapsedConstraints: [NSLayoutConstraint] = []
    private var filterContentViewExpandedConstraints: [NSLayoutConstraint] = []
    private var filterContentViewIsExpanded = false
    private var selectedFilterScope = SearchScope.all
    
    
    // MARK: UI
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    var refreshControl: UIRefreshControl!
    
    private let filterContentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.dbRed
        return v
    }()
    
    private var filterTextfield: JourneyFilterTextField = {
        let tf = JourneyFilterTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "journey_filter_textfield_placeholder".localized
        tf.backgroundColor = .white
        tf.clearButtonMode = .always
        tf.tintColor = UIColor.dbRed
        return tf
    }()
    
    private var filterSegmentedView: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            "journey_filter_all".localized,
            "journey_filter_past".localized,
            "journey_filter_future".localized
            ])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private var filterSearchButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("journey_filter_search_button".localized, for: .normal)
        
        b.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        b.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        b.backgroundColor = UIColor.dbRed
        b.layer.cornerRadius = 4.0
        b.setTitleColor(UIColor.dbRed, for: .normal)
        b.backgroundColor = UIColor.white
        return b
    }()
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let li = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        li.translatesAutoresizingMaskIntoConstraints = false
        li.hidesWhenStopped = true
        return li
    }()
    
    struct EmptyStateView {
        init() {
            show(false)
            
            view.addSubview(imageView)
            view.addSubview(label)
            
            imageView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            label.pin.top.to(imageView.bottomAnchor).with(8).activate()
            label.pin.edges([.leading, .trailing]).to(view).with(constants: [16, -16]).activate()
        }
        
        var view: UIView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()
        
        var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.image = #imageLiteral(resourceName: "icon-no-journeys-found")
            return imageView
        }()
        
        var label: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textAlignment = .center
            l.numberOfLines = 0
            l.font = UIFont.systemFont(ofSize: 12)
            l.text = "no_journeys_found".localized
            return l
        }()
        
        func show(_ shouldShow: Bool) {
            DispatchQueue.main.async {
                if shouldShow {
                    self.view.alpha = 1.0
                } else {
                    self.view.alpha = 0.0
                }
            }
        }
    }
    private var emptyStateView = EmptyStateView()
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "journey_title".localized
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterTextfield.text = nil
        selectedFilterScope = .all
        retrieveJourneys()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        guard didSetup == false else {
            return
        }
        
        didSetup = true
        
        // Setup empty state view
        view.addSubview(emptyStateView.view)
        emptyStateView.view.pinEdges(to: view).activate()
        
        // Table view
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.pinEdges(to: view).activate()
        
        var insets = tableView.contentInset
        insets.bottom += self.tabBarController?.tabBar.frame.size.height ?? 0
        tableView.contentInset = insets
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(FlightSegmentTableViewCell.self, forCellReuseIdentifier: FlightSegmentTableViewCell.identifier)
        tableView.register(CarSegmentTableViewCell.self, forCellReuseIdentifier: CarSegmentTableViewCell.identifier)
        tableView.register(HotelSegmentTableViewCell.self, forCellReuseIdentifier: HotelSegmentTableViewCell.identifier)
        tableView.register(TrainSegmentTableViewCell.self, forCellReuseIdentifier: TrainSegmentTableViewCell.identifier)
        tableView.register(ActivitySegmentTableViewCell.self, forCellReuseIdentifier: ActivitySegmentTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "pull_to_refresh".localized)
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // Filter view
        view.addSubview(filterContentView)
        filterContentView.pin.edges([.leading, .trailing]).to(view).activate()
        filterContentViewCollapsedConstraints.append(contentsOf: filterContentView.pin.bottom.to(view.topAnchor).constraints)
        filterContentViewExpandedConstraints.append(contentsOf: filterContentView.pin.top.to(view).constraints)
        filterContentViewCollapsedConstraints.activate()
        
        filterContentView.addSubview(filterTextfield)
        filterTextfield.pin.edges([.leading, .top, .trailing]).to(filterContentView).with(constants: [8, 8, -8]).activate()
        
        filterContentView.addSubview(filterSegmentedView)
        filterSegmentedView.pin.edges([.leading, .trailing]).to(filterContentView).with(constants: [8, -8]).activate()
        filterSegmentedView.pin.top.to(filterTextfield.bottomAnchor).with(8).activate()
        
        filterContentView.addSubview(filterSearchButton)
        filterSearchButton.pin.edges([.trailing, .bottom]).to(filterContentView).with(constants: [-8, -8]).activate()
        filterSearchButton.pin.top.to(filterSegmentedView.bottomAnchor).with(8).activate()
        
        filterSegmentedView.addTarget(self, action: #selector(self.filterControlChanged(_:)), for: .valueChanged)
        filterTextfield.delegate = self
        filterSearchButton.addTarget(self, action: #selector(self.filterSearchButtonPressed(_:)), for: .touchUpInside)
        
        // Loading animation
        view.addSubview(loadingIndicator)
        loadingIndicator.pinCenter(to: view).activate()
    }
    
    
    // MARK: BaseViewController
    
    override func isNavigationBarRightItemVisible() -> Bool {
        return true
    }
    
    override func imageForNavigationBarRightItem() -> UIImage? {
        return #imageLiteral(resourceName: "icon-filter")
    }
    
    override func onPressedNavigationBarRightButton() {
        expandFilterView(!filterContentViewIsExpanded)
    }
    
    
    // MARK: UI events
    
    @objc private func filterControlChanged(_ sender: UISegmentedControl) {
        selectedFilterScope = SearchScope(rawValue: sender.selectedSegmentIndex)!
    }
    
    @objc private func filterSearchButtonPressed(_ sender: UIButton) {
        _ = filterTextfield.resignFirstResponder()
        expandFilterView(false)
        
        retrieveJourneys()
    }
    
    @objc private func pullToRefresh(_ sender: UIRefreshControl) {
        retrieveJourneys()
    }
    
    
    // MARK: Private
    
    fileprivate func journey(for section: Int) -> Journey? {
        guard journeys.indices.contains(section) else {
            return nil
        }
        
        return journeys[section]
    }
    
    fileprivate func segment(for indexPath: IndexPath) -> Segment? {
        guard let journey = self.journey(for: indexPath.section),
            let segments = journey.segments,
            segments.indices.contains(indexPath.row) else {
            return nil
        }
        
        let segment = segments[indexPath.row]
        return segment
    }
    
    private func retrieveJourneys() {
        retrieveJourneys(searchTerm: filterTextfield.text, scope: selectedFilterScope)
    }
    
    private func retrieveJourneys(searchTerm: String?, scope: SearchScope = .all) {
        showLoadingAnimation(true)
        
        let actualSearchTerm = (searchTerm?.length == 0 ? nil : searchTerm)
        AwsBackendManager.getJourneys(searchTerm: actualSearchTerm, scope: scope.rawValue) { [weak self] (didSucceed, journeys) in
            self?.showLoadingAnimation(false)
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.set(journeys: journeys ?? [])
        }
    }
    
    private func expandFilterView(_ shouldExpand: Bool) {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            if self.filterContentViewIsExpanded {
                self.filterContentViewExpandedConstraints.deactivate()
                self.filterContentViewCollapsedConstraints.activate()
            } else {
                self.filterContentViewCollapsedConstraints.deactivate()
                self.filterContentViewExpandedConstraints.activate()
            }
            self.view.layoutIfNeeded()
            self.filterContentViewIsExpanded = shouldExpand
        }
    }
    
    private func showLoadingAnimation(_ shouldShow: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if !self.refreshControl.isRefreshing {
                if shouldShow {
                    self.view.alpha = 0.9
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.view.alpha = 1.0
                }
            }
        }
    }
    
    fileprivate func segmentPosition(for indexPath: IndexPath) -> JourneySegmentTableViewCell.SegmentPosition {
        let journey = self.journey(for: indexPath.section)!
        if journey.segments?.count == 1 {
            return .none
        }
        
        let currentSegment = self.segment(for: indexPath)!
        
        let index = journey.segments?.index(where: { (segment) -> Bool in
            return NSDictionary(dictionary: currentSegment.dictionaryRepresentation()).isEqual(to: segment.dictionaryRepresentation())
        })
        guard let existingIndex = index else {
            return .none
        }
        
        if existingIndex == 0 {
            return .top
        }
        
        if existingIndex == journey.segments?.indices.last! {
            return .bottom
        }
        
        return .middle
    }
    
    private func set(journeys newJourneys: [Journey]) {
        DispatchQueue.main.async { [unowned self] in
            self.journeys = newJourneys
            UIView.animate(withDuration: 0.1, animations: {
                self.refreshControl.endRefreshing()
            }, completion: { (_) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    if newJourneys.count > 0 {
                        self.emptyStateView.show(false)
                    } else {
                        self.emptyStateView.show(true)
                    }
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "journeyToHotelDetails" {
            if let hotelDetailsVC = segue.destination as? ReservationDetailsHotelViewController,
                let hotelData = selectedSegment as? HotelSegment {
                hotelDetailsVC.segment = hotelData
            }
        } else if segue.identifier == "journeyToFlightDetails" {
            if let flightDetailsVC = segue.destination as? ReservationDetailsFlightViewController,
                let flightData = selectedSegment as? FlightSegment {
                flightDetailsVC.segment = flightData
            }
        } else if segue.identifier == "journeyToTrainDetails" {
            if let publicTransportVC = segue.destination as? ReservationDetailsPublicTransportViewController,
                let publicTransportData = selectedSegment as? TrainSegment {
                publicTransportVC.segment = publicTransportData
            }
        } else if segue.identifier == "journeyToCarDetails" {
            if let vc = segue.destination as? ReservationDetailsCarViewController,
                let segment = selectedSegment as? CarSegment {
                vc.segment = segment
            }
        } else if segue.identifier == "journeyToActivityDetails" {
            if let vc = segue.destination as? ReservationDetailsActivityViewController,
                let segment = selectedSegment as? ActivitySegment {
                vc.segment = segment
            }
        }
    }
    
}


// MARK: TableView
extension JourneyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let journey = self.journey(for: section),
            let firstSegment = journey.segments?.first,
            let lastSegment = journey.segments?.last,
            let startDateString = firstSegment.userFacingStartDateString,
            let endDateString = lastSegment.userFacingEndDateString else {
            return nil
        }
        
        let v = UIView()
        v.backgroundColor = UIColor.white
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(l)
        l.pinEdges(to: v, insets: UIEdgeInsets(top: 12, left: 12, bottom: -6, right: -12)).activate()
        l.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightThin)
        
        if startDateString == endDateString {
            l.text = "\(startDateString)"
        } else {
            l.text = "\(startDateString) - \(endDateString)"
        }
        
        return v
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return journeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journey(for: section)?.segments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let segment = self.segment(for: indexPath) else {
            return UITableViewCell()
        }
        
        var identifier: String
        switch segment {
        case _ as FlightSegment:
            identifier = FlightSegmentTableViewCell.identifier
        case _ as CarSegment:
            identifier = CarSegmentTableViewCell.identifier
        case _ as HotelSegment:
            identifier = HotelSegmentTableViewCell.identifier
        case _ as TrainSegment:
            identifier = TrainSegmentTableViewCell.identifier
        case _ as ActivitySegment:
            identifier = ActivitySegmentTableViewCell.identifier
        default:
            assert(false, "Unknown segment type!")
            return UITableViewCell()
        }
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? JourneySegmentTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setup(with: segment)
        cell.segmentPosition = segmentPosition(for: indexPath)
        cell.setNeedsLayout()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let segment = self.segment(for: indexPath)
        switch segment {
        case let s as FlightSegment:
            selectedSegment = s
            performSegue(withIdentifier: "journeyToFlightDetails", sender: nil)
            
        case let s as HotelSegment:
            selectedSegment = s
            performSegue(withIdentifier: "journeyToHotelDetails", sender: nil)
            
        case let s as TrainSegment:
            selectedSegment = s
            performSegue(withIdentifier: "journeyToTrainDetails", sender: nil)
            
        case let s as CarSegment:
            selectedSegment = s
            performSegue(withIdentifier: "journeyToCarDetails", sender: nil)
            
        case let s as ActivitySegment:
            selectedSegment = s
            performSegue(withIdentifier: "journeyToActivityDetails", sender: nil)
            
        default:
            assert(false, "Unknown segment type found")
            break
        }
    }
    
}


// MARK: UITextFieldDelegate
extension JourneyViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //TODO: Invoke search
        
        return true
    }
    
}
