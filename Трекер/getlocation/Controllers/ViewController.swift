import UIKit
import CoreData
import MapKit
import CoreLocation
import SystemConfiguration

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    weak var timer: Timer?
    var data: [NSManagedObject] = []
    var refreshFlag = false
    let foregroundManager = CLLocationManager()
    let pickerOptions = ["5 seconds", "10 seconds", "30 seconds", "1 minute", "5 minutes", "10 minutes", "30 minutes", "1 hour", "5 hours", "12 hours", "24 hours"]
    let refreshRateOptions = [5.0, 10.0, 30.0, 60.0, 300.0, 600.0, 1800.0, 3600.0, 18000.0, 43200.0, 86400.0]
    var refreshRatevalue: Double = 0
    var objectID: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearBase()
        objectTextField.delegate = self
        refreshTimePicker.dataSource = self
        refreshTimePicker.delegate = self
        foregroundManager.delegate = self
        
        foregroundManager.requestAlwaysAuthorization()
        foregroundManager.requestWhenInUseAuthorization()
        foregroundManager.allowsBackgroundLocationUpdates = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if isInternetAvailable() == false{
            self.throwError(message: "Нет подключения. Данные будут сохранены локально для последующей выгрузки")
        }
        
    }
    func throwError(message: String){   //alert, выбрасывающий ошибки при работе с программой
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        objectID = objectTextField.text
        return false
    }
    func sendData(lat: CLLocationDegrees, lon: CLLocationDegrees, date: String){    //отправка данных на сервер
        
        let adress = "http://trackmygps.000webhostapp.com/index.php?action=insert&latitude=\(lat)&longitude=\(lon)&objectID=\(self.objectID!)&date=\(String(describing: date))"
        let url = URL(string: adress.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard data != nil else {
                print("Data is empty")
                return
            }
        }
        
        task.resume()
    }
    func getTodayString() -> String{    // получение текущей даты
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
    func clearBase(){   //очистка базы данных
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Data"))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
        
    }
    func saveToDB(lat: CLLocationDegrees, lon: CLLocationDegrees, date: String){    //сохранение в бд
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
        
        let dataToSave = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        dataToSave.setValue(lat, forKeyPath: "latitude")
        dataToSave.setValue(lon, forKey: "longitude")
        dataToSave.setValue(date, forKey: "date")
        dataToSave.setValue(self.objectID, forKey: "objectid")

        do {
            try managedContext.save()
            data.append(dataToSave)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func updateLocation(){  //обновление геопозиции
        var savedToDB = false
        timer = Timer.scheduledTimer(withTimeInterval: refreshRatevalue, repeats: true) { (timer) in
            let latitude = self.foregroundManager.location?.coordinate.latitude
            let longitude = self.foregroundManager.location?.coordinate.longitude
            let timeStamp = self.getTodayString()
            if self.isInternetAvailable() == false{
                self.saveToDB(lat: latitude!, lon: longitude!, date: timeStamp)
                savedToDB = true
            }
            else if self.isInternetAvailable() == true{
                if savedToDB == true{
                    guard let appDelegate =
                        UIApplication.shared.delegate as? AppDelegate else {
                            return
                    }
                    let managedContext =
                        appDelegate.persistentContainer.viewContext
                    let fetchRequest =
                        NSFetchRequest<NSManagedObject>(entityName: "Data")
                    do {
                        print("DATABASE OUTPUT:")
                        self.data = try managedContext.fetch(fetchRequest)
                        for alldata in self.data {
                            print(alldata.value(forKey: "latitude")!, alldata.value(forKey: "longitude")!, alldata.value(forKey: "date")!, alldata.value(forKey: "objectid")!)
                            self.sendData(lat: alldata.value(forKey: "latitude") as! CLLocationDegrees, lon: alldata.value(forKey: "longitude") as! CLLocationDegrees, date: alldata.value(forKey: "date") as! String)
                        }
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    self.clearBase()
                    savedToDB = false
                    return
                } else if savedToDB == false{
                    self.sendData(lat: latitude!, lon: longitude!, date: timeStamp)
                }
            }
            self.foregroundManager.desiredAccuracy = 100
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocationInfo.text = "Latitude: \(location.coordinate.latitude)\nLongitude: \(location.coordinate.longitude)\nAltitude: \(location.altitude)\nSpeed: \(location.speed) mps\nAccuracy: +/- \(location.horizontalAccuracy)m"
        }
    }
    
    func isInternetAvailable() -> Bool  //проверка доступности интернет-соединения
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    @IBOutlet weak var objectTextField: UITextField!
    @IBOutlet weak var additionalInfo: UILabel!
    @IBOutlet weak var currentLocationInfo: UILabel!
    @IBOutlet weak var refreshTimePicker: UIPickerView!
    @IBAction func setPicker(_ sender: Any) {
        refreshFlag = true
        refreshRatevalue = refreshRateOptions[refreshTimePicker.selectedRow(inComponent: 0)]
        objectID = objectTextField.text
        if self.objectID == nil || self.objectID == ""{
            self.throwError(message: "Cначала введите ID объекта!")
            return
        }
        additionalInfo.text = "Refreshrate is \(refreshRatevalue) seconds"
        foregroundManager.startUpdatingLocation()
        updateLocation()
    }
}
