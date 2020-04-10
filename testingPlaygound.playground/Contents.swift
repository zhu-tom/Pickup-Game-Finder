import Foundation

let session = URLSession(configuration: .default)
let url = URL(string: "http://localhost/Apps/RunItBack/getPosts.php")!
let task = session.dataTask(with: url) {(data,response,error) in
    if error != nil {
        print("Data retrieval failed")
    } else {
        do {
            let arr = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            for i in 0..<arr.count {
                let el = arr[i] as! NSDictionary
                print(el["id"]!
            }
        }
        catch let error as NSError {
            print(error)
        }
    }
}
task.resume()
