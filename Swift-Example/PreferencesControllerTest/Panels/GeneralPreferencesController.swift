//
//  GeneralPreferencesController.swift
//  PreferencesControllerTest
//
//  Created by Bruno Vandekerkhove on 04/02/16.
//  Copyright (c) 2015 WOW Media. All rights reserved.
//

import Cocoa

class GeneralPreferencesController: NSViewController, PreferencesViewController {
    
    convenience init() {
        
        self.init(nibName: NSNib.Name(rawValue: "GeneralPreferencesController"), bundle: nil)
        
        self.loadView()
        
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("Method not implemented")
        
    }
    
    // MARK: - Preferences Panel Protocol
    
    static var preferencesIcon: NSImage {
        
        return NSImage(named: NSImage.Name.preferencesGeneral)!
        
    }
    
    static var preferencesIdentifier: NSToolbarItem.Identifier {
        
        return .init(rawValue: "General")
        
    }
    
    static var preferencesTitle: String {
        
        return "General"
        
    }
    
}
