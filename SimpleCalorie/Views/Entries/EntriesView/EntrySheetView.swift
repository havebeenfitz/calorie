//
//  EntrySheetView.swift
//  SimpleCalorie
//
//  Created by MK on 15/09/2022.
//

import SwiftUI

struct EntrySheetView: View {
    
    @ObservedObject var model: EntriesModel
    
    @Binding var isPresented: Bool
    @State var cameraIsPresented = false
    
    var placeholder = Image(systemName: "camera")
    
    var body: some View {
        VStack(alignment: .leading) {
            header()
            entryInfo()
                .sheet(isPresented: $cameraIsPresented) {
                    ImagePicker(
                        sourceType: .camera,
                        image: $model.image,
                        isPresented: $cameraIsPresented
                    )
                }
            Spacer(minLength: 30)
            saveButton()
        }
    }
    
    // MARK: - Subviews
    
    func header() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.selectedEntry == nil ? "Add Entry" : "Edit Entry")
                    .font(.largeTitle)
                    .bold()
            }
            
            Spacer()
            
            let imageEdgeSize = 85.0
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .padding()
                    .frame(width: imageEdgeSize, height: imageEdgeSize)
                    .clipShape(Circle())
                    .onTapGesture { cameraIsPresented = true }
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: imageEdgeSize, height: imageEdgeSize)
                    .onTapGesture { cameraIsPresented = true }
            }
        }
    }
    
    func entryInfo() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                TextField("Food Name", text: $model.entryName)
                    .font(.title)
                TextField("kCal value", text: $model.kCalValue)
                    .font(.title)
                    .keyboardType(.decimalPad)
                DatePicker("Time:", selection: $model.date, in: ...Date.now)
                    .foregroundColor(.gray)
            }
        }
    }
    
    func saveButton() -> some View {
        AsyncButton {
            await model.addOrUpdateEntry()
            isPresented = false
        } label: {
            Text("Save")
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
        }
        .disabled(model.entryName.isEmpty || model.kCalValue.isEmpty)
        .background(.blue)
        .cornerRadius(10)
    }
    
}
