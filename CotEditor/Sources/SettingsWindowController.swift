//
//  SettingsWindowController.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2023-01-23.
//
//  ---------------------------------------------------------------------------
//
//  © 2023 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit

final class SettingsWindowController: NSWindowController {
    
    // MARK: Lifecycle
    
    convenience init() {
        
        let viewController = SettingsTabViewController()
        viewController.tabStyle = .toolbar
        viewController.canPropagateSelectedChildViewControllerTitle = false
        viewController.tabViewItems = SettingsPane.allCases.map(\.tabViewItem)
        
        let window = SettingsWindow(contentViewController: viewController)
        window.styleMask = [.closable, .titled]
        
        self.init(window: window)
    }
}


// MARK: -

private extension SettingsPane {
    
    var tabViewItem: NSTabViewItem {
        
        let viewController: NSViewController = NSStoryboard(name: self.storyboardName, bundle: nil).instantiateInitialController()!
        let tabViewItem = NSTabViewItem(viewController: viewController)
        tabViewItem.label = self.label.localized
        tabViewItem.image = NSImage(systemSymbolName: self.symbolName, accessibilityDescription: tabViewItem.label)
        tabViewItem.identifier = self.rawValue
        
        return tabViewItem
    }
    
    
    private var storyboardName: NSStoryboard.Name {
        
        switch self {
            case .general:
                return "GeneralPane"
            case .window:
                return "WindowPane"
            case .appearance:
                return "AppearancePane"
            case .edit:
                return "EditPane"
            case .format:
                return "FormatPane"
            case .fileDrop:
                return "FileDropPane"
            case .keyBindings:
                return "KeyBindingsPane"
            case .print:
                return "PrintPane"
        }
    }
}
