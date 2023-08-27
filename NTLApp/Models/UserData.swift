//
//  UserData.swift
//  NTLApp
//
//  Created by Tripsdoc on 16/08/23.
//

import Foundation

public var userPreference = UserDefaults.standard
public var ntlToken = "ntlToken"
public var ntlUserName = "ntlUserName"

func removeKey() {
    userPreference.removeObject(forKey: ntlToken)
    userPreference.removeObject(forKey: ntlUserName)
}

struct LoginData: Identifiable, Decodable {
    var fullName: String
    var id: String
    var userName: String
    var normalizedUserName: String
    var email: String
    var normalizedEmail: String
    var emailConfirmed: Bool
    var passwordHash: String
    var securityStamp: String
    var concurrencyStamp: String
    var phoneNumber: String? = nil
    var phoneNumberConfirmed: Bool
    var twoFactorEnabled: Bool
    var lockoutEnd: String? = nil
    var lockoutEnabled: Bool
    var accessFailedCount: Int
}

struct TokenData: Decodable {
    var token: String
    var expiration: String
}
