//
//  NewBGWSTMView.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 5/30/24.
//

import SwiftUI

enum ReadingType {
    case glucode
    case weightScale
    case thermometer

    var description: String {
        switch self {
        case .glucode:
            "Glucometer"
        case .weightScale:
            "Weight Scale"
        case .thermometer:
            "Thermometer"
        }
    }
}

struct NewBGWSTMView: View {

    weak var navigationController: UINavigationController?

    private var maximumValue: Double = 0.0
    private var readingType: ReadingType
    private var readingDisplayType: String = ""

    @State private var offset: CGFloat = 0
    var rectSize = CGSize(width: 300, height: 70)
    var circleSize: CGFloat = 70
    @GestureState var isDragging: Bool = false
    @State var previousOffset: CGFloat = 0

    private var database: String?
    private var mViewModel: ManualEntryViewModel?

    init(navigationController: UINavigationController,
         maximumValue: Double,
         readingType: ReadingType) {
        self.navigationController = navigationController
        self.maximumValue = maximumValue
        self.readingType = readingType

        switch readingType {
        case .glucode:
            self.offset = 38.4
            self.readingDisplayType = "mg/dl"
        case .weightScale:
            self.offset = 0
            self.readingDisplayType = "lbs"
        case .thermometer:
            self.offset = 0
            self.readingDisplayType = "°F"
        }

        if database == DatabaseEnum.coredata.rawValue {
            mViewModel = ManualEntryViewModel(with: VitalReadingCDRepository(context: CoreDataContextProvider.sharedInstance.managedObjectContext))
        } else {
            mViewModel = ManualEntryViewModel(with: RealmRepository())
        }
    }

    var body: some View {
        GeometryReader { bounds in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack {
                    // MARK: Top banner
                    HStack(alignment: .top) {

                        Button {
                            navigationController?.dismiss(animated: true)
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                        .padding(.leading)

                        Spacer()
                        Text("Glucose Reading")
                            .fontWeight(.semibold)

                        Spacer()

                        Button {
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .opacity(0)
                    }
                    .padding(.top, 20)
                    Divider()
                    upShiftingSlider
                    saveButton
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var upShiftingSlider: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                Canvas { context, size in
                    context.addFilter(.alphaThreshold(min: 0.5, max: 1, color: Color.cyan))
                    context.addFilter(.blur(radius: 7))

                    context.drawLayer { ctx in
                        if let rectangle = ctx.resolveSymbol(id: "Rectangle") {
                            ctx.draw(rectangle, at: CGPoint(x: size.width/2, y: size.height/2))
                        }
                        if let circle = ctx.resolveSymbol(id: "Circle") {
                            ctx.draw(circle, at: CGPoint(x: size.width/2 - rectSize.width/2 + circleSize/2, y: size.height/2))
                        }
                    }
                } symbols: {

                    Capsule()
                        .fill(Color.cyan)
                        .frame(width: rectSize.width, height: rectSize.height, alignment: .center)
                        .tag("Rectangle")

                    Circle()
                        .fill(Color.pink)
                        .frame(width: circleSize, height: circleSize, alignment: .center)
                        .offset(x: offset, y: isDragging ? -rectSize.height - 6 : 0)
                        .animation(animation, value: isDragging)
                        .tag("Circle")

                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isDragging, body: { _, state, _ in
                            state = true
                        })
                        .onChanged({ value in
                            self.offset = min(max(self.previousOffset + value.translation.width, 0), rectSize.width - circleSize)
                        })
                        .onEnded({ value in
                            self.previousOffset = self.offset
                        })
                )

                Circle()
                    .fill(Color.red)
                    .frame(width: circleSize - 10, height: circleSize - 10, alignment: .center)
                    .overlay {
                        switch readingType {
                        case .glucode:
                            Text("\(Int(percentage))")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        case .weightScale:
                            Text("\(Int(percentage))")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        case .thermometer:
                            Text("\(String(format: "%.1f", percentage))")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }

                    }
                    .offset(x: (-rectSize.width/2) + (circleSize/2))
                    .offset(x: offset, y: isDragging ? -rectSize.height - 7 : 0)
                    .animation(animation, value: isDragging)
                    .allowsHitTesting(false)
            }
            .frame(height: 180)

            Text(readingDisplayType)
                .font(.headline)
                .frame(width: 60, height: 30, alignment: .leading)
        }
        .padding()
    }

    private var saveButton: some View {
        VStack {
            Button(action: {
                mViewModel?.saveVitalReading(deviceType: readingType.description, closure: {
                    navigationController?.dismiss(animated: true)
                })
            }, label: {
                Text("Save")
                    .foregroundStyle(.white)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(width: 100, height: 50)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            })
        }
    }

    private var animation: Animation {
        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5)
    }

    private var percentage: Double {
        let reading = Double((offset) / (rectSize.width - circleSize) * maximumValue)
        mViewModel?.setReadingValue(value: reading)
        return reading
    }

//    func getPercentage<T>() -> T {
//        let reading = T((offset) / (rectSize.width - circleSize) * maximumValue)
//        mViewModel?.setReadingValue(value: reading)
//        return reading
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var navController = UINavigationController()
    static var previews: some View {
        NewBGWSTMView(navigationController: navController, maximumValue: 600, readingType: .weightScale)
    }
}
