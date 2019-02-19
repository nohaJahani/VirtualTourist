//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by نهى on 20/05/1440 AH.
//  Copyright © 1440 Noha. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
