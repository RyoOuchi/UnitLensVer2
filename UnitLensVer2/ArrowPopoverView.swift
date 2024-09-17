import UIKit

class ArrowPopoverView: UIView {

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let arrowSize = CGSize(width: 20, height: 10) // Size of the arrow

    init(message: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 10
        setupView(message: message)
        addArrow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(message: String) {
        addSubview(messageLabel)
        messageLabel.text = message
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func addArrow() {
        // Create an arrow shape using CAShapeLayer
        let arrowLayer = CAShapeLayer()
        arrowLayer.fillColor = UIColor.black.withAlphaComponent(0.7).cgColor

        // Define the path for the arrow pointing downwards
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: 0)) // Start at the bottom-left of the arrow
        arrowPath.addLine(to: CGPoint(x: arrowSize.width / 2, y: -arrowSize.height)) // Tip of the arrow
        arrowPath.addLine(to: CGPoint(x: arrowSize.width, y: 0)) // End at the bottom-right of the arrow
        arrowPath.close()

        // Set the path to the arrow layer
        arrowLayer.path = arrowPath.cgPath

        // Create a UIView to hold the arrow layer
        let arrowView = UIView()
        arrowView.layer.addSublayer(arrowLayer)
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowView)

        // Adjust constraints to place the arrow on the top-right
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: arrowSize.width),
            arrowView.heightAnchor.constraint(equalToConstant: arrowSize.height),
            arrowView.topAnchor.constraint(equalTo: topAnchor, constant: -arrowSize.height), // Position arrow above the view
            arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10) // Position arrow on the right side
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = false // Make sure the arrow is visible outside the corner radius
    }
}
