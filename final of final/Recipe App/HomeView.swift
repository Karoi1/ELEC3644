//
//  HomeView.swift
//  Recipe App
//
//  Created by Yuksing Li on 27/11/2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var user: User
    let imageUrls: [String] = [
            "https://thumbs.dreamstime.com/b/hand-drawn-organic-food-healthy-vegetables-spices-background-gourmet-fish-menu-vintage-sketch-vector-design-elements-151966078.jpg",
            "https://cdn.dribbble.com/users/2367910/screenshots/6120524/10.jpg",
            "https://thumbs.dreamstime.com/b/fruit-berry-deserts-menu-design-ink-hand-drawn-baking-cakes-pies-homemade-fruits-dessert-drawing-sweet-bakery-banner-top-view-177832942.jpg"
            // Add more image URLs as needed
    ]
    
    private func OneToNlist(n: Int) -> [Int]{
        var list: [Int] = []
        for i in 1...n{
            list.append(i)
        }
        return list
    }
   
    var body: some View {
        NavigationView {
            VStack{
                Image("LOGO")
                    .resizable()
                    .scaledToFit()
                TabView {
                    ForEach(imageUrls, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200) // Set height for the carousel
                                .clipped() // Ensure the image fits within the frame
                        } placeholder: {
                            Color.gray // Placeholder color while loading
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle()) // Enables horizontal swiping
                .frame(height: 200) // Set the height for the TabView
                .padding(.horizontal)
            
                Text("All the recipes we have:").bold().font(.title)
                let list = OneToNlist(n: RecipeViewModel().recipes.count)
                RecipeListView(user:user,recipeID: list,Editable: false)
            }
        }
    }
}

#Preview {
    ContentView()
}
