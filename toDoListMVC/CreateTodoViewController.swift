//
//  ViewController.swift
//  todoList
//
//  Created by Nutan Niraula on 5/25/18.
//  Copyright © 2018 SmartMobe. All rights reserved.
//

import UIKit

class CreateTodoViewController: UIViewController {
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    @IBOutlet weak var taskExpiryDateTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var networkCallStatusLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView!
    var alert: UIAlertController!
    var dateToolBar: UIToolbar!
    var datePicker = UIDatePicker()
    
    @IBAction func onSaveButtonTapped(_ sender: Any) {
        //Network call to save model
        guard taskExpiryDateTextField.text != "" && taskDescriptionTextField.text != "" && taskExpiryDateTextField.text != ""
            else {
                networkCallStatusLabel.text = "Please fill all the required fields"
                return
        }
        // initializing url for post request
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        // constructing url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // creating json encoded model to send in body of the post
        let dataToSave = ToDoListModel(taskTitle: taskTitleTextField.text ?? "", taskDescription: taskDescriptionTextField.text ?? "", taskAddedDate: Date(), expiryDate: Date())
        do {
            let jsonBody = try JSONEncoder().encode(dataToSave)
            request.httpBody = jsonBody
        } catch {}
        
        showActivityIndicator()
        //making api request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self](data, _, _) in
            guard let data = data else { return }
            do {
                //decoding api response
                let sentPost = try JSONDecoder().decode(ToDoListModel.self, from: data)
                print(sentPost)
                //changing code execution to main thread for displaying data in ui
                DispatchQueue.main.async {
                    self?.networkCallStatusLabel.text = "Task Created"
                    self?.networkCallStatusLabel.textColor = .blue
                    self?.hideActivityIndicator()
                }
            } catch {
                //handling error
                DispatchQueue.main.async {
                    self?.networkCallStatusLabel.text = "Failed to save task"
                    self?.networkCallStatusLabel.textColor = .red
                    self?.hideActivityIndicator()
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVisualStyleToView()
    }
    
    // View layout code
    private func addVisualStyleToView() {
        addCornerRadiusToContainerView()
        addCornerRadiusToSaveButton()
        addDatePickerInInputAccessoryView()
    }
    
    private func addCornerRadiusToContainerView() {
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
    }
    
    private func addCornerRadiusToSaveButton() {
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    //Activity Indicator Code
    private func showActivityIndicator() {
        alert = UIAlertController(title: nil, message: "Saving...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func hideActivityIndicator() {
        alert.dismiss(animated: true, completion: nil)
    }
    
    //add toolbar
    private func addDatePickerInInputAccessoryView() {
        dateToolBar = UIToolbar()
        dateToolBar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(onDoneTapped))
        dateToolBar.setItems([doneBtn], animated: true)
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        taskExpiryDateTextField.inputAccessoryView = dateToolBar
        taskExpiryDateTextField.inputView = datePicker
    }
    
    @objc private func onDoneTapped() {
        taskExpiryDateTextField.text = createDateString(fromDate: datePicker.date)
        self.view.endEditing(true)
    }
    
    private func createDateString(fromDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        let date = dateFormatter.date(from:dateString)!
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from:date)
    }
}

