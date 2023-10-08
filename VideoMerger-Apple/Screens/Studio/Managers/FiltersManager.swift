//
//  FiltersManager.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import CoreImage
import Foundation

final class FiltersManager {
    
    var filters = [ImageFilter]()
    
    private var arrFilters = [[String: Any]]()
    
    init() {
//        load()
    }
    
    func load(_ completion: @escaping () -> Void) {
        readJsonFile()
        if let customFilterChain = getCustomFilterChain() {
            setupFilters(customFilterChain: customFilterChain)
        } else {
            setupFilters()
        }
        completion()
    }

    private func readJsonFile()  {
        if let path = Bundle.main.path(forResource: "filters", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: Any] {
                    if let arrFilters = jsonResult["filters"] as? [[String:Any]] {
                        self.arrFilters.append(contentsOf: arrFilters)
                    }
                }
            } catch {
                // handle error
            }
        }
    }
    
    private func setupFilters(customFilterChain: [CIFilter]? = nil) {
        filters = [.noFilter, .inversion]
        if let customFilterChain = customFilterChain {
            filters.append(ImageFilter.custom(customFilterChain, "ParisLights"))
        }
    }
    
    private func getCustomFilterChain() -> [CIFilter]?  {
        
        var filters = [CIFilter?]()
        
        for filter in arrFilters {
            let filterKey = filter["key"] as? String
            let filterParams = filter["parameters"] as? [[String:Any]]
            
            switch filterKey {
            case "CIExposureAdjust":
                let dictFilterParams = filterParams?.first!
                let value = dictFilterParams!["val"] as? Double
                let imgFilter = CIFilter(name: "CIExposureAdjust")
                imgFilter?.setValue(value, forKey: kCIInputEVKey)
                filters.append(imgFilter)
            case "SaturationFilter":
                let dictFilterParams = filterParams?.first!
                let value = dictFilterParams!["val"] as? Double
                let imgFilter = CIFilter(name: "CIColorControls")
                imgFilter?.setValue(value, forKey: kCIInputSaturationKey)
                filters.append(imgFilter)
            case "CISharpenLuminance":
                let dictFilterParams = filterParams?.first!
                let value = dictFilterParams!["val"] as? Double
                let imgFilter = CIFilter(name: "CISharpenLuminance")
                imgFilter?.setValue(value, forKey: kCIInputSharpnessKey)
                filters.append(imgFilter)
            case "CIHighlightShadowAdjust":
                let imgFilter = CIFilter(name: "CIHighlightShadowAdjust")
                for filterValue in filterParams! {
                    if let key = filterValue["key"] as? String, let inputShadow = filterValue["val"] as? Double{
                        imgFilter?.setValue(inputShadow, forKey: key)
                    }                }
                filters.append(imgFilter)
            case "CIToneCurve":
                let imgFilter = CIFilter(name: "CIToneCurve")
                for filterValue in filterParams! {
                    if let valuesOfVector = filterValue["val"] as? [Double], let key = filterValue["key"] as? String{
                        let vector = CIVector.init(x: CGFloat(valuesOfVector.first!), y: CGFloat(valuesOfVector.last!))
                        imgFilter?.setValue(vector, forKey: key)
                    }
                }
                filters.append(imgFilter)
                
            case "MultiBandHSV":
                let imgFilter = MultiBandHSV()
                for filterValue in filterParams! {
                    if let valuesOfVector = filterValue["val"] as? [CGFloat], let key = filterValue["key"] as? String{
                        let vector =  CIVector.init(x: valuesOfVector.first!, y: valuesOfVector[1], z: valuesOfVector.last!)
                        imgFilter.setValue(vector, forKey: key)
                    }
                }
                filters.append(imgFilter)
                break
            default:
                break
            }
        }
        
        return filters.compactMap({ $0 })
    }
    
    func apply(_ filter: CIFilter?, for image: CIImage) -> CIImage {
        
        guard let filter = filter else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        guard let filteredImage = filter.value(forKey: kCIOutputImageKey) else { return image }
        return filteredImage as! CIImage
    }
}
