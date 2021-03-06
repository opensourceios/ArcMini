//
//  TimelineDayView.swift
//  Arc Mini
//
//  Created by Matt Greenfield on 6/3/20.
//  Copyright © 2020 Matt Greenfield. All rights reserved.
//

import SwiftUI
import LocoKit

struct TimelineDayView: View {

    @ObservedObject var timelineSegment: TimelineSegment
    @EnvironmentObject var timelineState: TimelineState
    @EnvironmentObject var mapState: MapState

    init(timelineSegment: TimelineSegment) {
        self.timelineSegment = timelineSegment
        UITableViewCell.appearance().selectionStyle = .none
        UITableView.appearance().backgroundColor = UIColor(named: "background")
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            List {
                ForEach(self.filteredListItems) { timelineItem in
                    ZStack {
                        self.listBox(for: timelineItem).onAppear {
                            if self.timelineSegment == self.timelineState.visibleTimelineSegment {
                                if timelineItem == self.filteredListItems.first {
                                    self.mapState.selectedItems = [] // zoom to all items when scrolled to top
                                } else {
                                    self.mapState.selectedItems.insert(timelineItem)
                                }
                            }
                        }.onDisappear {
                            if self.timelineSegment == self.timelineState.visibleTimelineSegment {
                                self.mapState.selectedItems.remove(timelineItem)
                            }
                        }
                        NavigationLink(destination: ItemDetailsView(timelineItem: timelineItem)) {
                            EmptyView()
                        }.hidden()
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            Rectangle().fill(Color("brandSecondary10")).frame(width: 0.5).edgesIgnoringSafeArea(.all)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            self.mapState.selectedItems.removeAll()
            self.mapState.itemSegments.removeAll()
            self.timelineState.backButtonHidden = true
            self.timelineState.updateTodayButton()
            self.timelineState.mapHeightPercent = TimelineState.rootMapHeightPercent

            // do place finds
            for case let visit as ArcVisit in self.timelineSegment.timelineItems {
                if visit.isWorthKeeping {
                    visit.findAPlace()
                }
            }
        }
        .background(Color("background"))
    }

    // TODO: need "thinking..." boxes represented in the list array somehow
    var filteredListItems: [TimelineItem] {
        return self.timelineSegment.timelineItems.reversed().filter { $0.dateRange != nil }
    }

    func listBox(for timelineItem: TimelineItem) -> some View {
        if let visit = timelineItem as? ArcVisit {
            return AnyView(VisitListBox(visit: visit)
                .listRowInsets(EdgeInsets()))
        }
        if let path = timelineItem as? ArcPath {
            return AnyView(PathListBox(path: path)
                .listRowInsets(EdgeInsets()))
        }
        fatalError("nah")
    }

}

//struct TimelineView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineView(segment: AppDelegate.todaySegment)
//    }
//}
