//
//  AsyncImage.swift
//  MVVMWeatherApp
//
//  Created by khalifa on 2/13/21.
//

import SwiftUI

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Image
    
    init(url: URL, @ViewBuilder placeholder: () -> Image) {
        self.placeholder = placeholder()
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
    }
    
    private var content: some View {
        if let image = loader.image {
            return Image(uiImage: image).scaledToFit()
        } else {
            return  placeholder.scaledToFit()
        }
    }
}
