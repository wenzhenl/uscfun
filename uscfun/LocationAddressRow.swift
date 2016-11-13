//
//  LocationAddressRow.swift
//  uscfun
//
//  Created by Wenzheng Li on 11/13/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import Eureka

/// A selector row where the user can pick an address
public final class LocationAddressRow: SelectorRow<PushSelectorCell<String>, AddressPickerViewController>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)

        presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback {
            return AddressPickerViewController()
            }, onDismiss: {
                vc in
                _ = vc.navigationController?.popViewController(animated: true)
        })
    }
}
