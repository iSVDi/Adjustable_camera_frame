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
    
    @State private var isInitialSetupDone = false
    
    @State private var imageDisplayWidth: CGFloat = 0
    @State private var imageDisplayHeight: CGFloat = 0
    
    @State private var cropWidth: CGFloat = UIScreen.main.bounds.height/3
    @State private var cropHeight: CGFloat = UIScreen.main.bounds.height/3*0.5
    @State private var cropWidthAdd: CGFloat = 0
    @State private var cropHeightAdd: CGFloat = 0
    
    @State private var currentPositionZS: CGSize = .zero
    @State private var newPositionZS: CGSize = .zero
    
    @State private var currentPositionZX: CGSize = .zero
    @State private var newPositionZX: CGSize = .zero
    
    @State private var currentPositionYX: CGSize = .zero
    @State private var newPositionYX: CGSize = .zero
    
    @State private var currentPositionYS: CGSize = .zero
    @State private var newPositionYS: CGSize = .zero
    
    
    @State private var currentPositionCrop: CGSize = .init(width: 50, height: 50)
    @State private var newPositionCrop: CGSize = .init(width: 50, height: 50)
    
    let imageName = "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
    
    var body: some View {
        ZStack {
            //Black background
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black)
            
            VStack {
                
                ZStack(alignment: .topLeading) {
                    
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onAppear {
                                        //TODO: add initialSetupProperty and use for one setup vertex coordinates
                                        self.imageDisplayWidth = proxy.size.width
                                        self.imageDisplayHeight = proxy.size.height
                                        setupInitialIfNeed()
                                    }
                                }
                            )
                            
                        
//                        semiTransparentMask
                    
                    
                    //Top-Leading
                    vertex(
                        offsetX: currentPositionZS.width,
                        offsetY: currentPositionZS.height,
                        onChangedHandler: topLeadingDragHandler(
                            value:
                        )
                    )
                    //Bottom-Leading
                    vertex(
                        offsetX: currentPositionZX.width,
                        offsetY: currentPositionZX.height,
                        onChangedHandler: bottomLeadingDragHandler(
                            value:
                        )
                    )
                    //Bottom-Trailing
                    vertex(
                        offsetX: currentPositionYX.width,
                        offsetY: currentPositionYX.height,
                        onChangedHandler: bottomTraililngDragHandler(
                            value:
                        )
                    )
                    //Top-Trailing
                    vertex(
                        offsetX: currentPositionYS.width,
                        offsetY: currentPositionYS.height,
                        onChangedHandler: topTraililngDragHandler(
                            value:
                        )
                    )
                    
                }
                
                Spacer()
                
                Button {
                    print("crop handler")
                } label: {
                    Image(systemName: "crop")
                        .padding(.all, 10)
                        .foregroundColor(.white)
                        .background(Color.gray.opacity(0.2))
                }
                .padding()
                
            }
            
        }
    }
    
    func setupInitialIfNeed() {
        guard !isInitialSetupDone else { return }
        currentPositionZS = .init(width: 50, height: 50)
        newPositionZS = .init(width: 50, height: 50)
        
        currentPositionZX = .init(width: 50, height: imageDisplayHeight - 50)
        newPositionZX = .init(width: 50, height: imageDisplayHeight - 50)
        
        currentPositionYX = .init(width: imageDisplayWidth - 50, height: imageDisplayHeight - 50)
        newPositionYX = .init(width: imageDisplayWidth - 50, height: imageDisplayHeight - 50)
        
        currentPositionYS = .init(width: imageDisplayWidth - 50, height: 50)
        newPositionYS = .init(width: imageDisplayWidth - 50, height: 50)
        
        isInitialSetupDone = true
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
        print("topLeading handler = \(value.translation)")
     
        //Horizontal direction
            currentPositionZS.width = value.translation.width + newPositionZS.width
            currentPositionZX.width = value.translation.width + newPositionZX.width
            //Cutter section
            currentPositionCrop.width = value.translation.width + newPositionCrop.width
            cropWidthAdd = -value.translation.width
        
        //Vertical
            currentPositionZS.height = value.translation.height + newPositionZS.height
            currentPositionYS.height = value.translation.height + newPositionYS.height

            //Cutter section
            currentPositionCrop.height = value.translation.height + newPositionCrop.height
            cropHeightAdd = -value.translation.height
        
    }
    func bottomLeadingDragHandler(value: DragGesture.Value) {
        //Horizontal direction
            currentPositionZX.width = value.translation.width + newPositionZX.width
            currentPositionZS.width = value.translation.width + newPositionZS.width
            //adjacent edges
            currentPositionCrop.width = value.translation.width + newPositionCrop.width
            cropWidthAdd = -value.translation.width
    
        //Vertical
            currentPositionZX.height = value.translation.height + newPositionZX.height
            
            currentPositionYX.height = value.translation.height + newPositionYX.height

            currentPositionCrop.height = value.translation.height + newPositionCrop.height
            cropHeightAdd = value.translation.height
        
    }
    func bottomTraililngDragHandler(value: DragGesture.Value) {
        //Horizontal direction
            currentPositionYX.width = value.translation.width + newPositionYX.width
            currentPositionYS.width = value.translation.width + newPositionYS.width
            //adjacent edges
       
            
            currentPositionCrop.width = value.translation.width + newPositionCrop.width
            cropWidthAdd = value.translation.width
        
        //Vertical
            currentPositionYX.height = value.translation.height + newPositionYX.height
            currentPositionZX.height = value.translation.height + newPositionZX.height
            
            currentPositionCrop.height = value.translation.height + newPositionCrop.height
            cropHeightAdd = value.translation.height
        
    }
    func topTraililngDragHandler(value: DragGesture.Value) {
        //Horizontal direction
            currentPositionYS.width = value.translation.width + newPositionYS.width
            currentPositionYX.width = value.translation.width + newPositionYX.width
            //adjacent edges
            currentPositionCrop.width = value.translation.width + newPositionCrop.width
            cropWidthAdd = value.translation.width
        
        
        //Vertical
            currentPositionYS.height = value.translation.height + newPositionYS.height
            currentPositionZS.height = value.translation.height + newPositionZS.height
            
            currentPositionCrop.height = value.translation.height + newPositionCrop.height
            cropHeightAdd = -value.translation.height
        
    }
    
    //MARK: -
    func operateOnEnd() {
        cropWidth = cropWidth + cropWidthAdd
        cropHeight = cropHeight + cropHeightAdd
        cropWidthAdd = 0
        cropHeightAdd = 0
                        
        self.newPositionCrop = self.currentPositionCrop
        self.newPositionZS = self.currentPositionZS
        self.newPositionZX = self.currentPositionZX
        self.newPositionYX = self.currentPositionYX
        self.newPositionYS = self.currentPositionYS
     
    }
}


