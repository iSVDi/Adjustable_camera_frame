//
//  CropImage.swift
//  ImageCropper
//
//  Created by Daniil on 18.11.2024.
//

import SwiftUI

// This function for crop givem image
func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
{
    let imageViewWidthScale = inputImage.size.width / viewWidth
    let imageViewHeightScale = inputImage.size.height / viewHeight
    // Scale cropRect to handle images larger than shown-on-screen size
    let cropZone = CGRect(x:cropRect.origin.x * imageViewWidthScale,
                          y:cropRect.origin.y * imageViewHeightScale,
                          width:cropRect.size.width * imageViewWidthScale,
                          height:cropRect.size.height * imageViewHeightScale)
    // Perform cropping in Core Graphics
    guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
    else {
        return nil
    }
    // Return image to UIImage
    let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
    return croppedImage
}
