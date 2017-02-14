//
//  Museum.swift
//  iMuseum
//
//  Created by Valerie Greer on 2/13/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import UIKit

class Museum: NSObject {

    var museumName      :String!
    var museumStreet    :String!
    var museumCity      :String!
    var museumState     :String!
    var museumZip       :String!
    
    var museumFullAddress :String! {
        return "\(museumStreet!), \(museumCity!), \(museumState!) \(museumZip!)"
    }
    
    init(museumName: String, museumStreet: String, museumCity: String, museumState: String, museumZip: String) {
        
        self.museumName = museumName
        self.museumStreet = museumStreet
        self.museumCity = museumCity
        self.museumState = museumState
        self.museumZip = museumZip
        
    }
    
}
