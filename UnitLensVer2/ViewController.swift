import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    var unitTypeArray: [String] = ["length", "weight", "time"]
    var unitTypeArrayID: Int = 0
    var buttons: [UIButton] = []
    var blurEffectView: UIVisualEffectView?
    @IBOutlet var barUnitTypeButton: UIBarButtonItem!
    var isAnimatingBlur = false
    private var popoverView: PopoverView?
    private var arrowPopoverView: ArrowPopoverView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show Arrow Popover
        showArrowPopover()
        
        // Swipe and pinch gestures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        label.text = unitTypeArray[0]
        barUnitTypeButton.title = unitTypeArray[0]
    }

    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended || sender.state == .cancelled {
            let scale = sender.scale
            handleCustomPinchAction(for: scale)
        }
    }

    func blurScreenAndShowButtons() {
        guard blurEffectView == nil else { return }
        
        let middleButtonSize = min(view.bounds.width, view.bounds.height) * 0.4
        let sideButtonSize = min(view.bounds.width, view.bounds.height) * 0.2
        let spacing: CGFloat = 20
        
        blurEffectView = UIVisualEffectView(effect: nil)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Hide the navigation bar
        navigationController?.navigationBar.isHidden = true

        if let blurEffectView = blurEffectView {
            view.addSubview(blurEffectView)
            
            // Create and configure the middle button
            let middleButton = UIButton(type: .system)
            middleButton.setTitle(label.text ?? unitTypeArray[unitTypeArrayID], for: .normal)
            middleButton.setTitleColor(.white, for: .normal)
            middleButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            middleButton.backgroundColor = UIColor.systemBlue
            middleButton.layer.cornerRadius = middleButtonSize / 2
            middleButton.clipsToBounds = true
            middleButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            blurEffectView.contentView.addSubview(middleButton)
            buttons.append(middleButton)

            middleButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                middleButton.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
                middleButton.bottomAnchor.constraint(equalTo: blurEffectView.centerYAnchor, constant: middleButtonSize / 2),
                middleButton.widthAnchor.constraint(equalToConstant: middleButtonSize),
                middleButton.heightAnchor.constraint(equalToConstant: middleButtonSize)
            ])

            for index in [1, 2] {
                let button = UIButton(type: .system)
                button.setTitle(unitTypeArray[(unitTypeArrayID + index) % unitTypeArray.count], for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                button.backgroundColor = UIColor.systemBlue
                button.layer.cornerRadius = sideButtonSize / 2
                button.clipsToBounds = true
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                blurEffectView.contentView.addSubview(button)
                buttons.append(button)

                button.translatesAutoresizingMaskIntoConstraints = false
                let horizontalOffset: CGFloat = (index == 1) ? -middleButtonSize / 2 - sideButtonSize / 2 - spacing : middleButtonSize / 2 + sideButtonSize / 2 + spacing
                NSLayoutConstraint.activate([
                    button.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor, constant: horizontalOffset),
                    button.bottomAnchor.constraint(equalTo: middleButton.bottomAnchor),
                    button.widthAnchor.constraint(equalToConstant: sideButtonSize),
                    button.heightAnchor.constraint(equalToConstant: sideButtonSize)
                ])
            }

            UIView.animate(withDuration: 0.5) {
                blurEffectView.effect = UIBlurEffect(style: .dark)
            }
        }
    }

    @objc func buttonTapped(_ sender: UIButton) {
        label.text = "\(sender.currentTitle ?? "Button")"
        barUnitTypeButton.title = "\(sender.currentTitle ?? "Button")"
        deleteBlurView()
    }
    
    func handleCustomPinchAction(for scale: CGFloat) {
        if scale > 1 && !isAnimatingBlur {
            deleteBlurView()
        } else if scale <= 1 && !isAnimatingBlur {
            blurScreenAndShowButtons()
        }
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            unitTypeArrayID = (unitTypeArrayID == unitTypeArray.count - 1) ? 0 : unitTypeArrayID + 1
        case .left:
            unitTypeArrayID = (unitTypeArrayID == 0) ? unitTypeArray.count - 1 : unitTypeArrayID - 1
        default:
            break
        }
        updateButtonTitles()
    }

    func updateButtonTitles() {
        for (index, button) in buttons.enumerated() {
            let titleIndex = (unitTypeArrayID + index) % unitTypeArray.count
            button.setTitle(unitTypeArray[titleIndex], for: .normal)
        }
    }
    
    func deleteBlurView() {
        isAnimatingBlur = true
        if let blurEffectView = blurEffectView {
            UIView.animate(withDuration: 0.5, animations: {
                blurEffectView.effect = nil
                blurEffectView.alpha = 0
            }) { _ in
                blurEffectView.removeFromSuperview()
                self.blurEffectView = nil
                self.buttons.removeAll()
                self.isAnimatingBlur = false
                
                self.navigationController?.navigationBar.isHidden = false
                
                if let labelText = self.label.text, let index = self.unitTypeArray.firstIndex(of: labelText) {
                    if let middleButton = self.buttons.first {
                        middleButton.setTitle(self.unitTypeArray[index], for: .normal)
                    }
                    self.unitTypeArrayID = index
                    self.barUnitTypeButton.title = self.unitTypeArray[self.unitTypeArrayID]
                }
            }
        } else {
            self.isAnimatingBlur = false
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    @IBAction func pressBarButton() {
        blurScreenAndShowButtons()
    }
    
    private func showPopover() {
        let message = "This is a simple popover! Click anywhere to dismiss."
        popoverView = PopoverView(message: message)
        guard let popoverView = popoverView else { return }
        
        popoverView.frame = CGRect(x: 0, y: 0, width: 250, height: 150)
        popoverView.center = view.center
        view.addSubview(popoverView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopover))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissPopover() {
        popoverView?.removeFromSuperview()
        popoverView = nil
    }
    
    private func showArrowPopover() {
        // Create the popover message
        let message = "Add Original Unit!"
        
        // Initialize the popover view
        arrowPopoverView = ArrowPopoverView(message: message)
        guard let arrowPopoverView = arrowPopoverView else { return }
        
        // Set the size of the popover
        let popoverWidth: CGFloat = 200
        let popoverHeight: CGFloat = 100
        
        // Calculate the position of the right bar button
        guard let barButtonView = barUnitTypeButton.value(forKey: "view") as? UIView else {
            print("Right bar button view is not available")
            return
        }
        
        // Convert bar button view frame to the view's coordinate space
        let barButtonFrame = barButtonView.convert(barButtonView.bounds, to: view)
        
        // Log barButtonFrame for debugging
        print("BarButtonFrame: \(barButtonFrame)")
        
        // Calculate the top offset considering the navigation bar height
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let topOffset: CGFloat = navigationBarHeight + 8 // Adjust this for better spacing
        
        // Additional vertical offset to bring the popover down
        let yOffset: CGFloat = 20 // Adjust this value to move the popover further down
        
        // Calculate the popover position
        let popoverX = view.bounds.width - popoverWidth - 16 // 16 points away from the right edge
        let popoverY = barButtonFrame.maxY + topOffset + yOffset // Add the vertical offset to move the popover down
        
        // Log popover position for debugging
        print("Popover Position: (x: \(popoverX), y: \(popoverY))")
        
        arrowPopoverView.frame = CGRect(x: popoverX, y: popoverY, width: popoverWidth, height: popoverHeight)
        
        // Add the popover to the view hierarchy
        view.addSubview(arrowPopoverView)
        
        // Add a tap gesture to dismiss the popover
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissArrowPopover))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissArrowPopover() {
        arrowPopoverView?.removeFromSuperview()
        arrowPopoverView = nil
        
        // Show popover after arrowPopoverView is dismissed
        showPopover()
    }
}
