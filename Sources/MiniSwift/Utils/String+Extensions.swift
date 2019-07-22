//
//  String+Extensions.swift
//  
//
//  Created by Jorge Revuelta on 22/07/2019.
//

import Foundation

extension String {
    init<T>(dumping object: T) {
        self.init()
        dump(object, to: &self)
    }
}
