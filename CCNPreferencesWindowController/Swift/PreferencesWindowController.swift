//
//  PreferencesWindowController.swift
//
//  Original Objective-C code created by Frank Gregor on 16/01/15, adapted by Bruno Vandekerkhove on 30/08/15.
//  Copyright (c) 2015 cocoa:naut. All rights reserved.
//

//
//  The MIT License (MIT)
//  Copyright © 2014 Frank Gregor, <phranck@cocoanaut.com>
//  http://cocoanaut.mit-license.org
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 

import AppKit

extension NSToolbar.Identifier {
    static var preferencesToolbar: NSToolbar.Identifier { return NSToolbar.Identifier(rawValue: "CCNPreferencesMainToolbar") }
}

extension NSToolbarItem.Identifier {
    static var preferencesSegmentedControl: NSToolbarItem.Identifier { return NSToolbarItem.Identifier(rawValue: "CCNPreferencesToolbarSegmentedControl") }
}

extension NSUserInterfaceItemIdentifier {
    static var preferencesToolbarSegmentedControl: NSUserInterfaceItemIdentifier { return NSUserInterfaceItemIdentifier("CCNPreferencesToolbarSegmentedControl")}
}

let CCNPreferencesWindowFrameAutoSaveName = "PreferencesWindowFrameAutoSaveName"
let CCNPreferencesDefaultWindowRect = NSMakeRect(0, 0, 420, 230)
let CCNPreferencesToolbarSegmentedControlItemInset = NSMakeSize(36, 12)
let escapeKey = 53

// MARK: - Preferences Window Controller

@available(*, deprecated: 1.0, renamed: "PreferencesWindowController")
public typealias CCNPreferencesWindowController = PreferencesWindowController

public class PreferencesWindowController : NSWindowController, NSToolbarDelegate, NSWindowDelegate {
    
    fileprivate var toolbar: NSToolbar?
    fileprivate var segmentedControl: NSSegmentedControl?
    fileprivate var toolbarDefaultItemIdentifiers: [NSToolbarItem.Identifier]?
    
    /// The preference panels this preferences window controller displays.
    public var viewControllers = [PreferencesViewController]() {
        didSet {
            setupToolbar()
        }
    }
    
    fileprivate var activeViewController: PreferencesViewController?
    
    ////////////////////////////////////////////////////////////////////////////////
    /// @name Constructors
    ////////////////////////////////////////////////////////////////////////////////
    
    // MARK: Constructors
    
    /// Initialize a new preferences window controller.
    public init() {
        
        super.init(window: nil)

        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .unifiedTitleAndToolbar]
        window = PreferencesWindow(contentRect: CCNPreferencesDefaultWindowRect, styleMask: styleMask, backing: .buffered, defer: true)
        
        window?.isMovableByWindowBackground = true

    }
    
    /// Initializes a new preferences window controller with the given coder
    required public init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    /// @name Preferences Window Behaviour
    ////////////////////////////////////////////////////////////////////////////////
    
    // MARK: Preferences Window Behaviour
    
    ///
    ///  Determines whether the preferences window's titlebar draws its background,
    ///  allowing all buttons to show - and click - through.
    ///  In general this is only useful when the preferences window has a full sized content view.
    ///
    ///  The value defaults to false.
    ///
    public var titleAppearsTransparent = false {
        didSet {
            
            window?.titlebarAppearsTransparent = titleAppearsTransparent
            
        }
    }
    
    ///
    ///  Determines whether or not the toolbar shows a basline separator.
    ///
    ///  The value defaults to true.
    ///
    public var showToolbarSeparator = true {
        didSet {
            
            window?.toolbar?.showsBaselineSeparator = showToolbarSeparator
            
        }
    }
    
    ///
    ///  If true the toolbar will also be visible when there's only one preferencesViewController.
    //
    ///  The value defaults to true.
    ///
    public var showToolbarWithSingleViewController = true
    
    ///
    ///  Determines whether or not the toolbar is presented as a segmented control or as a genuine toolbar with
    ///  NSToolbarItem instances.
    ///
    ///  The latter's the default behaviour.
    ///
    public var showToolbarItemsAsSegmentedControl = false {
        didSet {
            if showToolbarItemsAsSegmentedControl != oldValue {
                toolbarDefaultItemIdentifiers = nil
                centerToolbarItems = true
                setupToolbar()
            }
        }
    }
    
    ///
    ///  Determines whether or not the toolbar's items are centered. This property is ignored if the toolbar is
    ///  presented as a segmented control.
    ///
    ///  Defaults to true.
    ///
    public var centerToolbarItems = true {
        didSet {
            if centerToolbarItems != oldValue {
                toolbarDefaultItemIdentifiers = nil
                setupToolbar()
            }
        }
    }
    
    ///
    ///  If true, the preferences window's content view is embedded in an NSVisualEffectView using the
    ///  NSVisualEffectBlendingModeBehindWindow blending mode.
    ///
    ///  The value defaults to false.
    ///
    public var allowsVibrancy = false {
        didSet {
            if activeViewController != nil {
                activateViewController(activeViewController!, animate: true)
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    /// @name Show & Hide Preferences Window
    ////////////////////////////////////////////////////////////////////////////////
    
    // MARK: Show & Hide Preferences Window

    @available(*, deprecated: 1.0, renamed: "showPreferencesWindow(toolbarItemIdentifier:)")
    public func showPreferencesWindow(preferencesIdentifier: String) {

        showPreferencesWindow(toolbarItemIdentifier: NSToolbarItem.Identifier(rawValue: preferencesIdentifier))
    }

    public func showPreferencesWindow(toolbarItemIdentifier: NSToolbarItem.Identifier) {

        showPreferencesWindow(selectingViewController: viewController(toolbarItemIdentifier: toolbarItemIdentifier))
    }

    ///
    ///  Show the preferences window.
    ///
    /// - parameter selectingViewController: Segment to show initially. Defaults to `nil`,
    ///   which shows the first one.
    ///
    public func showPreferencesWindow(selectingViewController viewController: PreferencesViewController? = nil) {
        
        guard let window = window else { preconditionFailure("window not set up") }

        guard !window.isVisible else {
            showWindow(self)
            selectInitialPreferencesViewController(viewController)
            return
        }

        window.alphaValue = 0.0
        showWindow(self)
        window.makeKeyAndOrderFront(self)
        NSApplication.shared.activate(ignoringOtherApps: true)

        selectInitialPreferencesViewController(viewController)

        window.center()
        window.alphaValue = 1.0
        
    }

    private func selectInitialPreferencesViewController(_ viewController: PreferencesViewController? = nil) {

        guard !viewControllers.isEmpty else { return }

        if let toolbar = window?.toolbar {

            if showToolbarItemsAsSegmentedControl {
                segmentedControl?.selectSegment(withTag: 0)
            } else if let toolbarDefaultItemIdentifiers = self.toolbarDefaultItemIdentifiers,
                toolbarDefaultItemIdentifiers.count > 0 {
                toolbar.selectedItemIdentifier = toolbarDefaultItemIdentifiers[(centerToolbarItems ? 1 : 0)]
            }
        }

        let initialViewController = viewController
            ?? activeViewController
            ?? viewControllers[0]

        activateViewController(initialViewController, animate: false)
    }


    ///
    ///  Hide the preferences window.
    ///
    public func dismissPreferencesWindow() {
        
        close()
    }
    
    // MARK: Private functions
    
    fileprivate func setupToolbar() {
        
        window?.toolbar = nil
        toolbar = nil
        toolbarDefaultItemIdentifiers = nil
        
        guard showToolbarWithSingleViewController || showToolbarItemsAsSegmentedControl || !viewControllers.isEmpty else { return }
            
        toolbar = NSToolbar(identifier: .preferencesToolbar)

        if showToolbarItemsAsSegmentedControl {

            toolbar?.allowsUserCustomization = false
            toolbar?.autosavesConfiguration = false
            toolbar?.displayMode = .iconOnly

            setupSegmentedControl()
        }
        else {
            toolbar?.allowsUserCustomization = true
            toolbar?.autosavesConfiguration = true
        }

        toolbar?.showsBaselineSeparator = showToolbarSeparator
        toolbar?.delegate = self
        window?.toolbar = toolbar
    }
    
    fileprivate func setupSegmentedControl() {
        
        segmentedControl = NSSegmentedControl()
        segmentedControl?.segmentCount = viewControllers.count
        segmentedControl?.segmentStyle = .texturedSquare
        segmentedControl?.target = self
        segmentedControl?.action = #selector(CCNPreferencesWindowController.segmentedControlAction(_:))
        segmentedControl?.identifier = .preferencesToolbarSegmentedControl
        
        if let cell = segmentedControl?.cell as? NSSegmentedCell {
            cell.controlSize = .regular
            cell.trackingMode = .selectOne
        }
        
        let segmentSize = maxSegmentSizeForCurrentViewControllers()
        
        let vcCount = CGFloat(viewControllers.count)
        let segmentWidth = segmentSize.width * vcCount + vcCount + 1.0
        let segmentHeight = segmentSize.height
        segmentedControl?.frame = NSMakeRect(0, 0, segmentWidth, segmentHeight)

        for (i, viewController) in viewControllers.enumerated() {
            
            segmentedControl?.setLabel(type(of: viewController).preferencesTitle, forSegment: i)
            segmentedControl?.setWidth(segmentSize.width, forSegment: i)
            if let cell = segmentedControl?.cell as? NSSegmentedCell {
                cell.setTag(i, forSegment: i)
            }
        }
    }
    
    fileprivate func maxSegmentSizeForCurrentViewControllers() -> NSSize {
        
        var maxSize = NSMakeSize(42, 0)
        
        for viewController in viewControllers {
            
            let title = type(of: viewController).preferencesTitle
            let titleSize = title.size(withAttributes: [NSAttributedStringKey.font: NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))])
            
            if titleSize.width + CCNPreferencesToolbarSegmentedControlItemInset.width > maxSize.width {
                let maxWidth = titleSize.width + CCNPreferencesToolbarSegmentedControlItemInset.width
                let maxHeight = titleSize.height + CCNPreferencesToolbarSegmentedControlItemInset.height
                maxSize = NSMakeSize(maxWidth, maxHeight)
            }
        }
        
        return maxSize
    }

    /// Default title of the window, used for segmented control mode only.
    public lazy var defaultWindowTitle: String = NSLocalizedString("CCNPreferencesWindowTitle", value: "Preferences", comment: "Default preferences window title with segmented control in toolbar")

    fileprivate func activateViewController(_ viewController: PreferencesViewController, animate: Bool) {
        
        guard let preferencesViewController = viewController as? NSViewController,
            let window = self.window else { return }

        toolbar?.selectedItemIdentifier = type(of: viewController).preferencesIdentifier

        let currentWindowFrame = window.frame
        let frameRectForContentRect = window.frameRect(forContentRect: preferencesViewController.view.frame)
                
        let deltaX = NSWidth(currentWindowFrame) - NSWidth(frameRectForContentRect)
        let deltaY = NSHeight(currentWindowFrame) - NSHeight(frameRectForContentRect)
        let newWindowFrame = NSMakeRect(NSMinX(currentWindowFrame) + (centerToolbarItems ? deltaX / 2 : 0), NSMinY(currentWindowFrame) + deltaY, NSWidth(frameRectForContentRect), NSHeight(frameRectForContentRect))
        
        if showToolbarItemsAsSegmentedControl {
            window.title = defaultWindowTitle
        } else {
            window.title = type(of: viewController).preferencesTitle
        }
        
        let newView = preferencesViewController.view
        newView.frame.origin = NSMakePoint(0, 0)
        newView.alphaValue = 0.0
        newView.autoresizingMask = NSView.AutoresizingMask()
        
        if let previousViewController = activeViewController as? NSViewController {
            previousViewController.view.removeFromSuperview()
        }
        
        if allowsVibrancy {
            let effectView = NSVisualEffectView(frame: newView.frame)
            effectView.blendingMode = .behindWindow
            effectView.addSubview(newView)
            window.contentView!.addSubview(effectView)
        }
        else {
            window.contentView!.addSubview(newView)
        }
        
        if let firstResponder = viewController.firstResponder?() {
            window.makeFirstResponder(firstResponder)
        }
        
        NSAnimationContext.runAnimationGroup({
            (context: NSAnimationContext) -> Void in
            context.duration = (animate ? 0.25 : 0.0)
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.window?.animator().setFrame(newWindowFrame, display: true)
            newView.animator().alphaValue = 1.0
            }) {
                () -> Void in
                self.activeViewController = viewController
        }
    }
    
    fileprivate func viewController(toolbarItemIdentifier: NSToolbarItem.Identifier) -> PreferencesViewController? {

        return viewControllers
            .filter { identifier(of: $0) == toolbarItemIdentifier }
            .first
    }
    
    // MARK: Toolbar Delegate Protocol
    
    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        switch itemIdentifier {
        case .flexibleSpace:
            return nil

        case .preferencesSegmentedControl:
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.view = segmentedControl
            return toolbarItem

        default:
            guard let viewController = viewController(toolbarItemIdentifier: itemIdentifier) else { return nil }

            let viewControllerType = type(of: viewController)

            let toolbarItem = NSToolbarItem(itemIdentifier: viewControllerType.preferencesIdentifier)
            toolbarItem.label = viewControllerType.preferencesTitle
            toolbarItem.paletteLabel = viewControllerType.preferencesTitle
            toolbarItem.image = viewControllerType.preferencesIcon
            if let tooltip = viewController.preferencesToolTip?() {
                toolbarItem.toolTip = tooltip
            }
            toolbarItem.target = self
            toolbarItem.action = #selector(CCNPreferencesWindowController.toolbarItemAction(_:))

            return toolbarItem
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {

        if toolbarDefaultItemIdentifiers == nil && viewControllers.count > 0 {
            toolbarDefaultItemIdentifiers = toolbarItemIdentifiers()
        }
        
        return toolbarDefaultItemIdentifiers ?? []
    }

    private func toolbarItemIdentifiers() -> [NSToolbarItem.Identifier] {

        var toolbarItemIdentifiers = [NSToolbarItem.Identifier]()

        if showToolbarItemsAsSegmentedControl {

            toolbarItemIdentifiers.append(.flexibleSpace)
            toolbarItemIdentifiers.append(.preferencesSegmentedControl)
            toolbarItemIdentifiers.append(.flexibleSpace)
        }
        else {

            if centerToolbarItems {
                toolbarItemIdentifiers.append(.flexibleSpace)
            }

            for viewController in viewControllers {
                toolbarItemIdentifiers.append(identifier(of: viewController))
            }

            if centerToolbarItems {
                toolbarItemIdentifiers.append(.flexibleSpace)
            }
        }

        return toolbarItemIdentifiers
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    @objc func toolbarItemAction(_ toolbarItem: NSToolbarItem) {

        guard !isActiveViewController(toolbarItemIdentifier: toolbarItem.itemIdentifier) else { return }
        guard let viewController = viewController(toolbarItemIdentifier: toolbarItem.itemIdentifier) else { return }

        activateViewController(viewController, animate: true)
    }

    @objc func segmentedControlAction(_ control: NSSegmentedControl) {
        
        guard let cell = control.cell as? NSSegmentedCell else { return }
            
        let viewController = viewControllers[cell.tag(forSegment: control.selectedSegment)]
            
        guard !isActiveViewController(viewController: viewController) else { return }

        activateViewController(viewController, animate: true)
    }

    private func isActiveViewController(viewController: PreferencesViewController) -> Bool {

        return isActiveViewController(toolbarItemIdentifier: identifier(of: viewController))
    }

    private func isActiveViewController(toolbarItemIdentifier: NSToolbarItem.Identifier) -> Bool {

        guard let activeViewController = activeViewController else { return false }

        return identifier(of: activeViewController) == toolbarItemIdentifier
    }
}

func identifier(of viewController: PreferencesViewController) -> NSToolbarItem.Identifier {
    return type(of: viewController).preferencesIdentifier
}

// MARK: - Preferences Window

///
///  A preferences window.
///
internal class PreferencesWindow: NSWindow {
    
    
    ///
    ///  Initialize a new preferences window.
    ///
    ///  - parameters:
    ///     - contentRect: The new window's content rect.
    ///     - styleMask: The new window's style mask.
    ///     - backing: The buffer type.
    ///     - defer
    ///
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer:flag)
        
        setFrameAutosaveName(NSWindow.FrameAutosaveName(rawValue: CCNPreferencesWindowFrameAutoSaveName))
        setFrameFrom(CCNPreferencesWindowFrameAutoSaveName)
    }

    override func keyDown(with theEvent: NSEvent) {
        
        switch Int(theEvent.keyCode) {
        case escapeKey:
            orderOut(nil)
            close()
        default:
            super.keyDown(with: theEvent)
        }
        
    }
    
}
