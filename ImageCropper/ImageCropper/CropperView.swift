//
//  CropperView.swift
//  ImageCropper
//
//  Created by Daniil on 18.11.2024.
//

import SwiftUI

struct CropperView: View {
    var inputImage: UIImage
    @Binding var croppedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    //The width and height of the view, not used as a global variable to make it easier to modify the view: default horizontal (landscape)
    @State private var screenWidth = UIScreen.main.bounds.height
    @State private var screenHeight = UIScreen.main.bounds.width
    
    //The back can be turned into a customized section
    //Border color
    var cropBorderColor: Color? = Color.white
    //Vertex pattern colors
    var cropVerticesColor: Color = Color.pink
    //Mask Transparency
    var cropperOutsideOpacity: Double = 0.4
    
    @State private var imageDisplayWidth: CGFloat = 0
    @State private var imageDisplayHeight: CGFloat = 0
    
    @State private var cropWidth: CGFloat = UIScreen.main.bounds.height/3
    @State private var cropHeight: CGFloat = UIScreen.main.bounds.height/3*0.5
    @State private var cropWidthAdd: CGFloat = 0
    @State private var cropHeightAdd: CGFloat = 0
    
    @State private var currentPositionZS: CGSize = .zero
    @State private var newPositionZS: CGSize = .zero
    
    @State private var currentPositionZ: CGSize = .zero
    @State private var newPositionZ: CGSize = .zero
    
    @State private var currentPositionZX: CGSize = .zero
    @State private var newPositionZX: CGSize = .zero
    
    @State private var currentPositionX: CGSize = .zero
    @State private var newPositionX: CGSize = .zero
    
    @State private var currentPositionYX: CGSize = .zero
    @State private var newPositionYX: CGSize = .zero
    
    @State private var currentPositionY: CGSize = .zero
    @State private var newPositionY: CGSize = .zero
    
    @State private var currentPositionYS: CGSize = .zero
    @State private var newPositionYS: CGSize = .zero
    
    @State private var currentPositionS: CGSize = .zero
    @State private var newPositionS: CGSize = .zero
    
    @State private var currentPositionCrop: CGSize = .zero
    @State private var newPositionCrop: CGSize = .zero
    
    let imageName = "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
    
    
    
    //MARK: - Body
    var body: some View {
        ZStack {
            //Black background
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black)
            
            VStack {
                //NaviBar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: (UIDevice.current.model == "iPhone") ? screenHeight/5 : screenHeight/15)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    
                    VStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "chevron.backward")
                                .padding()
                                .foregroundColor(Color.white)
                        })
                    }
                    .offset(y: (UIDevice.current.model == "iPhone") ? 10 : 5)
                }
                .ignoresSafeArea()
                
                ZStack {
                    ZStack {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .overlay(GeometryReader{geo -> AnyView in
                                DispatchQueue.main.async{
                                    self.imageDisplayWidth = geo.size.width
                                    self.imageDisplayHeight = geo.size.height
                                }
                                return AnyView(EmptyView())
                            })
                        
                        semiTransparentMask
                    }
                    
                    //Top-Leading
                    vertex(offsetX: currentPositionZS.width - cropWidth/2, offsetY: currentPositionZS.height - cropHeight/2, onChangedHandler: topLeadingDragHandler(value:))
                    //Bottom-Leading
                    vertex(offsetX: currentPositionZX.width - cropWidth/2, offsetY: currentPositionZX.height + cropHeight/2, onChangedHandler: bottomLeadingDragHandler(value:))
                    //Bottom-Trailing
                    vertex(offsetX: currentPositionYX.width + cropWidth/2, offsetY: currentPositionYX.height + cropHeight/2, onChangedHandler: bottomTraililngDragHandler(value:))
                    //Top-Trailing
                    vertex(offsetX: currentPositionYS.width + cropWidth/2, offsetY: currentPositionYS.height - cropHeight/2, onChangedHandler: topTraililngDragHandler(value:))
                    
                }
                
                Spacer()
                
                
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
        .navigationBarHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            
            if UIDevice.current.orientation.isPortrait {
                screenWidth = UIScreen.main.bounds.width
                screenHeight = UIScreen.main.bounds.height
            } else if UIDevice.current.orientation.isLandscape {
                screenWidth = UIScreen.main.bounds.height
                screenHeight = UIScreen.main.bounds.width
            }
            
            print("screenWidth: \(screenWidth), screenHeight: \(screenHeight)")
        }
    }
    
    func vertex(
        offsetX: CGFloat,
        offsetY: CGFloat,
        onChangedHandler: @escaping (DragGesture.Value)->Void
    ) -> some View {
        Image(systemName: imageName)
            .font(.system(size: 12))
            .foregroundColor(cropVerticesColor)
            .background(Circle().frame(width: 20, height: 20).foregroundColor(Color.white))
            .offset(x: offsetX, y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        onChangedHandler(value)
                    }
                    .onEnded { value in
                        operateOnEnd()
                    }
            )
    }
    
    //MARK: - Vertex handlers
    func topLeadingDragHandler(value: DragGesture.Value) {
        //Free Mode
        //Horizontal direction
        if cropWidth-value.translation.width > 40 && value.translation.width+newPositionZS.width > -imageDisplayWidth/2+cropWidth/2 {
            currentPositionZS.width = value.translation.width + newPositionZS.width
            currentPositionZX.width = value.translation.width + newPositionZX.width
            //adjacent edges
            currentPositionS.width = value.translation.width/2 + newPositionS.width
            currentPositionZ.width = value.translation.width + newPositionZ.width
            //Discontiguous edges
            currentPositionX.width = value.translation.width/2 + newPositionX.width
            //Cutter section
            currentPositionCrop.width = value.translation.width/2 + newPositionCrop.width
            cropWidthAdd = -value.translation.width
        }
        //Vertical
        if cropHeight-value.translation.height > 40 && value.translation.height+newPositionZS.height > -imageDisplayHeight/2+cropHeight/2 {
            currentPositionZS.height = value.translation.height + newPositionZS.height
            currentPositionYS.height = value.translation.height + newPositionYS.height
            //adjacent edges
            currentPositionS.height = value.translation.height + newPositionS.height
            currentPositionZ.height = value.translation.height/2 + newPositionZ.height
            //Discontiguous edges
            currentPositionY.height = value.translation.height/2 + newPositionY.height
            //Cutter section
            currentPositionCrop.height = value.translation.height/2 + newPositionCrop.height
            cropHeightAdd = -value.translation.height
        }
    }
    func bottomLeadingDragHandler(value: DragGesture.Value) {
        if cropWidth-value.translation.width > 40 && value.translation.width+newPositionZX.width > -imageDisplayWidth/2+cropWidth/2{
            currentPositionZX.width = value.translation.width + newPositionZX.width
            currentPositionZS.width = value.translation.width + newPositionZS.width
            //adjacent edges
            currentPositionZ.width = value.translation.width + newPositionZ.width
            currentPositionX.width = value.translation.width/2 + newPositionX.width
            //Discontiguous edges
            currentPositionS.width = value.translation.width/2 + newPositionX.width
            
            currentPositionCrop.width = value.translation.width/2 + newPositionCrop.width
            cropWidthAdd = -value.translation.width
        }
        
        if cropHeight+value.translation.height > 40 && value.translation.height+newPositionZX.height < imageDisplayHeight/2-cropHeight/2 {
            currentPositionZX.height = value.translation.height + newPositionZX.height
            
            currentPositionYX.height = value.translation.height + newPositionYX.height
            
            currentPositionZ.height = value.translation.height/2 + newPositionZ.height
            currentPositionX.height = value.translation.height + newPositionX.height
            
            currentPositionY.height = value.translation.height/2 + newPositionY.height
            
            currentPositionCrop.height = value.translation.height/2 + newPositionCrop.height
            cropHeightAdd = value.translation.height
        }
    }
    func bottomTraililngDragHandler(value: DragGesture.Value) {
        if cropWidth+value.translation.width > 40 && value.translation.width+newPositionYX.width < imageDisplayWidth/2-cropWidth/2{
            currentPositionYX.width = value.translation.width + newPositionYX.width
            currentPositionYS.width = value.translation.width + newPositionYS.width
            //adjacent edges
            currentPositionX.width = value.translation.width/2 + newPositionX.width
            currentPositionY.width = value.translation.width + newPositionY.width
            //Discontiguous edges
            currentPositionS.width = value.translation.width/2 + newPositionX.width
            
            currentPositionCrop.width = value.translation.width/2 + newPositionCrop.width
            cropWidthAdd = value.translation.width
        }
        
        if cropHeight+value.translation.height > 40 && value.translation.height+newPositionYX.height < imageDisplayHeight/2-cropHeight/2{
            currentPositionYX.height = value.translation.height + newPositionYX.height
            currentPositionZX.height = value.translation.height + newPositionZX.height
            
            currentPositionX.height = value.translation.height + newPositionX.height
            currentPositionY.height = value.translation.height/2 + newPositionY.height
            
            currentPositionZ.height = value.translation.height/2 + newPositionZ.height
            
            currentPositionCrop.height = value.translation.height/2 + newPositionCrop.height
            cropHeightAdd = value.translation.height
        }
    }
    func topTraililngDragHandler(value: DragGesture.Value) {
        if cropWidth+value.translation.width > 40 && value.translation.width+newPositionYS.width < imageDisplayWidth/2-cropWidth/2{
            currentPositionYS.width = value.translation.width + newPositionYS.width
            currentPositionYX.width = value.translation.width + newPositionYX.width
            //adjacent edges
            currentPositionY.width = value.translation.width + newPositionY.width
            currentPositionS.width = value.translation.width/2 + newPositionX.width
            //Discontiguous edges
            currentPositionX.width = value.translation.width/2 + newPositionX.width
            
            currentPositionCrop.width = value.translation.width/2 + newPositionCrop.width
            cropWidthAdd = value.translation.width
        }
        
        if cropHeight-value.translation.height > 40 && -value.translation.height+newPositionYS.height < imageDisplayHeight/2-cropHeight/2{
            currentPositionYS.height = value.translation.height + newPositionYS.height
            currentPositionZS.height = value.translation.height + newPositionZS.height
            
            currentPositionY.height = value.translation.height/2 + newPositionY.height
            currentPositionS.height = value.translation.height + newPositionX.height
            
            currentPositionZ.height = value.translation.height/2 + newPositionZ.height
            
            currentPositionCrop.height = value.translation.height/2 + newPositionCrop.height
            cropHeightAdd = -value.translation.height
        }
    }
    var cutoutBoxGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Here newPosition represents the current offset, because we are controlling the representation position by offset. Manipulating currentPosition directly would result in recursive summation, which is not what we want.
                // Make currentPosition equal to the new offset and newPosition, to avoid recursion.
                //max and min for out-of-bounds prevention
                currentPositionCrop.width = min(max(value.translation.width + newPositionCrop.width, -imageDisplayWidth/2+cropWidth/2), imageDisplayWidth/2-cropWidth/2)
                currentPositionCrop.height = min(max(value.translation.height + newPositionCrop.height, -imageDisplayHeight/2+cropHeight/2), imageDisplayHeight/2-cropHeight/2)
                // The coordinates of the corners are actually the same as Crop's, except that the zs and such are subtracted by half the offset of Crop's as an additional offset.
                currentPositionZS.width = currentPositionCrop.width
                currentPositionZS.height = currentPositionCrop.height
                currentPositionZX.width = currentPositionCrop.width
                currentPositionZX.height = currentPositionCrop.height
                currentPositionYX.width = currentPositionCrop.width
                currentPositionYX.height = currentPositionCrop.height
                currentPositionYS.width = currentPositionCrop.width
                currentPositionYS.height = currentPositionCrop.height
                
                currentPositionS.width = currentPositionCrop.width
                currentPositionS.height = currentPositionCrop.height
                currentPositionZ.width = currentPositionCrop.width
                currentPositionZ.height = currentPositionCrop.height
                currentPositionX.width = currentPositionCrop.width
                currentPositionX.height = currentPositionCrop.height
                currentPositionY.width = currentPositionCrop.width
                currentPositionY.height = currentPositionCrop.height
            }
            .onEnded { value in
                // At the end of the move, make the value of the current coordinate equal to the previous value plus the coordinate of the
                currentPositionCrop.width = min(max(value.translation.width + newPositionCrop.width, -imageDisplayWidth/2+cropWidth/2), imageDisplayWidth/2-cropWidth/2)
                currentPositionCrop.height = min(max(value.translation.height + newPositionCrop.height, -imageDisplayHeight/2+cropHeight/2), imageDisplayHeight/2-cropHeight/2)
                // Make new equal to the present coordinates.
                self.newPositionCrop = self.currentPositionCrop
                operateOnEnd()
            }
    }
    
    
    //MARK: - SemiTransparentMask
    var semiTransparentMask: some View {
        ZStack {
            // Peripheral semi-transparent mask
            //left side
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(width: (imageDisplayWidth/2 - (cropWidth/2 - currentPositionCrop.width + cropWidthAdd/2)))
                .offset(x: -imageDisplayWidth/2 + (imageDisplayWidth/2 - (cropWidth/2 - currentPositionCrop.width + cropWidthAdd/2))/2)
            //Right
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(width: imageDisplayWidth/2 - (cropWidth/2 + currentPositionCrop.width + cropWidthAdd/2))
                .offset(x: imageDisplayWidth/2 - (imageDisplayWidth/2 - (cropWidth/2 + currentPositionCrop.width + cropWidthAdd/2))/2)
            // top
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(width: cropWidth + cropWidthAdd, height: imageDisplayHeight/2 - (cropHeight/2 - currentPositionCrop.height + cropHeightAdd/2))
                .offset(x: currentPositionCrop.width, y: -imageDisplayHeight/2 + (imageDisplayHeight/2 - (cropHeight/2 - currentPositionCrop.height + cropHeightAdd/2))/2)
            //Bottom
            Rectangle()
                .foregroundColor(.black)
                .opacity(cropperOutsideOpacity)
                .frame(width: cropWidth + cropWidthAdd, height: imageDisplayHeight/2 - (cropHeight/2 + currentPositionCrop.height + cropHeightAdd/2))
                .offset(x: currentPositionCrop.width, y: imageDisplayHeight/2 - (imageDisplayHeight/2 - (cropHeight/2 + currentPositionCrop.height + cropHeightAdd/2))/2)
            
            //Cutout box
            Rectangle()
                .fill(Color.white.opacity(0.01))
                .frame(width: cropWidth+cropWidthAdd, height: cropHeight+cropHeightAdd)
                .offset(x: currentPositionCrop.width, y: currentPositionCrop.height)
                .gesture(cutoutBoxGesture)
            
            //MARK: - Sides
            
            
            
            //MARK: - Top
            Rectangle()
                .frame(width: cropWidth + cropWidthAdd, height: 2)
                .offset(x: currentPositionS.width, y: currentPositionS.height - cropHeight/2)
                .foregroundColor(cropBorderColor)
                .padding(.vertical)
            
            
            //MARK: - Buttom
            Rectangle()
                .frame(width: cropWidth + cropWidthAdd, height: 2)
                .foregroundColor(cropBorderColor)
                .offset(x: currentPositionX.width, y: currentPositionX.height+cropHeight/2)
                .padding(.vertical)
            
            
            //MARK: - Leading
            Rectangle()
                .frame(width: 2, height: cropHeight + cropHeightAdd)
                .foregroundColor(cropBorderColor)
                .offset(x: currentPositionZ.width-cropWidth/2, y: currentPositionZ.height)
                .padding(.horizontal)
            
            
            //MARK: - Trailing
            Rectangle()
                .frame(width: 2, height: cropHeight + cropHeightAdd)
                .foregroundColor(cropBorderColor)
                .offset(x: currentPositionY.width + cropWidth/2, y: currentPositionY.height)
                .padding(.horizontal)
        }
    }
    
    func crop() {
        // Since CGRect goes to the coordinates before it starts generating, subtract the clipping bar like this
        let rect = CGRect(x: imageDisplayWidth/2 + currentPositionCrop.width - cropWidth/2,
                          y: imageDisplayHeight/2 + currentPositionCrop.height - cropHeight/2,
                          width: cropWidth,
                          height: cropHeight)
        croppedImage = cropImage(inputImage, toRect: rect, viewWidth: imageDisplayWidth, viewHeight: imageDisplayHeight)!
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func operateOnEnd() {
        cropWidth = cropWidth + cropWidthAdd
        cropHeight = cropHeight + cropHeightAdd
        cropWidthAdd = 0
        cropHeightAdd = 0
        
        //Conners
        currentPositionZS.width = currentPositionCrop.width
        currentPositionZS.height = currentPositionCrop.height
        
        currentPositionZX.width = currentPositionCrop.width
        currentPositionZX.height = currentPositionCrop.height
        
        currentPositionYX.width = currentPositionCrop.width
        currentPositionYX.height = currentPositionCrop.height
        
        currentPositionYS.width = currentPositionCrop.width
        currentPositionYS.height = currentPositionCrop.height
        
        //Sides
        currentPositionS.width = currentPositionCrop.width
        currentPositionS.height = currentPositionCrop.height
        
        currentPositionZ.width = currentPositionCrop.width
        currentPositionZ.height = currentPositionCrop.height
        
        currentPositionX.width = currentPositionCrop.width
        currentPositionX.height = currentPositionCrop.height
        
        currentPositionY.width = currentPositionCrop.width
        currentPositionY.height = currentPositionCrop.height
        
        self.newPositionCrop = self.currentPositionCrop
        self.newPositionZS = self.currentPositionZS
        self.newPositionZX = self.currentPositionZX
        self.newPositionYX = self.currentPositionYX
        self.newPositionYS = self.currentPositionYS
        self.newPositionS = self.currentPositionS
        self.newPositionZ = self.currentPositionZ
        self.newPositionX = self.currentPositionX
        self.newPositionY = self.currentPositionY
    }
}

