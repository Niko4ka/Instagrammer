//
//  ServerErrors.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 10.11.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

final class ServerErrors {
    
    public static func check(response: HTTPURLResponse) -> String? {
            switch response.statusCode {
            case 404:
                return "Not found"
            case 400:
                return "Bad request"
            case 401:
                return "Unauthorized"
            case 406:
                return "Not acceptable"
            case 422:
                return "Unprocessable"
            case 200:
                return nil
            default:
                return "Transfer error"
            }
    }
    
    public static func showTransferError(on sender: UIViewController) {
        DispatchQueue.main.async {
            Alert.show(message: "Transfer error", on: sender)
            Spinner.stop()
        }
    }
    
}
