//
//  HomeView.swift
//  WeatherApp
//
//  Created by khalifa on 1/23/21.
//

import SwiftUI

struct HomeView<Model: HomeViewModel>: View {
    @ObservedObject var model: Model
    @State var isAlertPresented: Bool = false
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        let alertBool = Binding<Bool>(
            get: { self.model.errorMessage != nil },
            set: { _ in self.model.errorMessage = nil }
        )
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                if !model.loading {
                    weatherInfoView
                } else {
                    ProgressView()
                }
            }
            .onAppear() { self.model.loadWeatherInfo() }
            .alert(isPresented: alertBool) {
                Alert(title: Text(""), message: Text(self.model.errorMessage ?? ""), dismissButton: .default(Text("Ok")))
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
    
    var weatherInfoView: some View {
        let toggleBool = Binding<Bool>(
            get: { self.model.showDateFromAPI },
            set: { self.model.showDateFromAPI = $0 }
        )
        return VStack(alignment: .center, spacing: 0) {
            Toggle(model.showDateFromAPI ? "Switch To Local Data" : "Switch To Server", isOn: toggleBool)              .foregroundColor(.black)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .padding(.all, 8)
            ScrollView {
            LazyVStack {
                if let daysInfo = model.daysWeatherInfo {
                    ForEach(daysInfo) { info in
                        SectionView(sectionInfo: info)
                            .padding(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                            .background(Color(.systemBlue))
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    }
                }
            }.padding(.init(top: 10, leading: 16, bottom: 10, trailing: 16))
            }.clipped()
        }.background(Color(.white))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        return HomeView<HomeViewModelImpl>.getConfiguredInstance()
    }
}

extension HomeView where Model == HomeViewModelImpl {
    static func getConfiguredInstance() -> HomeView<Model> {
        let locationManager = LocationManagerImpl(delegate: nil)
        let viewModel = HomeViewModelImpl(locationManager: locationManager, interactor: HomeInteractorImpl(coreNetwork: CoreNetwork.sharedInstance))
        locationManager.delegate = viewModel
        return HomeView<HomeViewModelImpl>(model: viewModel)
    }
}

struct SectionView: View {
    let sectionInfo: DayWeatherInfo
    var body: some View {
        GeometryReader { reader in
        VStack(alignment: .center, spacing: 10, content: {
            Text(sectionInfo.formatedDate)
                .foregroundColor(.white)
                .fontWeight(.bold)
            if let infoList = sectionInfo.info {
                ScrollView.init(.horizontal, showsIndicators: false, content: {
                    LazyHStack {
                        ForEach(infoList) { info in
                            WeatherDetailsView(info: info).frame(width: reader.size.width/4)
                        }
                    }
                })
            }
        }).padding(.all, 12)
        .cornerRadius(12)
        }.frame(height: 200)
        
    }
}

struct WeatherDetailsView: View {
    let info: WeatherInfoModel
    var body: some View {
        VStack(alignment: .center, spacing: 16, content: {
            if let urlString = info.weather?.first?.iconUrl, let url = URL.init(string: urlString) {
                AsyncImage(url: url,
                           placeholder: { Image(systemName: "Cloud") })
                    .frame(width: 50, height: 50, alignment: .center)
            }
            Text(info.time)
                .foregroundColor(.white)
                .fontWeight(.bold)
            Text(info.main?.tepreatureDescription ?? "")
                .foregroundColor(.white)
                .fontWeight(.bold)
        })
    }
}
