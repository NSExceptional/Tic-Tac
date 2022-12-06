//
//  FavoriteLocationCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/6/22.
//

import UIKit

class FavoriteLocationCell: BaseCell {
    override class var preferredStyle: CellStyle { .subtitle }
    
    static let coordFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        return formatter
    }()
    
    private var formatter: NumberFormatter { FavoriteLocationCell.coordFormatter }
    
    var location: SavedLocation? {
        didSet {
            guard let location = location else {
                self.textLabel?.text = ""
                self.detailTextLabel?.text = ""
                return
            }
            
            let coords = location.location.coordinate
            let lat = self.formatter.string(from: coords.latitude as NSNumber) ?? "?"
            let lng = self.formatter.string(from: coords.longitude as NSNumber) ?? "?"
            
            self.textLabel?.text = location.name
            self.detailTextLabel?.text = "\(lat), \(lng)"
        }
    }
    
    override func setup() {
        self.backgroundColor = .clear
        
        self.textLabel?.font = .preferredFont(forTextStyle: .headline)
        self.detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        
        self.detailTextLabel?.textColor = .secondaryLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
    }
}
