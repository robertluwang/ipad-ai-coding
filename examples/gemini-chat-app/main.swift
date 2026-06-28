import UIKit

// MARK: - Data Models
struct ChatMessage {
    let text: String
    let isUser: Bool
}

// MARK: - Core View Controller
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private var messages: [ChatMessage] = [
        ChatMessage(text: "Welcome to your Custom Gemini Client! How can I assist your workflow today?", isUser: false)
    ]
    
    private let tableView = UITableView()
    private let containerView = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    // ADJUST THIS LINE: Point to your precise LiteLLM Vertex Gateway VM address
    private let apiURLString = "http://192.168.1.50:8000/v1/chat/completions"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
        setupLayout()
        
        // Setup Keyboard Observers to dynamically push UI up when typing
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupLayout() {
        // 1. Setup Table View
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // 2. Setup Input Container Component
        containerView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1.0)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // 3. Setup Text Field
        textField.delegate = self
        textField.placeholder = "Ask Gemini..."
        textField.textColor = .white
        textField.setLeftPaddingPoints(10)
        textField.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
        textField.layer.cornerRadius = 8
        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textField)
        
        // 4. Setup Send Button
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.setTitleColor(UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0), for: .normal)
        sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        // 5. Apply Core Constraints (Programmatic Layout Anchors compatible with iOS 12)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.topAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func handleKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let isShowing = notification.name == UIResponder.keyboardWillShowNotification
            let adjustment = isShowing ? -keyboardFrame.height + view.safeAreaInsets.bottom : 0
            
            view.frame.origin.y = adjustment
            view.layoutIfNeeded()
        }
    }
    
    @objc private func sendPressed() {
        guard let text = textField.text, !text.isEmpty else { return }
        textField.text = ""
        
        // Append user prompt to UI table
        messages.append(ChatMessage(text: text, isUser: true))
        tableView.reloadData()
        scrollToBottom()
        
        // Asynchronously query LiteLLM Gateway
        queryGeminiGateway(prompt: text)
    }
    
    private func queryGeminiGateway(prompt: String) {
        guard let url = URL(string: apiURLString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", for: httpHeaderField: "Content-Type")
        
        // LiteLLM compliant OpenAI-structured JSON format payload
        let payload: [String: Any] = [
            "model": "gemini-1.5-pro",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            // Extract textual content safely out of deep nested structure
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let messageObj = firstChoice["message"] as? [String: Any],
               let content = messageObj["content"] as? String {
                
                DispatchQueue.main.async {
                    self?.messages.append(ChatMessage(text: content.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false))
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                }
            }
        }.resume()
    }
    
    private func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: some Int) -> Int { return messages.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withReuseIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - Visual Chat Custom Bubble Cell
class ChatCell: UITableViewCell {
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    
    private var activeConstraints: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        bubbleView.layer.cornerRadius = 12
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        NSLayoutConstraint.deactivate(activeConstraints)
        
        if message.isUser {
            bubbleView.backgroundColor = UIColor(red: 0.2, green: 0.45, blue: 0.9, alpha: 1.0)
            messageLabel.textColor = .white
            activeConstraints = [bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)]
        } else {
            bubbleView.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.28, alpha: 1.0)
            messageLabel.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
            activeConstraints = [bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)]
        }
        NSLayoutConstraint.activate(activeConstraints)
    }
}

// MARK: - Extensions
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

// MARK: - Main Application Entry Bootstrapper
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ChatViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))