//
//  DonationModel.swift
//  Musictory
//
//  Created by 김상규 on 9/1/24.
//

import Foundation

struct DonationModel: Decodable {
    let buyer_id: String
    let post_id: String
    let merchant_uid: String
    let productName: String
    let price: Int
    let paidAt: String
}
