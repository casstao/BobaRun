import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import MapKit


class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let GOOGLE_URL = "https://api.yelp.com/v3/businesses/search"
    let rad = "10000"
    let term = "boba"
    let limit = "20"
    let auth_header = ["Authorization":"Bearer ywBHE7wMOSh-_lw7shZBsIdfE_z1Z1yyMs0h7y_JY2hJPo1GiK7z_dX5AfAkky0Eu8WbI6E1Tj-enHndLISi_DcDe3dxnzfKu0Zbncg22odu6prpUKbqpb0EFfpoW3Yx"]
    var didwork = false

    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    var bobalat = 0.0000000
    var bobalong = 0.0000000
    var bobaname = ""
    var check_int = -1
    var weatherJSON : JSON = []
    
    //Pre-linked IBOutlets
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var bobaRunTitle: UILabel!
    @IBOutlet weak var button2Constraint: NSLayoutConstraint!
    @IBOutlet weak var button1Constraint: NSLayoutConstraint!
    @IBOutlet weak var randomButton: roundButton!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var Rating: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        randomButton.layer.cornerRadius = 4
        button.layer.cornerRadius = 4
        blurEffect.layer.cornerRadius = 4
        self.blurEffect.clipsToBounds = true
        button1Constraint.constant -= view.bounds.width
        button2Constraint.constant -= view.bounds.width
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {self.button1Constraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()}, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {self.button2Constraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()}, completion: nil)
    }
    
    @IBAction func randomButton(_ sender: UIButton)
    {
        let theButton = sender 
        let bounds = theButton.bounds
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
        theButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)})
        {
        (success:Bool) in
            if success
            {
                theButton.bounds = bounds
            }
        }
        if (self.didwork == true)
        {
            var random_int = Int(arc4random_uniform(UInt32(Int(self.weatherJSON["businesses"].count))-1))
            while (random_int == check_int)
            {
                 random_int = Int(arc4random_uniform(UInt32(Int(self.weatherJSON["businesses"].count))-1))
            }
            check_int = random_int
            self.bobalat = Double(self.weatherJSON["businesses"][random_int]["coordinates"]["latitude"].doubleValue)
        
            self.bobalong = Double(self.weatherJSON["businesses"][random_int]["coordinates"]["longitude"].doubleValue)
            
            self.resultLabel.text = self.weatherJSON["businesses"][random_int]["name"].stringValue
            self.Rating.text = String("Rating: " + self.weatherJSON["businesses"][random_int]["rating"].stringValue + "/5")
        }
        else
        {
            theButton.bounds = bounds
        }
    }
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String:String])
    {
        self.resultLabel.text = "Connecting..."
        Alamofire.request(url, method: .get, parameters:parameters, headers:auth_header).responseJSON
            {
            
                response in
                if response.result.isSuccess
                {
                    self.resultLabel.text = ""
                    self.didwork = true
                    print("Success! Got the boba data")
                    self.weatherJSON = JSON(response.result.value!)
                    
                   
                }
                else
                {
                    print("Error \(String(describing: response.result.error))")
                    self.resultLabel.text = "Connection Issues"
                }
            
        }
    }

    @IBAction func AppleMapsPressed(_ sender: UIButton)
    {
        let latitude:CLLocationDegrees = CLLocationDegrees(self.bobalat)
        let longitude:CLLocationDegrees = CLLocationDegrees(self.bobalong)
        let regionDistance:CLLocationDistance = 300
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate:coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.resultLabel.text
        mapItem.openInMaps(launchOptions: options)
    }
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[locations.count - 1]
        if (location.horizontalAccuracy > 0)
        {
            self.locationManager.stopUpdatingLocation()
            let params : [String : String] = ["term":term, "latitude": String(location.coordinate.latitude), "longitude":String(location.coordinate.longitude), "radius":rad, "limit":limit]
            getWeatherData(url: GOOGLE_URL, parameters: params)
        }
    }
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        resultLabel.text = "Location Unavailable"
    }
            
}

class roundButton: UIButton
{
    func applyDesign()
    {
    self.backgroundColor = UIColor.darkGray
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.shadowColor = UIColor.darkGray.cgColor
    self.layer.shadowRadius = 4
    self.layer.shadowOpacity = 0.5
    }
}
    




