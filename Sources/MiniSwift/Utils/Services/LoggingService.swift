//
//  LoggingService.swift
//  
//
//  Created by Jorge Revuelta on 22/07/2019.
//

import Foundation

public class LoggingService: Service {

    public var id: UUID = UUID()

    public var perform: ServiceChain { { action, _ -> Void in
            NSLog(String(dumping: action))
        }
    }
}
