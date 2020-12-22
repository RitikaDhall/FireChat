//
//  ProfileViewModel.swift
//  FireChat
//
//  Created by Ritika Dhall on 21/12/20.
//

import Foundation

enum ProfileViewModelType {
    case name, info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

struct Section {
    let title: String
    let options: [ProfileViewModel]
}
