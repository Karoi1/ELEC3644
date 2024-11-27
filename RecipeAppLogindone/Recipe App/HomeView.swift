//
//  HomeView.swift
//  Recipe App
//
//  Created by Yuksing Li on 27/11/2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var user: User
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
                Text("All the recipes we have:").bold().font(.title)
                let list = OneToNlist(n: RecipeViewModel().recipes.count)
                RecipeListView(user:user,recipeID: list)
            }
        }
    }
}

#Preview {
    ContentView()
}
