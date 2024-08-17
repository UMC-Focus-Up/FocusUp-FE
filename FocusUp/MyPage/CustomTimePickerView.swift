import UIKit

class CustomTimePickerView: UIView {
    weak var delegate: CustomStartTimePickerDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Start Time"
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        return label
    }()
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        // Customize picker appearance if needed
        return picker
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.backgroundColor = UIColor.primary4
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(titleLabel)
        addSubview(pickerView)
        addSubview(confirmButton)
        addSubview(cancelButton)
        
        // Setup constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            pickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            pickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200),
            
            confirmButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            confirmButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func confirmButtonTapped() {
        // Handle confirmation action
        // Notify delegate with selected time
        // Example:
        let selectedTime = "08:00" // This should be the selected time from the picker
        delegate?.didSelectStartTime(selectedTime)
        removeFromSuperview()
    }
    
    @objc private func cancelButtonTapped() {
        removeFromSuperview()
    }
}
