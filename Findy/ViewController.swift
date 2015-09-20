//
//  ViewController.swift
//  Findy
//
//  Created by Oskar Zhang on 9/19/15.
//  Copyright © 2015 FindyTeam. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate,UISearchBarDelegate
{
    let locationManager: CLLocationManager = CLLocationManager() // the object that provides us the location data
    var userLocation: CLLocation!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!
    var searchController:UISearchController!
    var searchResultsTableViewController:UITableViewController!
    var storePins:[CustomPin] = []
    var profileView:UIView!
    var images:[String] = []
    var names:[String] = []
    var prices:[Int] = []
    var currentSelection:Int!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        searchResultsTableViewController = UITableViewController()
        searchResultsTableViewController.view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        searchController = UISearchController(searchResultsController: searchResultsTableViewController)
        //        searchResultsTableViewController.tableView.
        
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        self.navigationItem.titleView = searchController.searchBar
        searchResultsTableViewController.tableView.delegate = self
        searchResultsTableViewController.tableView.dataSource = self
        profileView = ProfileView.loadNib()
        profileView.frame = CGRectMake(0, -150, UIScreen.mainScreen().bounds.width, 200)
        self.view.addSubview(profileView)
        self.getUserLocation(self)
        
        print("Requesting your current location...")
        getUserLocation(self)
        view.insertSubview(toolBar, atIndex: 1)
    }
    
    
    @IBAction func didClickProfile(sender: AnyObject)
    {
        if self.profileView.frame.origin.y == -150
        {
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.profileView.frame = CGRectMake(0, 50, UIScreen.mainScreen().bounds.width, 150)
                
                }, completion: nil)
        }
        else
        {
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.profileView.frame = CGRectMake(0, -150, UIScreen.mainScreen().bounds.width, 150)
                
                }, completion: nil)
        }
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapOnGetLocation(sender: AnyObject)
    {
        getUserLocation(self)
    }
    
    func getUserLocation(sender: AnyObject)
    {
        locationManager.delegate = self // instantiate the CLLocationManager object
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.startUpdatingLocation()
        // continuously send the application a stream of location data
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let newLocation = locations.last!
        mapView.setCenterCoordinate(newLocation.coordinate, animated: true)
        let viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
        mapView.setRegion(viewRegion, animated: true)
        
        manager.stopUpdatingLocation()
        
    }
    
    // Display the custom view
    func addStore(coordinate: CLLocationCoordinate2D, price: Int)
    {
        print("addStore called!")
        let randomPair = randomOffset()
        print(coordinate)
        let newCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + Double(randomPair.0), longitude: coordinate.longitude   +  Double(randomPair.1))
        
        print(newCoordinate)
        let storePin = CustomPin(title: "", locationName: "", discipline: "", coordinate: newCoordinate)
        
        storePins.append(storePin)
        mapView.addAnnotation(storePin)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation
        {
            return mapView.dequeueReusableAnnotationViewWithIdentifier("")
        }
        else
        {
            let view = MKAnnotationView(frame: CGRectMake(0, 0, 100, 20))
            view.backgroundColor = UIColor.whiteColor()
            let label = UILabel(frame: CGRectMake(0, 0,100, 20))
            let price = priceRandomizer(prices[currentSelection])
            label.text = "$\(price).99"
            view.addSubview(label)
            
            return view
        }
    }
    
    
    func priceRandomizer(price:Int) -> Int
    {
        let range = Int(Double(price) * 0.20)
        let rangeUInt = UInt32(range)
        let priceUInt = UInt32(price)
        return Int(priceUInt +   arc4random_uniform(rangeUInt) - rangeUInt/2 )
    }
    func randomOffset() ->(Double,Double)
    {
        let number1 = (0.01 - 0) * Double(Double(arc4random()) / Double(UInt32.max))
        let number2 = (0.01 - 0) * Double(Double(arc4random()) / Double(UInt32.max))
        return (number1,number2)
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        WalmartClient.search(searchController.searchBar.text!) { (names,images , prices) -> Void in
            self.names = names
            self.images = images
            self.prices = prices
            self.searchResultsTableViewController.tableView.reloadData()
        }
        
    }
    
    //        func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    //            let annotation1 = self.storePins[0]
    //            let identifier = "pin"
    //            var view: MKPinAnnotationView
    //            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView{
    //                dequeuedView.annotation = annotation1
    //                view = dequeuedView
    //            } else {
    //                view = MKPinAnnotationView(annotation: annotation1, reuseIdentifier:identifier)
    //                view.calloutOffset = CGPoint(x: -5, y: 5)
    //                view.pinColor = MKPinAnnotationColor.Purple
    //            }
    //            return view
    //        }
}
//
//

extension ViewController: UISearchControllerDelegate
{
    func willPresentSearchController(searchController: UISearchController) {
        //caculate frame here
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navigationBarFrame = navigationController!.navigationBar.frame
        let tableViewY = navigationBarFrame.height + statusBarHeight
        let tableViewHeight = mapView.frame.height - navigationBarFrame.height  - toolBar.frame.height
        
        searchResultsTableViewController.tableView.frame = CGRectMake(0, tableViewY, navigationBarFrame.width, tableViewHeight)
        
        
    }
    override func viewWillLayoutSubviews() {
    }
    func presentSearchController(searchController: UISearchController) {
    }
    func didPresentSearchController(searchController: UISearchController) {
    }
}

class CustomPin: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let discipline: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
extension ViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        if names.count == 0
        {
            return cell
        }
        cell.textLabel!.text =  "\(names[indexPath.item])  $\(prices[indexPath.item])"
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentSelection = indexPath.item
        for i in 0...10
        {
            addStore(mapView.userLocation.coordinate, price: prices[currentSelection])
        }
        searchController.active = false
    }
}