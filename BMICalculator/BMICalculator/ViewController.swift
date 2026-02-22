import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var riskLabel: UILabel!

    var lastLinks: [String] = []

    @IBAction func callAPI(_ sender: UIButton) {

        guard let height = Int(heightField.text ?? ""),
              let weight = Int(weightField.text ?? "") else {
            riskLabel.text = "Invalid input"
            riskLabel.textColor = .red
            return
        }

        let urlString = "https://jig2ag6wwdvb52n6jrexlf3n7u0comxh.lambda-url.us-west-2.on.aws?height=\(height)&weight=\(weight)"
        
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(BMIResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.updateUI(response: decoded)
                    }
                    
                } catch {
                    print("JSON decode error:", error)
                }
            }
        }.resume()
    }

    func updateUI(response: BMIResponse) {
        bmiLabel.text = String(format: "%.2f", response.bmi)
        riskLabel.text = response.risk
        lastLinks = response.more

        let bmi = response.bmi

        if bmi < 18 {
            riskLabel.textColor = .blue
        } else if bmi < 25 {
            riskLabel.textColor = .green
        } else if bmi < 30 {
            riskLabel.textColor = .purple
        } else {
            riskLabel.textColor = .red
        }
    }

    @IBAction func educateMe(_ sender: UIButton) {
        guard lastLinks.count > 0,
              let url = URL(string: lastLinks[0]) else { return }

        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
