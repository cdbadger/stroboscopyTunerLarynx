import UIKit
import Pitchy
import Hue
import Cartography
import Beethoven

final class ViewController: UIViewController {
  lazy var noteLabel: UILabel = {
    let label = UILabel()
    label.text = "-- Hz"
    label.font = UIFont.boldSystemFont(ofSize: 65)
    label.textColor = UIColor(hex: "DCD9DB")
    label.textAlignment = .center
    label.numberOfLines = 0
    label.sizeToFit()
    return label
  }()

  lazy var offsetLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 28)
    label.textColor = UIColor.white
    label.textAlignment = .center
    label.numberOfLines = 0
    label.sizeToFit()
    return label
  }()

  lazy var actionButton: UIButton = { [unowned self] in
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 20
    button.backgroundColor = UIColor(hex: "3DAFAE")
    button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    button.setTitleColor(UIColor.white, for: UIControlState())

    button.addTarget(self, action: #selector(ViewController.actionButtonDidPress(_:)),
      for: .touchUpInside)
    button.setTitle("Detect frequency".uppercased(), for: UIControlState())

    return button
  }()
  
  lazy var strobeButton: UIButton = { [unowned self] in
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 20
    button.backgroundColor = UIColor(hex: "3DAFAE")
    button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    button.setTitleColor(UIColor.white, for: UIControlState())
    
    button.addTarget(self, action: #selector(ViewController.strobeButtonDidPress(_:)), for: .touchUpInside)
    button.setTitle("Start Strobe".uppercased(), for: UIControlState())
    
    return button
  }()
 
 

  lazy var pitchEngine: PitchEngine = { [weak self] in
    let config = Config(estimationStrategy: .yin)
    let pitchEngine = PitchEngine(config: config, delegate: self)
    pitchEngine.levelThreshold = -30.0
    return pitchEngine
  }()

  lazy var strobeLights: StrobeLights = { [weak self] in
    let strobeLights = StrobeLights()
    return strobeLights
  }()
  
  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Stroboscopy".uppercased()
    view.backgroundColor = UIColor(hex: "111011")

    [noteLabel, actionButton, offsetLabel, strobeButton].forEach {
      view.addSubview($0)
    }

    setupLayout()
  }

  // MARK: - Action methods

  
  @objc func actionButtonDidPress(_ button: UIButton) {
    let text = pitchEngine.active
      ? NSLocalizedString("Detect frequency", comment: "").uppercased()
      : NSLocalizedString("Stop", comment: "").uppercased()

    button.setTitle(text, for: .normal)
    button.backgroundColor = pitchEngine.active
      ? UIColor(hex: "3DAFAE")
      : UIColor(hex: "E13C6C")

    noteLabel.text = "--"
    pitchEngine.active ? pitchEngine.stop() : pitchEngine.start()
    offsetLabel.isHidden = !pitchEngine.active
  }
  // MARK: - Strobe button action
 @objc func strobeButtonDidPress( _ button: UIButton) {
  let text = strobeLights.isLightOn
    ? NSLocalizedString("Start Strobe", comment: "").uppercased()
    : NSLocalizedString("Stop strobing", comment: "").uppercased()
  
  button.setTitle(text, for: .normal)
  button.backgroundColor = strobeLights.isLightOn
    ? UIColor(hex: "3DAFAE")
    : UIColor(hex: "E13C6C")
  //strobeLights.active ? strobeLights.activateStrobe(isActive: false) : strobeLights.activateStrobe(isActive: true)
  //strobeLights.lightIsOn ? strobeLights.toggleTorch(on: false) : strobeLights.toggleTorch(on: true)
  self.strobeLights.toggleStrobe()
  }
 

 

  // MARK: - Layout

  func setupLayout() {
    let totalSize = UIScreen.main.bounds

    constrain(actionButton, noteLabel, offsetLabel, strobeButton) {
      actionButton, noteLabel, offsetLabel, strobeButton in

      let superview = actionButton.superview!

      actionButton.top == superview.top + (totalSize.height - 30) / 2
      actionButton.centerX == superview.centerX
      actionButton.width == 280
      actionButton.height == 50
      
      offsetLabel.bottom == actionButton.top - 60
      offsetLabel.leading == superview.leading
      offsetLabel.trailing == superview.trailing
      offsetLabel.height == 80

      noteLabel.bottom == offsetLabel.top - 20
      noteLabel.leading == superview.leading
      noteLabel.trailing == superview.trailing
      noteLabel.height == 80
      
      
      strobeButton.top == actionButton.bottom + 30
      strobeButton.centerX == actionButton.centerX
      strobeButton.width == 280
      strobeButton.height == 50
 
    }
  }

  // MARK: - UI

  private func offsetColor(_ offsetPercentage: Double) -> UIColor {
    let color: UIColor

    switch abs(offsetPercentage) {
    case 0...5:
      color = UIColor(hex: "3DAFAE")
    case 6...25:
      color = UIColor(hex: "FDFFB1")
    default:
      color = UIColor(hex: "E13C6C")
    }

    return color
  }
}

// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
    noteLabel.text = "\(round(pitch.frequency)) Hz"

    let offsetPercentage = pitch.closestOffset.percentage
    let absOffsetPercentage = abs(offsetPercentage)

    print("pitch : \(pitch.note.string) - percentage : \(offsetPercentage)")

    guard absOffsetPercentage > 1.0 else {
      return
    }
    
// Offset labels coommented out
  /*
     let prefix = offsetPercentage > 0 ? "+" : "-"
    let color = offsetColor(offsetPercentage)
 */
    
/*
    offsetLabel.text = "\(prefix)" + String(format:"%.2f", absOffsetPercentage) + "%"
    offsetLabel.textColor = color
    offsetLabel.isHidden = false
 */
  }

  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
    print(error)
  }

  public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
    print("Below level threshold")
  }
}

