//
//  CropperViewX.swift
//  ImageCropper
//
//  Created by Daniil on 22.11.2024.
//

import SwiftUI

struct CropperViewX: View {
    
    var inputImage: UIImage
    @Binding var croppedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    //Vertex pattern colors
    var cropVerticesColor: Color = Color.purple
    //Mask Transparency
    var cropperOutsideOpacity: Double = 0.4
    //Border color
    var cropBorderColor: Color? = Color.white
    
    @State private var isInitialSetupDone = false
    
    @State private var imageDisplayWidth: CGFloat = 0
    @State private var imageDisplayHeight: CGFloat = 0
    
    @State private var currentPositionZS: CGSize = .zero
    @State private var lastPositionZS: CGSize = .zero
    
    @State private var currentPositionZX: CGSize = .zero
    @State private var lastPositionZX: CGSize = .zero
    
    @State private var currentPositionYX: CGSize = .zero
    @State private var lastPositionYX: CGSize = .zero
    
    @State private var currentPositionYS: CGSize = .zero
    @State private var lastPositionYS: CGSize = .zero
    
    let imageName = "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
    
    var cropWidth: CGFloat {
        currentPositionYS.width - currentPositionZS.width
    }
    
    var cropHeight: CGFloat {
        currentPositionZX.height - currentPositionZS.height
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .background(
                        GeometryReader { proxy in
                            Color.clear.onAppear {
                                //TODO: add initialSetupProperty and use for one setup vertex coordinates
                                self.imageDisplayWidth = proxy.frame(in: .global).size.width
                                self.imageDisplayHeight = proxy.frame(in: .global).size.height
                                setupInitialIfNeed()
                            }
                        }
                    )
//                    .overlay {
                        semiTransparentMask
//                    }
                
                
                //Top-Leading
                vertex(offsetX: currentPositionZS.width, offsetY: currentPositionZS.height, topLeadingDragHandler)
                //Bottom-Leading
                vertex(offsetX: currentPositionZX.width, offsetY: currentPositionZX.height, bottomLeadingDragHandler)
                //Bottom-Trailing
                vertex(offsetX: currentPositionYX.width, offsetY: currentPositionYX.height, bottomTraililngDragHandler)
                //Top-Trailing
                vertex(offsetX: currentPositionYS.width, offsetY: currentPositionYS.height, topTraililngDragHandler)
            }
            
            Button {
                crop()
            } label: {
                Image(systemName: "crop")
                    .padding(.all, 10)
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
            }
            .padding()
            
        }
        
        
    }
    
    //MARK: - SemiTransparentMask
    var semiTransparentMask: some View {
        ZStack(alignment: .topLeading) {
            // Peripheral semi-transparent mask
            //left side
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(width: currentPositionZS.width, height: imageDisplayHeight)
            
//            //Right
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(width: imageDisplayWidth - currentPositionYS.width, height: imageDisplayHeight)
                .offset(x: currentPositionYS.width)
            
            // top
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(width: currentPositionYS.width - currentPositionZS.width, height: currentPositionZS.height)
                .offset(x: currentPositionZS.width)
            
            //Bottom
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(
                    width: currentPositionYS.width - currentPositionZS.width,
                    height: imageDisplayHeight - currentPositionZX.height
                )
                .offset(x: currentPositionZS.width, y: currentPositionZX.height)
            
            //Cutout box
            //TODO: is this view need?
//            Rectangle()
//                .fill(Color.white.opacity(0.001))
//                .frame(width: cropWidth, height: cropHeight)
//                .offset(x: currentPositionZS.width, y: currentPositionZS.height)
            
            //MARK: - Sides
            
//                        //MARK: - Top
//                        side(
//                            size: .init(width: cropWidth, height: 10),
//                            offset: .init(x: currentPositionZS.width, y: currentPositionZS.height),
//                            topHandler
//                        )
//                        //MARK: - Buttom
//                        side(
//                            size: .init(width: cropWidth, height: 10),
//                            offset: .init(x: currentPositionZX.width, y: currentPositionZX.height),
//                            bottomHandler
//                        )
//                        //MARK: - Leading
//                        side(
//                            size: .init(width: 10, height: cropHeight),
//                            offset: .init(x: currentPositionZS.width, y: currentPositionZS.height),
//                            leadingHandler
//                        )
//                        //MARK: - Trailing
//                        side(
//                            size: .init(width: 10, height: cropHeight),
//                            offset: .init(x: currentPositionYS.width, y: currentPositionYS.height),
//                            traillingHandler
//                        )
        }
    }
    
    
    
    func setupInitialIfNeed() {
        guard !isInitialSetupDone else { return }
        currentPositionZS = .init(width: 50, height: 50)
        lastPositionZS = .init(width: 50, height: 50)
        
        currentPositionZX = .init(width: 50, height: imageDisplayHeight - 50)
        lastPositionZX = .init(width: 50, height: imageDisplayHeight - 50)
        
        currentPositionYX = .init(width: imageDisplayWidth - 50, height: imageDisplayHeight - 50)
        lastPositionYX = .init(width: imageDisplayWidth - 50, height: imageDisplayHeight - 50)
        
        currentPositionYS = .init(width: imageDisplayWidth - 50, height: 50)
        lastPositionYS = .init(width: imageDisplayWidth - 50, height: 50)
        
        isInitialSetupDone = true
    }
    
    func vertex(
        offsetX: CGFloat,
        offsetY: CGFloat,
        _ onChangedHandler: @escaping (DragGesture.Value)->Void
    ) -> some View {
        Image(systemName: imageName)
            .font(.system(size: 12))
            .foregroundColor(cropVerticesColor)
            .background(Circle().frame(width: 20, height: 20).foregroundColor(Color.white))
            .offset(x: offsetX, y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged(onChangedHandler)
                    .onEnded { value in
                        operateOnEnd()
                    }
            )
    }
    
    func side(
        size: CGSize,
        offset: CGPoint,
        _ onChangeHandler: @escaping (DragGesture.Value) -> Void
    ) -> some View {
        Rectangle()
            .frame(width: size.width, height: size.height)
            .foregroundColor(cropBorderColor)
            .offset(x: offset.x, y: offset.y)
            .gesture(
                DragGesture()
                    .onChanged(onChangeHandler)
                    .onEnded { value in
                        operateOnEnd()
                    }
            )
    }
    
    //MARK: - Vertex handlers
    func topLeadingDragHandler(_ value: DragGesture.Value) {

        
        //Horizontal direction
        currentPositionZS.width = min(max(value.translation.width + lastPositionZS.width, 0), imageDisplayWidth)
        currentPositionZX.width = min(max(value.translation.width + lastPositionZX.width, 0), imageDisplayWidth)
        
        currentPositionZS.height = min(max(value.translation.height + lastPositionZS.height, 0), imageDisplayHeight)
        currentPositionYS.height = min(max(value.translation.height + lastPositionYS.height, 0), imageDisplayHeight)
        
    }
    func bottomLeadingDragHandler(_ value: DragGesture.Value) {
        //Horizontal direction
        currentPositionZX.width = min(max(value.translation.width + lastPositionZX.width, 0), imageDisplayWidth)
        currentPositionZS.width = min(max(value.translation.width + lastPositionZS.width, 0), imageDisplayWidth)
        //adjacent edges
        
        //Vertical
        currentPositionZX.height = min(max(value.translation.height + lastPositionZX.height, 0), imageDisplayHeight)
        currentPositionYX.height = min(max(value.translation.height + lastPositionYX.height, 0), imageDisplayHeight)
        
        
    }
    func bottomTraililngDragHandler(_ value: DragGesture.Value) {
        //Horizontal direction
        currentPositionYX.width = min(max(value.translation.width + lastPositionYX.width, 0), imageDisplayWidth)
        currentPositionYS.width = min(max(value.translation.width + lastPositionYS.width, 0), imageDisplayWidth)
        //adjacent edges
        
        //Vertical
        currentPositionYX.height = min(max(value.translation.height + lastPositionYX.height, 0), imageDisplayHeight)
        currentPositionZX.height = min(max(value.translation.height + lastPositionZX.height, 0), imageDisplayHeight)
        
        
    }
    func topTraililngDragHandler(_ value: DragGesture.Value) {
        //Horizontal direction
        currentPositionYS.width = min(max(value.translation.width + lastPositionYS.width, 0), imageDisplayWidth)
        currentPositionYX.width = min(max(value.translation.width + lastPositionYX.width, 0), imageDisplayWidth)
        //adjacent edges
        //Vertical
        currentPositionYS.height = min(max(value.translation.height + lastPositionYS.height, 0), imageDisplayHeight)
        currentPositionZS.height = min(max(value.translation.height + lastPositionZS.height, 0), imageDisplayHeight)
    }
    
    //MARK: - Sides handler
    
    func topHandler(_ value : DragGesture.Value) {
        currentPositionYS.height = min(max(value.translation.height + lastPositionYS.height, 0), imageDisplayHeight)
        currentPositionZS.height = min(max(value.translation.height + lastPositionZS.height, 0), imageDisplayHeight)
    }
    
    func leadingHandler(_ value : DragGesture.Value) {
        currentPositionZS.width = min(max(value.translation.width + lastPositionZS.width, 0), imageDisplayWidth)
        currentPositionZX.width = min(max(value.translation.width + lastPositionZX.width, 0), imageDisplayWidth)
        
    }
    
    func bottomHandler(_ value : DragGesture.Value) {
        currentPositionZX.height = min(max(value.translation.height + lastPositionZX.height, 0), imageDisplayHeight)
        currentPositionYX.height = min(max(value.translation.height + lastPositionYX.height, 0), imageDisplayHeight)
    }
    
    func traillingHandler(_ value : DragGesture.Value) {
        currentPositionYS.width = min(max(value.translation.width + lastPositionYS.width, 0), imageDisplayWidth)
        currentPositionYX.width = min(max(value.translation.width + lastPositionYX.width, 0), imageDisplayWidth)
    }
    
    
    //MARK: -
    
    func crop() {
        let rect = CGRect(x: lastPositionZS.width, y: lastPositionZS.height, width: cropWidth, height: cropHeight)
        self.croppedImage = cropImage(inputImage, toRect: rect, viewWidth: imageDisplayWidth, viewHeight: imageDisplayHeight)!
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        let imageViewWidthScale = inputImage.size.width / viewWidth
        let imageViewHeightScale = inputImage.size.height / viewHeight
        let scale = max(imageViewWidthScale, imageViewHeightScale)
    
        let cropZone = CGRect(x:cropRect.origin.x * scale,
                              y:cropRect.origin.y * scale,
                              width:cropRect.size.width * scale,
                              height:cropRect.size.height * scale)
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone) else { return nil }
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(
            cgImage: cutImageRef,
            scale: inputImage.scale,
            orientation: inputImage.imageOrientation
        )
        return croppedImage
    }
    
  
    
    func operateOnEnd() {
        self.lastPositionZS = self.currentPositionZS
        self.lastPositionZX = self.currentPositionZX
        self.lastPositionYX = self.currentPositionYX
        self.lastPositionYS = self.currentPositionYS
        printCurrentValues()
    }
    
    func printCurrentValues() {
        print("Current Values")
        print("self.currentPositionZS: \(self.currentPositionZS)")
        print("self.currentPositionZX: \(self.currentPositionZX)")
        print("self.currentPositionYX: \(self.currentPositionYX)")
        print("self.currentPositionYS: \(self.currentPositionYS)")
    }
    
}

