//
//  PageView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/26.
//

import SwiftUI

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @Binding var currentPage: Int

    init(_ views: [Page], currentPage: Binding<Int>) {
        self._currentPage = currentPage
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }

    var body: some View {
        PageViewController(controllers: viewControllers, currentPage: $currentPage)
    }
}
