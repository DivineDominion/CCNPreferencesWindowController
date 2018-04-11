//
//  AdvancedPreferencesController.swift
//  PreferencesControllerTest
//
//  Created by Bruno Vandekerkhove on 04/02/16.
//  Copyright (c) 2015 WOW Media. All rights reserved.
//

import Cocoa

class AdvancedPreferencesController: NSViewController, PreferencesViewController {
    
    convenience init() {
        
        self.init(nibName: NSNib.Name(rawValue: "AdvancedPreferencesController"), bundle: nil)
        
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("Method not implemented")
        
    }
    
    // MARK: - Preferences Panel Protocol
    
    static var preferencesIcon: NSImage {
        
        return NSImage(named: NSImage.Name.advanced)!
        
    }
    
    static var preferencesIdentifier: NSToolbarItem.Identifier {
        
        return .init(rawValue: "Advanced")
        
    }
    
    static var preferencesTitle: String {
        
        return "Advanced"
        
    }
    
}
