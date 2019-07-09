//
//  DispatchQueue+Extensions.swift
//  
//
//  Created by Jorge Revuelta on 01/07/2019.
//

import Foundation

public extension DispatchQueue {
    private static var token: DispatchSpecificKey<()> = {
        let key = DispatchSpecificKey<()>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()

    static var isMain: Bool {
        return DispatchQueue.getSpecific(key: token) != nil
    }
}
