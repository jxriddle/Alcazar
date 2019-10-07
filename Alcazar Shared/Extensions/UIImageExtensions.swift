//
//  UIImageExtensions.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/30/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

extension NSImage
{
    func Crop(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> NSImage
    {
        var cropRect = CGRect(x: x, y: y, width: width, height: height)
        
        let cgImage = self.cgImage(forProposedRect: &cropRect, context: nil, hints: nil)
        
        let cgImageSize = NSSize(width: width, height: height)
        
        return NSImage(cgImage: cgImage!, size: cgImageSize)
    }
}
