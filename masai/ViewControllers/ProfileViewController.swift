//
//  ProfileViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 14.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import Auth0


class ProfileViewController: MasaiBaseViewController {
    
    // MARK: Properties
    
    private var didSetupForms = false
    private var profile: UserProfile!
    private var choices: ProfileChoices!
    private var isVisible = false
    private var formNotificationToken: Any?
    
    private static let contactInformationSectionIdentifier = "contact_details"
    
    
    // MARK: UI
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private var switchButtonsView: ProfileSwitchButtonView!
    private let pagedScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.isScrollEnabled = false
        return sv
    }()
    private var personalDataForm: Form?
    private var personalDataFormView: UIView?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: AwsBackendManager.didUpdateUserProfileNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.presentedViewController is ProfileDetailViewController {
                strongSelf.dismiss(animated: true, completion: nil)
            }
            
            strongSelf.profile = CacheManager.retrieveUserProfile()
            
            strongSelf.clearForms()
            
            if strongSelf.isVisible {
                strongSelf.retrieveProfileChoicesAndSetupForms()
            }
        })
        
        formNotificationToken = NotificationCenter.default.addObserver(forName: FormNotifications.formValueChanged, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo,
                let form = userInfo["form"] as? Form else {
                    return
            }
            
            // If the user changed his first or last name, we'll reconnect to all services (so that the new name is displayed on the server side)
            var shouldReconnect = false
            if let personalValues = form.values["personal"],
                let profile = CacheManager.retrieveUserProfile() {
                for val in personalValues {
                    if let firstName = val["first_name"] as? String,
                        profile.firstName != firstName {
                        shouldReconnect = true
                    }
                    if let lastName = val["last_name"] as? String,
                        profile.lastName != lastName {
                        shouldReconnect = true
                    }
                }
            }
            
            if shouldReconnect {
                HostConnectionManager.shared.forceReconnectToAllActiveHosts({ (didSuccessfullyConnectionAllHosts: Bool) in
                })
            }
        }
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profile = CacheManager.retrieveUserProfile() ?? UserProfile()
        retrieveProfileChoicesAndSetupForms()
        
        isVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isVisible = false
    }
    
    deinit {
        if let token = formNotificationToken {
            NotificationCenter.default.removeObserver(token)
            formNotificationToken = nil
        }
    }
    
    
    // MARK: BaseViewController
    
    override func isNavigationBarRightItemVisible() -> Bool {
        return true
    }
    
    override func titleForNavigationBarRightItem() -> String? {
        return "logout".localized
    }
    
    override func onPressedNavigationBarRightButton() {
        self.dismiss(animated: true, completion:nil);
        AppDelegate.logout()
    }
    
    
    // MARK: Setup
    
    private func retrieveProfileChoicesAndSetupForms() {
        ProfileChoices.retrieve({ [unowned self] (choices) in
            guard let choices = choices else {
                //TODO: Show error
                return
            }
            
            self.choices = choices
            
            DispatchQueue.global(qos: .default).async { [unowned self] in
                self.setupForms()
            }
        }, willLoadFromBackend: { [unowned self] in
            DispatchQueue.main.async {
                self.clearForms()
                self.showLoadingIndicator(true)
            }
        })
    }
    
    private func setup() {
        title = "profile_title".localized
        
        view.backgroundColor = UIColor(red: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1.0)
        
        switchButtonsView = ProfileSwitchButtonView(titles: [
            "profile_switchbutton_my_info".localized,
            "profile_switchbutton_preferences".localized,
            "profile_switchbutton_access".localized,
            ], images: [
                #imageLiteral(resourceName: "subnav-my-data"),
                #imageLiteral(resourceName: "subnav-preferences"),
                #imageLiteral(resourceName: "subnav-permissions"),
            ])
        switchButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchButtonsView)
        switchButtonsView.pin.edges([.leading, .top, .trailing]).to(view).activate()
        
        switchButtonsView.transitionToButtonAnimationClosure = { [unowned self] (selectedIndex: Int, selectedTitle: String) in
            let contentOffset = CGPoint(x: self.view.bounds.size.width * CGFloat(selectedIndex), y: 0)
            self.pagedScrollView.setContentOffset(contentOffset, animated: false)
            self.view.endEditing(true)
        }
        
        view.addSubview(pagedScrollView)
        pagedScrollView.topAnchor.constraint(equalTo: switchButtonsView.bottomAnchor).isActive = true
        pagedScrollView.pin.edges([.leading, .bottom, .trailing]).to(view).activate()
        
        profile = CacheManager.retrieveUserProfile() ?? UserProfile()
    }
    
    private func setupForms() {
        guard didSetupForms == false else {
            highlightMandatorySections()
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.personalDataForm = self.createPersonalDataForm()
            self.personalDataFormView = self.personalDataForm!.createView()
            self.personalDataFormView!.translatesAutoresizingMaskIntoConstraints = false
            self.pagedScrollView.addSubview(self.personalDataFormView!)
            
            let travelPrefForm = self.createTravelPreferencesForm().createView()
            travelPrefForm.translatesAutoresizingMaskIntoConstraints = false
            self.pagedScrollView.addSubview(travelPrefForm)
            
            let accessControlForm = self.createAccessManagementForm().createView()
            accessControlForm.translatesAutoresizingMaskIntoConstraints = false
            self.pagedScrollView.addSubview(accessControlForm)
            
            self.personalDataFormView!.pin.edges([.top, .leading, .bottom]).to(self.pagedScrollView).activate()
            self.personalDataFormView!.heightAnchor.constraint(equalTo: self.pagedScrollView.heightAnchor, multiplier: 1.0).isActive = true
            self.personalDataFormView!.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
            
            travelPrefForm.pin.edges([.top, .bottom]).to(self.pagedScrollView).activate()
            travelPrefForm.heightAnchor.constraint(equalTo: self.pagedScrollView.heightAnchor, multiplier: 1.0).isActive = true
            travelPrefForm.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
            travelPrefForm.pin.leading.to(self.personalDataFormView!.trailingAnchor).activate()
            travelPrefForm.pin.trailing.to(accessControlForm.leadingAnchor).activate()
            
            accessControlForm.pin.edges([.top, .trailing, .bottom]).to(self.pagedScrollView).activate()
            accessControlForm.heightAnchor.constraint(equalTo: self.pagedScrollView.heightAnchor, multiplier: 1.0).isActive = true
            accessControlForm.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
            
            self.showLoadingIndicator(false)
            self.didSetupForms = true
            
            self.highlightMandatorySections()
        }
    }
    
    private func createPersonalDataForm() -> Form {
        let form = Form()
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "personal", title: "profile_personal_info".localized, image: #imageLiteral(resourceName: "icon-personal-info")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "personal", title: "profile_personal_info".localized, image: #imageLiteral(resourceName: "icon-personal-info")),
                        cells: [
                            ProfileFormTextCell(identifier: "title", title: "academic_title".localized, value: self.profile.title),
                            ProfileFormTextCell(identifier: "first_name", title: "first_name".localized, value: self.profile.firstName),
                            ProfileFormTextCell(identifier: "middle_name", title: "middle_name".localized, value: self.profile.middleName),
                            ProfileFormTextCell(identifier: "last_name", title: "last_name".localized, value: self.profile.lastName),
                            ProfileFormSelectionCell(identifier: "nationality", title: "nationality".localized, value: self.profile.nationality, possibleValues: self.values(from: self.choices.passportCountryOfIssuance), sort: true),
                            ProfileFormDateSelectionCell(identifier: "birth_date", title: "birth_date".localized, value: self.profile.birthDate),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "contact", title: "private_address".localized, image: #imageLiteral(resourceName: "icon-address")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "contact", title: "private_address".localized, image: #imageLiteral(resourceName: "icon-address")),
                        cells: [
                            ProfileFormTextCell(identifier: "address_line_1", title: "address_line_1".localized, value: self.profile.addressLine1),
                            ProfileFormTextCell(identifier: "address_line_2", title: "address_line_2".localized, value: self.profile.addressLine2),
                            ProfileFormTextCell(identifier: "city", title: "city".localized, value: self.profile.city),
                            ProfileFormTextCell(identifier: "state", title: "state".localized, value: self.profile.state),
                            ProfileFormTextCell(identifier: "zip", title: "zip".localized, value: self.profile.zipCode),
                            ProfileFormSelectionCell(identifier: "country", title: "country".localized, value: self.profile.country, possibleValues: self.values(from: self.choices.passportCountryOfIssuance), sort: true),
                            FormChecklistCell(identifier: "billing_sync", title: "billing_address".localized, value: (self.profile.keepBillingAndPrivateIdentical ? ["keep_billing_sync"] : []), possibleValues: [ FormChecklistItemValue(identifier: "keep_billing_sync", title: "keep_billing_address_identical".localized) ]),
                        ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: ProfileViewController.contactInformationSectionIdentifier, title: "contact_info".localized, image: #imageLiteral(resourceName: "icon-contactinfo")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: ProfileViewController.contactInformationSectionIdentifier, title: "contact_info".localized, image: #imageLiteral(resourceName: "icon-contactinfo")),
                        cells: [
                            ProfileFormTextCell(identifier: "contact_email", title: "contact_email".localized, value: self.profile.contactEmailAddress),
                            ProfileFormTextCell(identifier: "primary_email", title: "booking_email".localized, value: self.profile.primaryEmailAddress, validator: EmailValidator(validateImmediately: true)),
                            ProfileFormPhoneNumberCell(identifier: "primary_phone", title: "phone_number".localized, value: self.profile.primaryPhoneNumber, validator: PhoneNumberValidator(), transformator: PhoneNumberTransformator()),
                            ProfileFormLabelCell(identifier: "primary_email_hint", title: "contact_info_email_description".localized),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "billing_address", title: "billing_address".localized, image: #imageLiteral(resourceName: "icon-billing-address")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let disableTextFields = self.profile.keepBillingAndPrivateIdentical
                
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "billing_address", title: "billing_address".localized, image: #imageLiteral(resourceName: "icon-billing-address")),
                        cells: [
                            ProfileFormTextCell(identifier: "company_name", title: "company_name".localized, value: self.profile.companyName),
                            ProfileFormTextCell(identifier: "address_line_1", title: "address_line_1".localized, value: self.profile.companyAddressLine1).set(disabled: disableTextFields),
                            ProfileFormTextCell(identifier: "address_line_2", title: "address_line_2".localized, value: self.profile.companyAddressLine2).set(disabled: disableTextFields),
                            ProfileFormTextCell(identifier: "city", title: "city".localized, value: self.profile.companyCity).set(disabled: disableTextFields),
                            ProfileFormTextCell(identifier: "state", title: "state".localized, value: self.profile.companyState).set(disabled: disableTextFields),
                            ProfileFormTextCell(identifier: "zip", title: "zip".localized, value: self.profile.companyZip).set(disabled: disableTextFields),
                            ProfileFormSelectionCell(identifier: "country", title: "country".localized, value: self.profile.companyCountry, possibleValues: self.values(from: self.choices.passportCountryOfIssuance), sort: true).set(disabled: disableTextFields),
                            ProfileFormTextCell(identifier: "vat", title: "vat".localized, value: self.profile.companyVatId),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        return form
    }
    
    private func createTravelPreferencesForm() -> Form {
        let form = Form()
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "passport", title: "passport".localized, image: #imageLiteral(resourceName: "icon-passport")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "passport", title: "passport".localized, image: #imageLiteral(resourceName: "icon-passport")),
                        cells: [
                            ProfileFormTextCell(identifier: "number", title: "passport_number".localized, value: self.profile.passportNumber),
                            ProfileFormSelectionCell(identifier: "country", title: "country_of_issuance".localized, value: self.profile.passportCountryOfIssuance, possibleValues: self.values(from: self.choices.passportCountryOfIssuance), sort: true),
                            ProfileFormTextCell(identifier: "city", title: "city_of_issuance".localized, value: self.profile.passportCityOfIssuance),
                            ProfileFormDateSelectionCell(identifier: "date_issued", title: "date_issued".localized, value: self.profile.passportDateOfIssuance),
                            ProfileFormDateSelectionCell(identifier: "expiry", title: "expiry_date".localized, value: self.profile.passportExpiryDate),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "esta", title: "ESTA (Electronihorization - USA)", image: #imageLiteral(resourceName: "icon-esta")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "esta", title: "ESTA (Electronihorization - USA)", image: #imageLiteral(resourceName: "icon-esta")),
                        cells: [
                            ProfileFormTextCell(identifier: "application_number", title: "application_number".localized, value: self.profile.estaApplicationNumber),
                            ProfileFormDateSelectionCell(identifier: "valid_until", title: "valid_until".localized, value: self.profile.estaValidUntil),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "hotel", title: "hotel".localized, image: #imageLiteral(resourceName: "icon-hotel")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "hotel", title: "hotel".localized, image: #imageLiteral(resourceName: "icon-hotel")),
                        cells: [
                            FormChecklistCell(identifier: "category", title: "category".localized, value: self.profile.hotelCategory, possibleValues: self.values(from: self.choices.hotelCategories)),
                            FormChecklistCell(identifier: "hotel_type", title: "hotel_type".localized, value: self.profile.hotelType, possibleValues: self.values(from: self.choices.hotelTypes)),
                            FormChecklistCell(identifier: "location", title: "location".localized, value: self.profile.hotelLocation, possibleValues: self.values(from: self.choices.hotelLocation)),
                            FormChecklistCell(identifier: "bed_type", title: "bed_type".localized, value: self.profile.hotelBedType, possibleValues: self.values(from: self.choices.hotelBedTypes)),
                            FormChecklistCell(identifier: "room_standard", title: "room_standard".localized, value: self.profile.hotelRoomStandard, possibleValues: self.values(from: self.choices.hotelRoomStandards)),
                            FormChecklistCell(identifier: "room_location", title: "room_location".localized, value: self.profile.hotelRoomLocation, possibleValues: self.values(from: self.choices.hotelRoomLocation)),
                            FormChecklistCell(identifier: "amenities", title: "amenities".localized, value: self.profile.hotelAmenities, possibleValues: self.values(from: self.choices.hotelAmenities)),
                            FormChecklistCell(identifier: "preferred_hotels", title: "preferred_hotels".localized, value: self.profile.hotelChains, possibleValues: self.values(from: self.choices.hotelChains)),
                            FormChecklistCell(identifier: "hotels_to_avoid", title: "hotels_to_avoid".localized, value: self.profile.hotelChainsBlacklist, possibleValues: self.values(from: self.choices.hotelChainsBlacklist)),
                            ProfileFormListFieldListCell(identifier: "hotel_loyalty", title: "loyalty_programs".localized, value: self.profile.hotelLoyaltyPrograms, possibleValues: self.values(from: self.choices.hotelLoyaltyProgram), form: form),
                            ProfileFormDateSelectionCell(identifier: "loyalty_date", title: "loyalty_program_valid_until".localized, value: self.profile.hotelLoyaltyValidUntil),
                            ProfileFormTextCell(identifier: "anything_else", title: "anything_else".localized, value: self.profile.hotelAnythingElse),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "flights", title: "flights".localized, image: #imageLiteral(resourceName: "icon-flights")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "flights", title: "flights".localized, image: #imageLiteral(resourceName: "icon-flights")),
                        cells: [
                            ProfileFormSelectionCell(identifier: "booking_class_short_haul", title: "booking_class_short_haul".localized, value: self.profile.flightBookingClassShortHaul, possibleValues: self.values(from: self.choices.flightBookingClassShortHaul), sort: false),
                            ProfileFormSelectionCell(identifier: "booking_class_medium_haul", title: "booking_class_medium_haul".localized, value: self.profile.flightBookingClassMediumHaul, possibleValues: self.values(from: self.choices.flightBookingClassMediumHaul), sort: false),
                            ProfileFormSelectionCell(identifier: "booking_class_long_haul", title: "booking_class_long_haul".localized, value: self.profile.flightBookingClassLongHaul, possibleValues: self.values(from: self.choices.flightBookingClassLongHaul), sort: false),
                            ProfileFormSelectionCell(identifier: "preferred_seat", title: "preferred_seat".localized, value: self.profile.flightPreferredSeat, possibleValues: self.values(from: self.choices.flightSeat), sort: false),
                            ProfileFormSelectionCell(identifier: "preferred_row", title: "preferred_row".localized, value: self.profile.flightPreferredRow, possibleValues: self.values(from: self.choices.flightSeatRow), sort: false),
                            ProfileFormSelectionCell(identifier: "meal_preferences", title: "meal_preferences".localized, value: self.profile.flightMealPreference, possibleValues: self.values(from: self.choices.flightMealPreference), sort: false),
                            FormChecklistCell(identifier: "options", title: "options".localized, value: self.profile.flightOptions, possibleValues: self.values(from: self.choices.flightOptions)),
                            FormChecklistCell(identifier: "preferred_airlines", title: "preferred_airlines".localized, value: self.profile.flightAirlines, possibleValues: self.values(from: self.choices.flightAirlines)),
                            FormChecklistCell(identifier: "airlines_to_avoid", title: "airlines_to_avoid".localized, value: self.profile.flightAirlineBlacklist, possibleValues: self.values(from: self.choices.flightAirlinesBlacklist)),
                            ProfileFormListFieldListCell(identifier: "flights_loyalty", title: "loyalty_programs".localized, value: self.profile.flightLoyaltyPrograms, possibleValues: self.values(from: self.choices.airlineLoyaltyPrograms), form: form),
                            ProfileFormDateSelectionCell(identifier: "loyalty_date", title: "loyalty_program_valid_until".localized, value: self.profile.flightLoyaltyValidUntil),
                            ProfileFormTextCell(identifier: "anything_else", title: "anything_else".localized, value: self.profile.flightAnythingElse),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "rental_car", title: "rental_car".localized, image: #imageLiteral(resourceName: "icon-rental-car")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "rental_car", title: "rental_car".localized, image: #imageLiteral(resourceName: "icon-rental-car")),
                        cells: [
                            ProfileFormSelectionCell(identifier: "booking_class", title: "booking_class".localized, value: self.profile.carBookingClass, possibleValues: self.values(from: self.choices.carBookingClass), sort: false),
                            ProfileFormSelectionCell(identifier: "car_type", title: "car_type".localized, value: self.profile.carType, possibleValues: self.values(from: self.choices.carType), sort: false),
                            FormChecklistCell(identifier: "car_preferences", title: "car_preferences".localized, value: self.profile.carPreferences, possibleValues: self.values(from: self.choices.carPreferences)),
                            FormChecklistCell(identifier: "extras", title: "extras".localized, value: self.profile.carExtras, possibleValues: self.values(from: self.choices.carExtras)),
                            FormChecklistCell(identifier: "preferred_rental_companies", title: "preferred_rental_companies".localized, value: self.profile.carPreferredRentalCompanies, possibleValues: self.values(from: self.choices.carRentalCompanies)),
                            ProfileFormListFieldListCell(identifier: "rental_car_loyalty", title: "loyalty_programs".localized, value: self.profile.carLoyaltyPrograms, possibleValues: self.values(from: self.choices.carLoyaltyPrograms), form: form),
                            ProfileFormDateSelectionCell(identifier: "loyalty_date", title: "loyalty_program_valid_until".localized, value: self.profile.carLoyaltyValidUntil),
                            ProfileFormTextCell(identifier: "anything_else", title: "anything_else".localized, value: self.profile.carAnythingElse),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "train", title: "train".localized, image: #imageLiteral(resourceName: "icon-train")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = ProfileDetailViewController()
                detailVC.loadFormClosure = { [unowned self] (vc) in
                    let form = Form()
                    form.add(section: FormSection(
                        header: FormSectionHeader(identifier: "train", title: "train".localized, image: #imageLiteral(resourceName: "icon-train")),
                        cells: [
                            ProfileFormSelectionCell(identifier: "train_travel_class", title: "train_travel_class".localized, value: self.profile.trainTravelClass, possibleValues: self.values(from: self.choices.trainTravelClass), sort: false),
                            ProfileFormSelectionCell(identifier: "train_compartment_type", title: "train_compartment_type".localized, value: self.profile.trainCompartmentType, possibleValues: self.values(from: self.choices.trainCompartmentType), sort: false),
                            ProfileFormSelectionCell(identifier: "train_seat_location", title: "train_seat_location".localized, value: self.profile.trainSeatLocation, possibleValues: self.values(from: self.choices.trainSeatLocation), sort: false),
                            ProfileFormSelectionCell(identifier: "train_zone", title: "train_zone".localized, value: self.profile.trainZone, possibleValues: self.values(from: self.choices.trainZone), sort: false),
                            FormChecklistCell(identifier: "train_preferred", title: "train_preferred".localized, value: self.profile.trainPreferred, possibleValues: self.values(from: self.choices.trainPreferred)),
                            FormChecklistCell(identifier: "train_specific_booking", title: "train_specific_booking".localized, value: self.profile.trainSpecificBooking, possibleValues: self.values(from: self.choices.trainSpecificBooking)),
                            FormChecklistCell(identifier: "train_mobility_service", title: "train_mobility_service".localized, value: self.profile.trainMobilityService, possibleValues: self.values(from: self.choices.trainMobilityService)),
                            FormChecklistCell(identifier: "train_ticket", title: "train_ticket".localized, value: self.profile.trainTicket, possibleValues: self.values(from: self.choices.trainTicket)),
                            ProfileFormListFieldListCell(identifier: "train_loyalty", title: "loyalty_programs".localized, value: self.profile.trainLoyaltyPrograms, possibleValues: self.values(from: self.choices.trainLoyaltyPrograms), form: form),
                            ProfileFormDateSelectionCell(identifier: "loyalty_date", title: "loyalty_program_valid_until".localized, value: self.profile.trainLoyaltyValidUntil),
                            ProfileFormTextCell(identifier: "anything_else", title: "anything_else".localized, value: self.profile.trainAnythingElse),
                            ], form: form))
                    let formView = form.createView()
                    self.add(view: formView, to: vc)
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        return form
    }
    
    private func createAccessManagementForm() -> Form {
        let form = Form()
        
        form.add(section: FormPushSection(
            header: FormSectionHeader(identifier: "unused", title: "profile_access_granted".localized, image: #imageLiteral(resourceName: "icon-granted-access")),
            form: form,
            didTapClosure: { [unowned self] (section) in
                let detailVC = AccessManagementViewController()
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        ))
        
        return form
    }
    
    private func add(view: UIView, to detailViewController: ProfileDetailViewController) {
        detailViewController.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinEdges(to: detailViewController.view, insets: UIEdgeInsets(top: 0, left: 0, bottom: -(self.tabBarController?.tabBar.frame.size.height ?? 0), right: 0)).activate()
    }
    
    
    // MARK: Private
    
    private func showLoadingIndicator(_ show: Bool) {
        if show {
            let showClosure = { [unowned self] in
                self.loadingIndicator.startAnimating()
            }
            
            if !Thread.isMainThread {
                DispatchQueue.main.sync {
                    showClosure()
                }
            } else {
                showClosure()
            }
            
        } else {
            let hideClosure = { [unowned self] in
                self.loadingIndicator.stopAnimating()
            }
            
            if !Thread.isMainThread {
                DispatchQueue.main.sync {
                    hideClosure()
                }
            } else {
                hideClosure()
            }
        }
    }
    
    private func clearForms() {
        for subview in self.pagedScrollView.subviews {
            subview.removeFromSuperview()
        }
        didSetupForms = false
    }
    
    private func values(from: [(ProfileChoice.Title, ProfileChoice.Value)]) -> [FormSelectionValue] {
        let values = from.map({ FormSelectionValue(identifier: $0.1, title: $0.0) })
        return values
    }
    
    private func values(from: [(ProfileChoice.Title, ProfileChoice.Value)]) -> [FormChecklistItemValue] {
        let values = from.map({ FormChecklistItemValue(identifier: $0.1, title: $0.0) })
        return values
    }
    
    private func values(from: [(ProfileChoice.Title, ProfileChoice.Value)]) -> [FormListFieldItemValue] {
        let values = from.map({ FormListFieldItemValue(identifier: $0.1, title: $0.0) })
        return values
    }
    
    private func highlightMandatorySections() {
        personalDataForm?.updateSection(withHeaderIdentifier: ProfileViewController.contactInformationSectionIdentifier, updateClosure: { (section: FormSectionType) -> FormSectionType in
            guard let actualSection = section as? FormPushSection else {
                return section
            }
            
            let shouldHighlight = !profile.hasRequiredEmailField()
            actualSection.setAlertHighlighted(shouldHighlight)
            return actualSection
        }, completionClosure: {
            //TODO: Render section again into form view
        })
    }
    
}
