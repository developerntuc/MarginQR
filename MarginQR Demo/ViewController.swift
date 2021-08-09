//
//  ViewController.swift
//  MarginQR Demo
//
//  Created by Steve Dao on 9/8/21.
//

import UIKit
import Combine
import CombineCocoa
import MarginQR

class ViewController: UIViewController {
    
    @IBOutlet var txtFieldMessage: UITextField!
    @IBOutlet var labelCorrection: UILabel!
    @IBOutlet var segmentCorrection: UISegmentedControl!
    @IBOutlet var labelQuietZone: UILabel!
    @IBOutlet var sliderQuietZone: UISlider!
    @IBOutlet var labelScale: UILabel!
    @IBOutlet var sliderScale: UISlider!
    @IBOutlet var imgView: UIImageView!
    
    private var disposeBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentCorrection.selectedSegmentIndexPublisher
            .map { index -> String? in
                switch index {
                case 0: return "7%"
                case 1: return "15%"
                case 2: return "25%"
                case 3: return "30%"
                default: return nil
                }
            }
            .sink { [weak self] in self?.labelCorrection.text = "Correction level: \($0 ?? "")" }
            .store(in: &disposeBag)
        
        sliderQuietZone.valuePublisher
            .sink { [weak self] value in
                self?.labelQuietZone.text = "Quiet zone: \(value.rounded())"
            }
            .store(in: &disposeBag)
        
        sliderScale.valuePublisher
            .sink { [weak self] value in
                self?.labelScale.text = "Scale: \(value.rounded())"
            }
            .store(in: &disposeBag)
        
        let correctionLevelPublisher = segmentCorrection.selectedSegmentIndexPublisher
            .map { index -> MarginQR.CorrectionLevel in
                switch index {
                case 0: return .l
                case 1: return .m
                case 2: return .q
                case 3: return .h
                default: return .m
                }
            }
        
        Publishers.CombineLatest4(txtFieldMessage.textPublisher,
                                  correctionLevelPublisher,
                                  sliderQuietZone.valuePublisher,
                                  sliderScale.valuePublisher)
            .map { MarginQR(message: $0.0 ?? "", correctionLevel: $0.1, quietZone: Int($0.2.rounded()), scale: CGFloat($0.3.rounded())) }
            .print()
            .sink { [weak imgView] in imgView?.image = $0.uiImage }
            .store(in: &disposeBag)
        
        sliderQuietZone.value = 4
        sliderQuietZone.sendActions(for: .valueChanged)
        sliderScale.value = 5
        sliderScale.sendActions(for: .valueChanged)
    }
    
    
}

