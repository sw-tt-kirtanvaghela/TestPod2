//
//  OfflineStorageOption.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

public struct OfflineStorageOption {
    public var availSpaceInMb: Int = SDKConstants.osAvailSpaceInMb
    public var fileCount: Int = SDKConstants.osFileCount
    public var disabled: Bool = SDKConstants.osDisabled
}
